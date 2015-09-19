#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include "stickman.h"

void Initialize(int, char**);
void DrawSkel(SkeletonPtr s, GC gc, Window where);
void HandleKeyPress(XKeyEvent* pevent);
void HandleButtonPress(XButtonEvent* pevent);
void HandleButtonRelease(XButtonEvent* pevent);
void HandleMotion(XMotionEvent* pevent);
void DumpSkel(SkeletonPtr s);
void FlashRay(RayPtr targetray);
RayPtr FindNearestRay(XButtonEvent* pevent);
double FindDistance(int x, int y, RayPtr rayp);

extern Display* dpy;
extern Window win;
GC set_gc, dotted_gc, unset_gc;
extern Window buffer[2];

static int ButtonDown=0;

static Skeleton bones=
{
	20, 150, 200,
	{50, M_PI_2},

	{50, M_PI_4/2},
	{50, -M_PI_4/2},
	{20, M_PI_2},
	{40, -M_PI_4},
	{40, M_PI_4},

	{50, -M_PI_4/2},
	{50, M_PI_4/2},
	{20, -M_PI_2},
	{40, M_PI_4},
	{40, -M_PI_4},
};

static int offsetx, offsety;

int main(int argc, char** argv)
{
	XGCValues my_gcvalues;
	XEvent my_event;

	Initialize(argc, argv);
	XRaiseWindow(dpy, buffer[0]);

	XSelectInput(dpy, win,
		ExposureMask|ButtonPressMask|ButtonReleaseMask|
		ButtonMotionMask|KeyPressMask);

	XSelectInput(dpy, buffer[0],
		ExposureMask|ButtonPressMask|ButtonReleaseMask|
		ButtonMotionMask|KeyPressMask);

	XSelectInput(dpy, buffer[1],
		ExposureMask|ButtonPressMask|ButtonReleaseMask|
		ButtonMotionMask|KeyPressMask);

	my_gcvalues.line_width=0;
	my_gcvalues.line_style=LineSolid;

#ifdef NOCOLOR
	my_gcvalues.function=GXset;
#else
	my_gcvalues.function=GXclear;
#endif

	set_gc=XCreateGC(dpy, buffer[0],
		GCFunction|GCLineWidth|GCLineStyle,
		&my_gcvalues);

	my_gcvalues.line_width=0;
	my_gcvalues.line_style=LineOnOffDash;
	my_gcvalues.function=GXclear;
	my_gcvalues.cap_style=CapNotLast;

	dotted_gc=XCreateGC(dpy, buffer[0],
		GCFunction|GCLineWidth|GCLineStyle|GCCapStyle,
		&my_gcvalues);

	my_gcvalues.line_width=0;
	my_gcvalues.line_style=LineSolid;

#ifdef NOCOLOR
	my_gcvalues.function=GXclear;
#else
	my_gcvalues.function=GXset;
#endif

	unset_gc=XCreateGC(dpy, buffer[0],
		GCFunction|GCLineWidth|GCLineStyle,
		&my_gcvalues);

	XClearWindow(dpy, buffer[0]);
	DrawSkel(&bones, unset_gc, buffer[0]);
	while (1) {
		XNextEvent (dpy, &my_event);
		if (my_event.type == KeyPress)
			HandleKeyPress((XKeyEvent*)&my_event);
		if (my_event.type == ButtonPress)
			HandleButtonPress((XButtonEvent*)&my_event);
		if (my_event.type == ButtonRelease)
			HandleButtonRelease((XButtonEvent*)&my_event);
		if (my_event.type == MotionNotify)
			HandleMotion((XMotionEvent*)&my_event);
		else if (my_event.type == Expose) {
			XClearWindow(dpy, buffer[0]);
			DrawSkel(&bones, unset_gc, buffer[0]);
		}
	}
}

static RayPtr targetray;

void HandleKeyPress(XKeyEvent* pevent)
{
	char charback;

	XLookupString(pevent, &charback, 1, NULL, NULL);
	switch (charback) {
	case 'q':
	case 'Q':
		exit(0);
	case ' ':
	case '\n':
		DumpSkel(&bones);
	}
}

