/*
 * wlmelt -- mess up the screen (Wayland edition)
 *
 * A Wayland port of xmeltdown.c (meltdown, David Lemke 1990). Wayland has no
 * root window a client may scribble on, so the effect is faked: grab a
 * screenshot of the output, show it on a fullscreen overlay layer surface
 * (the closest thing to an override-redirect root-covering window), and melt
 * the pixels in software with the original algorithm. The X11 "-planes" mode
 * has no Wayland equivalent and is not ported.
 *
 * The screenshot is taken with the wlr-screencopy protocol where the
 * compositor offers it (sway, Hyprland, ...). Compositors without it (KWin,
 * for one) fall back to an external screenshot tool (grim, then spectacle)
 * whose PNG output is loaded with libpng.
 */
#define _GNU_SOURCE
#include <errno.h>
#include <png.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <wayland-client.h>

#include "viewporter-client-protocol.h"
#include "wlr-layer-shell-unstable-v1-client-protocol.h"
#include "wlr-screencopy-unstable-v1-client-protocol.h"

#define MIN_SIZE 10
#define MAX_SIZE 100
#define MIN_DIST 2
#define MIN_WIDTH 30
#define WIDTH_ADD 20
#define FINISHED 50
/* xmeltdown ran ~1000 steps/sec (usleep(1000)); at ~60 frames/sec this
 * keeps roughly the same melting rate */
#define STEPS_PER_FRAME 16

#define rnd(x) (random()%(x))
#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

#define BLACK 0xff000000u

struct shot {
	uint32_t format;
	int width, height, stride;
	uint32_t flags;
	int have_buffer;
	int done;
	int failed;
	void *data;
	size_t size;
	struct wl_buffer *wb;
};

static struct wl_display *dpy;
static struct wl_compositor *compositor;
static struct wl_shm *shm;
static struct wl_output *output;
static struct zwlr_layer_shell_v1 *layer_shell;
static struct zwlr_screencopy_manager_v1 *screencopy;
static struct wp_viewporter *viewporter;

static struct wl_surface *surface;
static struct zwlr_layer_surface_v1 *layer_surface;
static int configured;
static int closed;
static int logical_w, logical_h;

/* the melt happens on this canvas; frames are copied out to wl_buffers */
static uint32_t *canvas;
static int cw, ch;
static int *heights;
static int finished;
static int over;

struct frame_buf {
	struct wl_buffer *wb;
	uint32_t *data;
	int busy;
};
static struct frame_buf bufs[2];

static void usage(void) {
	fprintf(stderr, "Usage: wlmelt [-display <displayname>]\n");
	exit(EXIT_FAILURE);
}

static int create_shm_fd(size_t size) {
	int fd = memfd_create("wlmelt", MFD_CLOEXEC);
	if (fd < 0)
		return -1;
	if (ftruncate(fd, size) < 0) {
		close(fd);
		return -1;
	}
	return fd;
}

/* ─── screenshot via wlr-screencopy ─────────────────────────────────── */

static void shot_handle_buffer(void *data, struct zwlr_screencopy_frame_v1 *frame, uint32_t format, uint32_t width, uint32_t height, uint32_t stride) {
	(void)frame;
	struct shot *s = data;
	s->format = format;
	s->width = width;
	s->height = height;
	s->stride = stride;
	s->have_buffer = 1;
}

static void shot_handle_flags(void *data, struct zwlr_screencopy_frame_v1 *frame, uint32_t flags) {
	(void)frame;
	struct shot *s = data;
	s->flags = flags;
}

static void shot_handle_ready(void *data, struct zwlr_screencopy_frame_v1 *frame, uint32_t sec_hi, uint32_t sec_lo, uint32_t nsec) {
	(void)frame;
	(void)sec_hi;
	(void)sec_lo;
	(void)nsec;
	struct shot *s = data;
	s->done = 1;
}

static void shot_handle_failed(void *data, struct zwlr_screencopy_frame_v1 *frame) {
	(void)frame;
	struct shot *s = data;
	s->failed = 1;
	s->done = 1;
}

static const struct zwlr_screencopy_frame_v1_listener shot_listener = {
	.buffer = shot_handle_buffer,
	.flags = shot_handle_flags,
	.ready = shot_handle_ready,
	.failed = shot_handle_failed,
};

