#include <math.h>
#include <stdio.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <stdlib.h>
#include "skel.h"
/*
 * Bug fixes and forward port to Linux,gcc-3.2 by Mark Veltzer <mark@veltzer.org>
 */

void DrawLines(XPoint* pointlist, int pointcount, GC gc, Window where);
void EndPoint(RayPtr targetRay, double currentT);

Display *dpy;
Window win;
Window buffer[2];
int screen;

Ray torsoup, torsodown, waist;

void DumpSkel(SkeletonPtr s)
{
	RayPtr stepray;
	int stepsize=sizeof(Ray);

	printf ("	%d, %d, %d\n", s->headradius, s->waistx, s->waisty);
/*
** Yes, I KNOW the following is a disgusting way to step through all the
** ray elements of the skeleton data structure. So there! Neah neah neah.
*/
	for (stepray=&(s->torso); stepray <= &(s->ltricep); stepray=(RayPtr) ((int) stepray+(int) stepsize)) {
		printf ("	{%d, %f}\n", stepray->r, stepray->t);
	}
	fflush(stdout);
}

void DrawSkel(SkeletonPtr s, GC gc, Window where)
{
	int xhip, yhip, xneck, yneck, xshoulder, yshoulder;
	int xhead, yhead;
	int x, y;

	double rsumt, lsumt;
	XPoint mypoints[7];

	x=s->waistx;
	y=s->waisty;

	s->rthigh.anchor=&torsoup;
	s->lthigh.anchor=&torsoup;
	s->rshin.anchor=&(s->rthigh);
	s->lshin.anchor=&(s->lthigh);
	s->rfoot.anchor=&(s->rshin);
	s->lfoot.anchor=&(s->lshin);
	s->rtricep.anchor=&(s->rbicep);
	s->ltricep.anchor=&(s->lbicep);
	s->rbicep.anchor=&torsodown;
	s->lbicep.anchor=&torsodown;

/*
** Get control points along the torso
*/
	xhip=(int) (0.5*s->torso.r*cos(s->torso.t));
	yhip=(int) (0.5*s->torso.r*sin(s->torso.t));
	xneck=-xhip;
	yneck=-yhip;
	xshoulder=(int) (0.75*xneck);
	yshoulder=(int) (0.75*yneck);

	xhead=(int) -((s->headradius+(0.5*s->torso.r))*cos(s->torso.t));
	yhead=(int) -((s->headradius+(0.5*s->torso.r))*sin(s->torso.t));

	xhip+=x;
	yhip+=y;
	xneck+=x;
	yneck+=y;
	xhead+=x;
	yhead+=y;
	xshoulder+=x;
	yshoulder+=y;

	waist.x=x;
	waist.y=y;
	waist.anchor=NULL;

	s->torso.anchor=&waist;
	s->torso.x=xhip;
	s->torso.y=yhip;

/*
** A ray from the hips pointing upwards, used as the anchor for the legs.
*/
	torsoup.x=xhip;
	torsoup.y=yhip;
	torsoup.t=s->torso.t;

/*
** A ray from the shoulders pointing downwards, the anchor for the arms.
*/
	torsodown.x=xshoulder;
	torsodown.y=yshoulder;
	torsodown.t=s->torso.t;

	mypoints[0].x=xhip;
	mypoints[0].y=yhip;
	mypoints[1].x=xneck;
	mypoints[1].y=yneck;

	DrawLines(mypoints, 2, gc, where);

/*
** Draw head
*/
	XDrawArc (dpy, where, gc,
		xhead-s->headradius, yhead-s->headradius,
		2*s->headradius,
		2*s->headradius,
		0, 360*64);

/*
** Get control points for arms
*/
	rsumt=s->torso.t;
	lsumt=s->torso.t;
	EndPoint(&(s->rbicep), rsumt);
	EndPoint(&(s->lbicep), lsumt);

	rsumt+=s->rbicep.t;
	lsumt+=s->lbicep.t;
	EndPoint(&(s->rtricep), rsumt);
	EndPoint(&(s->ltricep), lsumt);

	mypoints[0].x=s->rtricep.x;
	mypoints[0].y=s->rtricep.y;
	mypoints[1].x=s->rbicep.x;
	mypoints[1].y=s->rbicep.y;
	mypoints[2].x=xshoulder;
	mypoints[2].y=yshoulder;
	mypoints[3].x=s->lbicep.x;
	mypoints[3].y=s->lbicep.y;
	mypoints[4].x=s->ltricep.x;
	mypoints[4].y=s->ltricep.y;

	DrawLines(mypoints, 5, gc, where);

/*
** Get control points for legs
*/

	rsumt=s->torso.t;
	lsumt=s->torso.t;
	EndPoint(&(s->rthigh), rsumt);
	EndPoint(&(s->lthigh), lsumt);

	rsumt+=s->rthigh.t;
	lsumt+=s->lthigh.t;
	EndPoint(&(s->rshin), rsumt);
	EndPoint(&(s->lshin), lsumt);

	rsumt+=s->rshin.t;
	lsumt+=s->lshin.t;
	EndPoint(&(s->rfoot), rsumt);
	EndPoint(&(s->lfoot), lsumt);

	mypoints[0].x=s->rfoot.x;
	mypoints[0].y=s->rfoot.y;
	mypoints[1].x=s->rshin.x;
	mypoints[1].y=s->rshin.y;
	mypoints[2].x=s->rthigh.x;
	mypoints[2].y=s->rthigh.y;
	mypoints[3].x=xhip;
	mypoints[3].y=yhip;
	mypoints[4].x=s->lthigh.x;
	mypoints[4].y=s->lthigh.y;
	mypoints[5].x=s->lshin.x;
	mypoints[5].y=s->lshin.y;
	mypoints[6].x=s->lfoot.x;
	mypoints[6].y=s->lfoot.y;

	DrawLines(mypoints, 7, gc, where);
}