void HandleButtonRelease(XButtonEvent* pevent)
{
	ButtonDown=0;
	DrawSkel(&bones, unset_gc, buffer[0]);
}

void HandleMotion(XMotionEvent* pevent)
{
	int newx, newy, oldx, oldy;
	double newtheta, totaltheta, newr;
	RayPtr fooray;

	DrawSkel(&bones, set_gc, buffer[0]);
	newx=pevent->x;
	newy=pevent->y;

	oldx=targetray->anchor->x;
	oldy=targetray->anchor->y;
/*
** Spin the ray around its anchor
*/
	if (ButtonDown == 1) {
		if (oldx == newx)
			newx++;
		newtheta=atan((double)(oldy-newy)/(double)(oldx-newx));
		if (oldx > newx) newtheta+=M_PI;
		for (totaltheta=0, fooray=targetray->anchor; fooray; fooray=fooray->anchor) {
			totaltheta+=fooray->t;
		}
		targetray->t=newtheta-totaltheta;
		DrawSkel(&bones, unset_gc, buffer[0]);
		FlashRay (targetray);
	}
	if (ButtonDown == 2) {
		bones.waistx=newx+offsetx;
		bones.waisty=newy+offsety;
		DrawSkel(&bones, unset_gc, buffer[0]);
		DrawSkel(&bones, dotted_gc, buffer[0]);
	}
/*
** Stretch the ray out from its anchor
*/
	if (ButtonDown == 3) {
		newr=FindDistance(newx, newy, targetray->anchor);
		targetray->r=newr;
		DrawSkel(&bones, unset_gc, buffer[0]);
		FlashRay (targetray);
	}
}

void HandleButtonPress(XButtonEvent* pevent)
{
	targetray=FindNearestRay(pevent);
	switch (pevent->button) {
/*
** Button 1 rotates the selected segment about its anchor.
*/
	case 1:
		ButtonDown=1;
		FlashRay (targetray);
		break;
/*
** Button 2 drags the whole body around.
*/
	case 2:
		DrawSkel(&bones, set_gc, buffer[0]);
		DrawSkel(&bones, dotted_gc, buffer[0]);
		ButtonDown=2;
		offsetx=bones.waistx-pevent->x;
		offsety=bones.waisty-pevent->y;
		break;
/*
** Button 3 prints the current variables to the screen.
*/

	case 3:
		ButtonDown=3;
		FlashRay (targetray);
		break;
	}
}

void FlashRay(RayPtr targetray)
{
/*
 *	XDrawLine(	dpy, buffer[0], set_gc,
 * targetray->x, targetray->y,
 * targetray->anchor->x, targetray->anchor->y);
 */

	XDrawLine(dpy, buffer[0], dotted_gc,
		targetray->x, targetray->y,
		targetray->anchor->x, targetray->anchor->y);
}

RayPtr FindNearestRay(XButtonEvent* pevent) {
	RayPtr retval=NULL;
	double olddist, newdist;
	int x, y;
	RayPtr stepray;
	int stepsize=sizeof(Ray);

	x=pevent->x;
	y=pevent->y;

	olddist=99999;
/*
** Yes, I KNOW the following is a disgusting way to step through all the
** ray elements of the "bones" data structure. So there! Neah neah neah.
*/
	for (stepray=&(bones.torso); stepray <= &(bones.ltricep); stepray=(RayPtr) ((long) stepray+(long) stepsize)) {
		newdist=(FindDistance(x, y, stepray));
		if (newdist < olddist) {
			retval=stepray;
			olddist=newdist;
		}
	}
	return (retval);
}

double FindDistance(int x, int y, RayPtr rayp) {
	int a, b;
	double asq, bsq, retval;

	a=x-rayp->x;
	b=y-rayp->y;

	asq=a*a;
	bsq=b*b;

	retval=sqrt (asq+bsq);

	return (retval);
}