/* normalize one captured pixel row into 0xAARRGGBB words on the canvas */
static int convert_row(uint32_t *dst, const uint32_t *src, int width, uint32_t format) {
	int i;
	switch (format) {
	case WL_SHM_FORMAT_ARGB8888:
	case WL_SHM_FORMAT_XRGB8888:
		for (i = 0; i < width; i++)
			dst[i] = src[i] | 0xff000000u;
		return 0;
	case WL_SHM_FORMAT_ABGR8888:
	case WL_SHM_FORMAT_XBGR8888:
		for (i = 0; i < width; i++) {
			uint32_t p = src[i];
			dst[i] = 0xff000000u | ((p & 0xffu) << 16) | (p & 0xff00u) | ((p >> 16) & 0xffu);
		}
		return 0;
	default:
		return -1;
	}
}

static int capture_screencopy(void) {
	struct shot s;
	memset(&s, 0, sizeof(s));
	struct zwlr_screencopy_frame_v1 *frame = zwlr_screencopy_manager_v1_capture_output(screencopy, 0, output);
	zwlr_screencopy_frame_v1_add_listener(frame, &shot_listener, &s);
	while (!s.have_buffer && !s.done) {
		if (wl_display_dispatch(dpy) < 0)
			return -1;
	}
	if (s.failed || !s.have_buffer) {
		zwlr_screencopy_frame_v1_destroy(frame);
		return -1;
	}
	s.size = (size_t)s.stride * s.height;
	int fd = create_shm_fd(s.size);
	if (fd < 0) {
		zwlr_screencopy_frame_v1_destroy(frame);
		return -1;
	}
	s.data = mmap(NULL, s.size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (s.data == MAP_FAILED) {
		close(fd);
		zwlr_screencopy_frame_v1_destroy(frame);
		return -1;
	}
	struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, s.size);
	s.wb = wl_shm_pool_create_buffer(pool, 0, s.width, s.height, s.stride, s.format);
	wl_shm_pool_destroy(pool);
	close(fd);
	zwlr_screencopy_frame_v1_copy(frame, s.wb);
	while (!s.done) {
		if (wl_display_dispatch(dpy) < 0) {
			s.failed = 1;
			break;
		}
	}
	int ret = -1;
	if (!s.failed) {
		cw = s.width;
		ch = s.height;
		canvas = malloc((size_t)cw * ch * 4);
		int invert = s.flags & ZWLR_SCREENCOPY_FRAME_V1_FLAGS_Y_INVERT;
		int y;
		ret = 0;
		for (y = 0; y < ch; y++) {
			const uint32_t *src = (uint32_t *)((char *)s.data + (size_t)(invert ? ch - 1 - y : y) * s.stride);
			if (convert_row(canvas + (size_t)y * cw, src, cw, s.format) < 0) {
				fprintf(stderr, "unsupported screencopy format 0x%x\n", s.format);
				free(canvas);
				canvas = NULL;
				ret = -1;
				break;
			}
		}
	}
	wl_buffer_destroy(s.wb);
	munmap(s.data, s.size);
	zwlr_screencopy_frame_v1_destroy(frame);
	return ret;
}

/* ─── screenshot via an external tool, for compositors without
 *     wlr-screencopy (KWin and friends) ──────────────────────────────── */

static int capture_tool(void) {
	static const char *const tools[] = {
		"grim '%s' >/dev/null 2>&1",
		"spectacle -b -f -n -o '%s' >/dev/null 2>&1",
		NULL,
	};
	char path[] = "/tmp/wlmelt-XXXXXX.png";
	int fd = mkstemps(path, 4);
	if (fd < 0)
		return -1;
	close(fd);
	int got = 0;
	int i;
	for (i = 0; tools[i] && !got; i++) {
		char cmd[256];
		snprintf(cmd, sizeof(cmd), tools[i], path);
		if (system(cmd) != 0)
			continue;
		struct stat st;
		if (stat(path, &st) == 0 && st.st_size > 0)
			got = 1;
	}
	if (!got) {
		unlink(path);
		fprintf(stderr, "no screenshot tool worked (tried grim, spectacle)\n");
		return -1;
	}
	png_image img;
	memset(&img, 0, sizeof(img));
	img.version = PNG_IMAGE_VERSION;
	if (!png_image_begin_read_from_file(&img, path)) {
		unlink(path);
		fprintf(stderr, "can't read screenshot: %s\n", img.message);
		return -1;
	}
	/* BGRA bytes are 0xAARRGGBB words on little-endian, matching the
	 * canvas and the wl_shm XRGB8888 frame buffers */
	img.format = PNG_FORMAT_BGRA;
	canvas = malloc(PNG_IMAGE_SIZE(img));
	if (!png_image_finish_read(&img, NULL, canvas, 0, NULL)) {
		unlink(path);
		fprintf(stderr, "can't decode screenshot: %s\n", img.message);
		free(canvas);
		canvas = NULL;
		return -1;
	}
	unlink(path);
	cw = img.width;
	ch = img.height;
	return 0;
}

/* ─── the melt itself, straight from xmeltdown's do_all() ───────────── */

