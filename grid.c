#include <stdio.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

GC gc_list[16];

Display *dpy;
Window win;
int screen;

int main(int argc, char** argv)
{
	XGCValues my_gcvalues;
	XEvent my_event;
	int counter;

	Initialize(argc, argv);

	XSelectInput(dpy, win,
		ExposureMask|ButtonPressMask|ButtonReleaseMask|
		ButtonMotionMask|KeyPressMask);

	my_gcvalues.line_width=5;
	my_gcvalues.line_style=LineSolid;
	for (counter=0; counter < 16; counter++) {
		my_gcvalues.function=counter;

		gc_list[counter]=XCreateGC(dpy, win,
			GCFunction|GCLineWidth|GCLineStyle,
			&my_gcvalues);
	}
	while (1) {
		XNextEvent (dpy, &my_event);
		if (my_event.type == Expose)
			DrawGrid();
		if (my_event.type == ButtonPress)
			DrawGrid();
	}
}

void Initialize(int argc, char** argv)
{
	XSizeHints size_hints;
	if (!(dpy=XOpenDisplay(""))) {
		printf ("Error: Can't open display.");
		exit(-1);
	}
	screen=DefaultScreen(dpy);

	size_hints.width=400;
	size_hints.height=400;
	size_hints.flags=PSize;

	win=XCreateSimpleWindow(dpy,
		DefaultRootWindow(dpy),
		0, 0,
		size_hints.width,
		size_hints.height,
		4,
		BlackPixel(dpy, screen),
		WhitePixel(dpy, screen));

	XSetStandardProperties (dpy, win, "GC demo",
		"stickman",
		None, argv, argc, &size_hints);

	XMapWindow(dpy, win);
}

void DrawGrid(void)
{
	int fromx, fromy, tox, toy;
	int counter;
	for (counter=0; counter < 16; counter++) {
		fromx=counter*10;
		fromy=0;
		tox=counter*10;
		toy=400;
		XDrawLine(dpy, win,
			gc_list[counter],
			fromx, fromy, tox, toy);

		fromx=0;
		fromy=counter*10;
		tox=400;
		toy=counter*10;
		XDrawLine(dpy, win,
			gc_list[counter],
			fromx, fromy, tox, toy);
	}
}

/*
** Given a list of points, draw line segments between them.
*/

DrawLines(pointlist, pointcount, gc)
XPoint*pointlist;
int pointcount;
GC gc;
{
	XDrawLines (dpy, win, gc, pointlist, pointcount, CoordModeOrigin);
}