/*
** Given the endpoint of a line, the angle of the line, and a new r and
** angle, calculate the X and Y of the endpoint of the line from the
** endpoint at the given r and theta.
** EndPoint(targetX, targetY, currentX, currentY, currentT, targetR, targetT)
** int	*targetX, *targetY;
** int	currentX, currentY;
** double	currentT;
** int	targetR;
** double	targetT;
** {
***************************targetX = currentX + (int) (targetR * cos(targetT + currentT));
***************************targetY = currentY + (int) (targetR * sin(targetT + currentT));
** }
*/

/*
** Assuming that the target Ray's anchor has its endpoint set, and that
** the cumulative angle-so-far has been passed in as currentT, fill in
** the endpoints of the Ray.
*/
void EndPoint(RayPtr targetRay, double currentT)
{
	targetRay->x=
		targetRay->anchor->x+
		(int) (targetRay->r*cos(targetRay->t+currentT));
	targetRay->y=
		targetRay->anchor->y+
		(int) (targetRay->r*sin(targetRay->t+currentT));
}

/*
** Given a list of points, draw line segments between them.
*/

void DrawLines(XPoint* pointlist, int pointcount, GC gc, Window where)
{
	XDrawLines (dpy, where, gc, pointlist, pointcount, CoordModeOrigin);
}

void Initialize(int argc, char** argv)
{
	int count;
	XSizeHints size_hints;
	XSetWindowAttributes attributes;
	if (!(dpy=XOpenDisplay(""))) {
		printf ("Error: Can't open display.");
		exit(-1);
	}
	screen=DefaultScreen(dpy);

	attributes.backing_store=Always;
	attributes.background_pixel=WhitePixel(dpy, screen);
	attributes.border_pixel=BlackPixel(dpy, screen);

	size_hints.width=400;
	size_hints.height=400;
	size_hints.flags=PSize;

/*
 * win = XCreateWindow(
 * dpy, DefaultRootWindow(dpy),
 * 0,0,
 * size_hints.width,
 * size_hints.height,
 * 0,
 * CopyFromParent,
 * InputOutput,
 * CopyFromParent,
 * CWBackingStore | CWBackPixel | CWBorderPixel,
 * &attributes);
 */

	win=XCreateSimpleWindow(dpy,
		DefaultRootWindow(dpy),
		0, 0,
		size_hints.width,
		size_hints.height,
		4,
/*
 * BlackPixel(dpy, screen),
 * WhitePixel(dpy, screen));
 */
		WhitePixel(dpy, screen),
		BlackPixel(dpy, screen)),

	XSetStandardProperties (dpy, win, "application",
		"stickman",
		None, argv, argc, &size_hints);
	for (count=0; count < 2; count++) {
		buffer[count]=XCreateWindow(
			dpy, win,
			0, 0,
			size_hints.width,
			size_hints.height,
			0,
			CopyFromParent,
			InputOutput,
			CopyFromParent,
			CWBackingStore|CWBackPixel,
			&attributes);
		XMapWindow(dpy, buffer[count]);
	}
	XMapWindow(dpy, win);
	XRaiseWindow(dpy, win);
}