static int calc_xloc(int width) {
	int xloc;
	/* give values near edges a better chance */
	xloc = rnd(cw + MIN_WIDTH) - MIN_WIDTH;
	if ((xloc + width) > cw)
		xloc = cw - width;
	else if (xloc < 0)
		xloc = 0;
	return xloc;
}

static void melt_step(void) {
	int width, xloc, yloc, dist, size, i, row;

	width = rnd(MIN_WIDTH) + WIDTH_ADD;
	xloc = calc_xloc(width);

	yloc = ch;
	for (i = xloc; i < (xloc + width); i++) {
		yloc = min(yloc, heights[i]);
	}
	if (yloc == ch)
		return;
	dist = rnd(yloc / 10 + MIN_DIST);
	size = rnd(max(yloc + MIN_SIZE, MAX_SIZE));

	/* XCopyArea(xloc, yloc, width, size -> xloc, yloc+dist), clipped to
	 * the canvas; bottom-up since source and destination overlap */
	for (row = min(yloc + size, ch - dist) - 1; row >= yloc; row--) {
		memcpy(canvas + (size_t)(row + dist) * cw + xloc,
			canvas + (size_t)row * cw + xloc,
			(size_t)width * 4);
	}
	/* XFillRectangle(xloc, yloc, width, dist) in black */
	for (row = yloc; row < min(yloc + dist, ch); row++) {
		for (i = 0; i < width; i++)
			canvas[(size_t)row * cw + xloc + i] = BLACK;
	}
	yloc += dist;
	for (i = xloc; i < (xloc + width); i++) {
		if ((heights[i] < (ch - MIN_SIZE)) && (yloc >= (ch - MIN_SIZE)))
			finished++;
		heights[i] = max(heights[i], yloc);
	}
	if (finished >= (cw - FINISHED))
		over = 1;
}

/* ─── surface and frame plumbing ────────────────────────────────────── */

static void layer_handle_configure(void *data, struct zwlr_layer_surface_v1 *ls, uint32_t serial, uint32_t width, uint32_t height) {
	(void)data;
	zwlr_layer_surface_v1_ack_configure(ls, serial);
	logical_w = width;
	logical_h = height;
	configured = 1;
}

static void layer_handle_closed(void *data, struct zwlr_layer_surface_v1 *ls) {
	(void)data;
	(void)ls;
	closed = 1;
	over = 1;
}

static const struct zwlr_layer_surface_v1_listener layer_listener = {
	.configure = layer_handle_configure,
	.closed = layer_handle_closed,
};

static void buffer_handle_release(void *data, struct wl_buffer *wb) {
	(void)wb;
	struct frame_buf *b = data;
	b->busy = 0;
}

static const struct wl_buffer_listener buffer_listener = {
	.release = buffer_handle_release,
};

static int create_frame_bufs(void) {
	size_t stride = (size_t)cw * 4;
	size_t one = stride * ch;
	int fd = create_shm_fd(one * 2);
	if (fd < 0)
		return -1;
	void *data = mmap(NULL, one * 2, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (data == MAP_FAILED) {
		close(fd);
		return -1;
	}
	struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, one * 2);
	int i;
	for (i = 0; i < 2; i++) {
		bufs[i].wb = wl_shm_pool_create_buffer(pool, one * i, cw, ch, stride, WL_SHM_FORMAT_XRGB8888);
		bufs[i].data = (uint32_t *)((char *)data + one * i);
		wl_buffer_add_listener(bufs[i].wb, &buffer_listener, &bufs[i]);
	}
	wl_shm_pool_destroy(pool);
	close(fd);
	return 0;
}

static void frame_handle_done(void *data, struct wl_callback *cb, uint32_t time);

static const struct wl_callback_listener frame_listener = {
	.done = frame_handle_done,
};

static void submit_frame(void) {
	struct frame_buf *b = NULL;
	int i;
	for (i = 0; i < 2; i++) {
		if (!bufs[i].busy)
			b = &bufs[i];
	}
	if (b) {
		memcpy(b->data, canvas, (size_t)cw * ch * 4);
		b->busy = 1;
		wl_surface_attach(surface, b->wb, 0, 0);
		wl_surface_damage_buffer(surface, 0, 0, cw, ch);
	}
	/* even with both buffers busy, commit for the next frame callback */
	if (!over) {
		struct wl_callback *cb = wl_surface_frame(surface);
		wl_callback_add_listener(cb, &frame_listener, NULL);
	}
	wl_surface_commit(surface);
}

static void frame_handle_done(void *data, struct wl_callback *cb, uint32_t time) {
	(void)data;
	(void)time;
	wl_callback_destroy(cb);
	if (over)
		return;
	int i;
	for (i = 0; i < STEPS_PER_FRAME && !over; i++)
		melt_step();
	submit_frame();
}

