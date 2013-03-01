/*
 * meltdown -- mess up the screen
 */
/*
 * Copyright 1990 David Lemke and Network Computing Devices
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of Network Computing Devices not be
 * used in advertising or publicity pertaining to distribution of the
 * software without specific, written prior permission. Network Computing
 * Devices makes no representations about the suitability of this software
 * for any purpose. It is provided "as is" without express or implied
 * warranty.
 *
 * NETWORK COMPUTING DEVICES DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
 * SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS,
 * IN NO EVENT SHALL NETWORK COMPUTING DEVICES BE LIABLE FOR ANY SPECIAL,
 * INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
 * OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE
 * OR PERFORMANCE OF THIS SOFTWARE.
 *
 * Author:
 *		Dave Lemke
 *		lemke@ncd.com
 *
 *		Network Computing Devices, Inc
 *		350 North Bernardo Ave
 *		Mountain View, CA 94043
 *
 *		@(#)meltdown.c	1.2	90/02/22
 *
 */

#include <X11/Xlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

#define MIN_SIZE 10
#define MAX_SIZE 100

#define MIN_DIST 10

#define MIN_WIDTH 30
#define WIDTH_ADD 20

#define FINISHED 50

#define rnd(x) (random()%(x))

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

void do_planes();
void do_all();
int calc_xloc(int width);

Display *dpy;
Window win;
GC copygc, fillgc;
int screen;
int depth;

short** heights;

void usage(void)
{
	fprintf(stderr, "Usage: meltdown [-planes] [-display <displayname>]\n");
	exit(1);
}

int main(int argc, char** argv)
{
	char *display=NULL;
	unsigned long vmask;
	XSetWindowAttributes xswat;
	XGCValues gcvals;
	Bool use_planes=False;
	int i;

	srandom(getpid());
	for (i=1; i < argc; i++) {
		if (strncmp(argv[i], "-dis", 4) == 0) {
			if (argv[i+1])
				display=argv[++i];
			else
				usage();
		} else if (strncmp(argv[i], "-p", 2) == 0) {
			use_planes=1;
		} else
			usage();
	}
	if ((dpy=XOpenDisplay(display)) == NULL) {
		fprintf(stderr, "can't open display\n");
		exit(0);
	}
	screen=DefaultScreen(dpy);

	xswat.override_redirect=True;
	xswat.do_not_propagate_mask=KeyPressMask|KeyReleaseMask|ButtonPressMask|ButtonReleaseMask;
	vmask=CWOverrideRedirect|CWDontPropagate;
	win=XCreateWindow(dpy, RootWindow(dpy, screen), 0, 0,
		DisplayWidth(dpy, screen), DisplayHeight(dpy, screen),
		0, CopyFromParent, CopyFromParent, CopyFromParent, vmask,
		&xswat);
	XMapWindow(dpy, win);

	gcvals.graphics_exposures=False;
	/* copyplane gc wants to leave the data alone */
	gcvals.foreground=1;
	gcvals.background=0;
	copygc=XCreateGC(dpy, win,
		GCForeground|GCBackground|GCGraphicsExposures, &gcvals);

	gcvals.foreground=BlackPixel(dpy, screen);
	fillgc=XCreateGC(dpy, win, GCForeground, &gcvals);

	XSync(dpy, 0);
	// sleep(1);
	if (use_planes) {
		do_planes();
	} else {
		do_all();
	}
	/* NOTREACHED */
	sleep(20);
	return(0);
}

void do_planes()
{
	int over=0;
	int finished=0;
	int width, xloc, yloc, dist, size, i;
	short** heights;

	heights=(short **) malloc(DisplayPlanes(dpy, screen));
	for (i=0; i < DisplayPlanes(dpy, screen); i++)
		heights[i]=(short *) calloc(sizeof(short),
			DisplayWidth(dpy, screen));
	while (!over) {
		depth=rnd(DisplayPlanes(dpy, screen));
		width=rnd(MIN_WIDTH)+WIDTH_ADD;

		xloc=calc_xloc(width);

		yloc=DisplayHeight(dpy, screen);
		for (i=xloc; i < (xloc+width); i++) {
			yloc=min(yloc, heights[depth][i]);
		}
		if (yloc == DisplayHeight(dpy, screen))
			continue;
		dist=rnd(yloc/10+MIN_DIST);
		size=rnd(max(yloc+MIN_SIZE, MAX_SIZE));

		XSetPlaneMask(dpy, copygc, 1<<depth);
		XSetPlaneMask(dpy, fillgc, 1<<depth);
		XCopyArea(dpy, win, win, copygc,
			xloc, yloc,
			width, size,
			xloc, yloc+dist);
		XFillRectangle(dpy, win, fillgc,
			xloc, yloc,
			width, dist);
		yloc+=dist;
		for (i=xloc; i < (xloc+width); i++) {
			if ((heights[depth][i] < (DisplayHeight(dpy, screen)-MIN_SIZE)) && (yloc >= (DisplayHeight(dpy, screen)-MIN_SIZE)))
				finished++;
			heights[depth][i]=max(heights[depth][i], yloc);
		}
		if (finished >= (DisplayWidth(dpy, screen)-FINISHED)) {
			XSync(dpy, 0);
			over=1;
		}
	}
}

void do_all()
{
	int over;
	int finished=0;
	int width, xloc, yloc, dist, size, i;
	short* heights;

	heights=(short *) calloc(sizeof(short), DisplayWidth(dpy, screen));
	over=0;
	while (!over) {
		depth=rnd(DisplayPlanes(dpy, screen));
		width=rnd(MIN_WIDTH)+WIDTH_ADD;

		xloc=calc_xloc(width);

		yloc=DisplayHeight(dpy, screen);
		for (i=xloc; i < (xloc+width); i++) {
			yloc=min(yloc, heights[i]);
		}
		if (yloc == DisplayHeight(dpy, screen))
			continue;
		dist=rnd(yloc/10+MIN_DIST);
		size=rnd(max(yloc+MIN_SIZE, MAX_SIZE));

		XCopyArea(dpy, win, win, copygc,
			xloc, yloc,
			width, size,
			xloc, yloc+dist);
		XFillRectangle(dpy, win, fillgc,
			xloc, yloc,
			width, dist);
		yloc+=dist;
		for (i=xloc; i < (xloc+width); i++) {
			if ((heights[i] < (DisplayHeight(dpy, screen)-MIN_SIZE)) && (yloc >= (DisplayHeight(dpy, screen)-MIN_SIZE)))
				finished++;
			heights[i]=max(heights[i], yloc);
		}
		if (finished >= (DisplayWidth(dpy, screen)-FINISHED)) {
			XSync(dpy, 0);
			over=1;
		}
		// usleep(1);
		for(i=0; i<1900000; i++) {
		}
	}
}

int calc_xloc(int width)
{
	int xloc;

	/* give values near edges a better chance */
	xloc=rnd(DisplayWidth(dpy, screen)+MIN_WIDTH)-MIN_WIDTH;
	if ((xloc+width) > DisplayWidth(dpy, screen))
		xloc=DisplayWidth(dpy, screen)-width;
	else if (xloc < 0)
		xloc=0;
	return xloc;
}