/* ─── registry ──────────────────────────────────────────────────────── */

static void registry_handle_global(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version) {
	(void)data;
	(void)version;
	if (strcmp(interface, wl_compositor_interface.name) == 0) {
		compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 4);
	} else if (strcmp(interface, wl_shm_interface.name) == 0) {
		shm = wl_registry_bind(registry, name, &wl_shm_interface, 1);
	} else if (strcmp(interface, wl_output_interface.name) == 0) {
		if (!output)
			output = wl_registry_bind(registry, name, &wl_output_interface, 1);
	} else if (strcmp(interface, zwlr_layer_shell_v1_interface.name) == 0) {
		layer_shell = wl_registry_bind(registry, name, &zwlr_layer_shell_v1_interface, 1);
	} else if (strcmp(interface, zwlr_screencopy_manager_v1_interface.name) == 0) {
		screencopy = wl_registry_bind(registry, name, &zwlr_screencopy_manager_v1_interface, 1);
	} else if (strcmp(interface, wp_viewporter_interface.name) == 0) {
		viewporter = wl_registry_bind(registry, name, &wp_viewporter_interface, 1);
	}
}

static void registry_handle_global_remove(void *data, struct wl_registry *registry, uint32_t name) {
	(void)data;
	(void)registry;
	(void)name;
}

static const struct wl_registry_listener registry_listener = {
	.global = registry_handle_global,
	.global_remove = registry_handle_global_remove,
};

int main(int argc, char **argv) {
	char *display = NULL;
	int i;

	srandom(getpid());
	for (i = 1; i < argc; i++) {
		if (strncmp(argv[i], "-dis", 4) == 0) {
			if (argv[i + 1])
				display = argv[++i];
			else
				usage();
		} else
			usage();
	}
	dpy = wl_display_connect(display);
	if (dpy == NULL) {
		fprintf(stderr, "can't open display\n");
		exit(EXIT_FAILURE);
	}
	struct wl_registry *registry = wl_display_get_registry(dpy);
	wl_registry_add_listener(registry, &registry_listener, NULL);
	wl_display_roundtrip(dpy);
	if (!compositor || !shm || !output || !layer_shell || !viewporter) {
		fprintf(stderr, "compositor lacks a required protocol (need wl_compositor, wl_shm, wl_output, zwlr_layer_shell_v1, wp_viewporter)\n");
		exit(EXIT_FAILURE);
	}

	/* grab the screen before the overlay covers it */
	if (!screencopy || capture_screencopy() < 0) {
		if (capture_tool() < 0) {
			fprintf(stderr, "can't capture the screen\n");
			exit(EXIT_FAILURE);
		}
	}
	heights = calloc(cw, sizeof(int));

	surface = wl_compositor_create_surface(compositor);
	layer_surface = zwlr_layer_shell_v1_get_layer_surface(layer_shell, surface, output, ZWLR_LAYER_SHELL_V1_LAYER_OVERLAY, "wlmelt");
	zwlr_layer_surface_v1_add_listener(layer_surface, &layer_listener, NULL);
	zwlr_layer_surface_v1_set_anchor(layer_surface,
		ZWLR_LAYER_SURFACE_V1_ANCHOR_TOP | ZWLR_LAYER_SURFACE_V1_ANCHOR_BOTTOM |
		ZWLR_LAYER_SURFACE_V1_ANCHOR_LEFT | ZWLR_LAYER_SURFACE_V1_ANCHOR_RIGHT);
	zwlr_layer_surface_v1_set_exclusive_zone(layer_surface, -1);
	zwlr_layer_surface_v1_set_size(layer_surface, 0, 0);
	wl_surface_commit(surface);
	while (!configured && !closed) {
		if (wl_display_dispatch(dpy) < 0)
			exit(EXIT_FAILURE);
	}
	if (closed)
		exit(EXIT_FAILURE);

	if (create_frame_bufs() < 0) {
		fprintf(stderr, "can't create shm buffers\n");
		exit(EXIT_FAILURE);
	}
	/* the buffer holds output pixels, the surface is logical-sized; the
	 * viewport bridges the two whatever the output scale is */
	struct wp_viewport *viewport = wp_viewporter_get_viewport(viewporter, surface);
	wp_viewport_set_destination(viewport, logical_w, logical_h);

	submit_frame();
	while (!over) {
		if (wl_display_dispatch(dpy) < 0)
			break;
	}
	wl_display_roundtrip(dpy);
	sleep(2);
	wl_display_disconnect(dpy);
	return EXIT_SUCCESS;
}
