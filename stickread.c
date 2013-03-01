#include <math.h>
#include <stdio.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <stdlib.h>
#include "skel.h"
/*
 * Bug fixes and forward port to Linux,gcc-3.2 by Mark Veltzer <mark@veltzer.org>
 */

void Initialize(int argc, char** argv);
void HandleKeyPress(XKeyEvent* pevent);
void Interpolate(Skeleton** skellist, int steps);
int Fill(FILE* filep, RayPtr rayp);
void DrawSkel(SkeletonPtr s, GC gc, Window where);

extern Display* dpy;
extern Window win;
extern Window buffer[2];
Skeleton**ReadFile();
int waistx;
int waisty;
GC set_gc, noop_gc, unset_gc, neg_gc;

int main(int argc, char** argv)
{
	Skeleton** skellist;
	char* inputfile;
	int framecount;
	XGCValues my_gcvalues;
	XEvent my_event;
	if (argc < 2) {
		printf ("Usage: %s filename [framecount]\n", argv[0]);
		exit (1);
	}
	inputfile=argv[1];
	if (argc == 3)
		framecount=atoi(argv[2]);
	else
		framecount=10;
	Initialize(argc, argv);
	XSelectInput(dpy, win,
		ExposureMask|ButtonPressMask|KeyPressMask);
	my_gcvalues.line_width=3;
	my_gcvalues.line_style=LineSolid;
	my_gcvalues.function=GXset;

	set_gc=XCreateGC(dpy, win,
		GCFunction|GCLineWidth|GCLineStyle,
		&my_gcvalues);

	my_gcvalues.line_width=3;
	my_gcvalues.line_style=LineSolid;
	my_gcvalues.function=GXclear;

	unset_gc=XCreateGC(dpy, win,
		GCFunction|GCLineWidth|GCLineStyle,
		&my_gcvalues);

	my_gcvalues.line_width=3;
	my_gcvalues.line_style=LineSolid;
	my_gcvalues.function=GXnoop;

	noop_gc=XCreateGC(dpy, win,
		GCFunction|GCLineWidth|GCLineStyle,
		&my_gcvalues);

	my_gcvalues.line_width=3;
	my_gcvalues.line_style=LineSolid;
	my_gcvalues.function=GXinvert;

	neg_gc=XCreateGC(dpy, win,
		GCFunction|GCLineWidth|GCLineStyle,
		&my_gcvalues);

	skellist=ReadFile(inputfile);
	while (1) {
		XNextEvent (dpy, &my_event);
		if (my_event.type == KeyPress)
			HandleKeyPress((XKeyEvent*)&my_event);
		if (my_event.type == ButtonPress) {
			Interpolate(skellist, framecount);
			printf ("Beep.");
		}else if (my_event.type == Expose)
			Interpolate(skellist, framecount);
	}
}
void HandleKeyPress(XKeyEvent* pevent)
{
	if (pevent->keycode == 'q') ;
	exit(0);
}

void Interpolate(Skeleton** skellist, int steps)
{
	RayPtr to, from, tweenray;
	int bonesize=sizeof(Ray);
	Skeleton* skel1, *skel2;
	int stepctr, skelctr, bone;
	Skeleton tween1;
	// Skeleton	tween2;
	double factor;
	// Skeleton	*oldskel;
	Skeleton* newskel=NULL;
	/* Skeleton *tempskel; */
	int curbuf=0;
	int flag1=1;
	int flag2=1;
	int flag3=1;
	int flag4=0;

	newskel=&tween1;
	// oldskel = &tween2;
	for (skelctr=0; skellist[skelctr+1] != NULL; skelctr++) {
		skel1=skellist[skelctr];
		skel2=skellist[skelctr+1];

		tween1.headradius=skel1->headradius;
		// tween2.headradius = skel2->headradius;
		for (stepctr=0; stepctr < steps; stepctr++) {
			factor=(double) (steps-stepctr)/(double) steps;
			for (bone=0; bone < 11; bone++) {
				from=(RayPtr)((int) &(skel1->torso)+(int) (bone*bonesize));
				to=(RayPtr) ((int) &(skel2->torso)+(int) (bone*bonesize));
				tweenray=(RayPtr) ((int) &(newskel->torso)+(int) (bone*bonesize));
/*
** Never rotate through an angle > PI. I.e., take the shortest path.
*/
				if ((from->t-to->t) > M_PI)
					to->t+=2*M_PI;
				else if ((to->t-from->t) > M_PI)
					from->t+=2*M_PI;
				tweenray->t=(from->t*factor+to->t*(1.0-factor));
				tweenray->r=(from->r*factor+to->r*(1.0-factor));
			}
			newskel->waistx=skel1->waistx*factor+
					 skel2->waistx*(1.0-factor);
			newskel->waisty=skel1->waisty*factor+
					 skel2->waisty*(1.0-factor);
/*
** Real double-buffering...clear the hidden window, draw the skeleton
** in it, bring it to the top.
*/
			if (flag1 == 1) XClearWindow(dpy, buffer[!curbuf]);
			if (!flag2 && flag4) XRaiseWindow(dpy, buffer[!curbuf]);
			if (!flag2 && !flag4) {
				XMapWindow(dpy, buffer[!curbuf]);
				XUnmapWindow(dpy, buffer[curbuf]);
			}
			DrawSkel(newskel, unset_gc, buffer[!curbuf]);
			if (flag2 && flag4) XRaiseWindow(dpy, buffer[!curbuf]);
			if (flag2 && !flag4) {
				XMapWindow(dpy, buffer[!curbuf]);
				XUnmapWindow(dpy, buffer[curbuf]);
			}
			if (flag3) curbuf=!curbuf;
/*
 * Simulated double-buffering: Keep track of previous skeleton, and undraw
 * it just before drawing the new one.
 *
 * DrawSkel(newskel, neg_gc);
 *
 * if (oldskel != NULL)
 * DrawSkel(oldskel, neg_gc);
 *
 * DrawSkel(newskel, unset_gc);
 *
 * tempskel = oldskel;
 * oldskel = newskel;
 * newskel = tempskel;
 */
		}
	}
}

Skeleton**ReadFile(char* filename)
{
	FILE* infile;
	Skeleton** retval;
	int numread=1, okayflag=1, tempradius;
	Skeleton* current;

	infile=fopen(filename, "r");
	if (infile == NULL) {
		fprintf(stderr, "Cannot open file %s\n", filename);
		exit(1);
	}
	retval=(Skeleton **) calloc (2, sizeof (Skeleton *));
	retval[0]=(Skeleton *) calloc (1, sizeof (Skeleton));
	retval[1]=NULL;
	current=retval[0];
	okayflag=fscanf(infile, "%d, %d, %d\n", &tempradius, &waistx, &waisty);
	while (okayflag >= 0) {
		current->headradius=tempradius;
		current->waistx=waistx;
		current->waisty=waisty;

		Fill (infile, &(current->torso));
		Fill (infile, &(current->rthigh));
		Fill (infile, &(current->rshin));
		Fill (infile, &(current->rfoot));
		Fill (infile, &(current->rbicep));
		Fill (infile, &(current->rtricep));
		Fill (infile, &(current->lthigh));
		Fill (infile, &(current->lshin));
		Fill (infile, &(current->lfoot));
		Fill (infile, &(current->lbicep));
		Fill (infile, &(current->ltricep));

		printf ("Read %d skeleton%s\n",
			numread, numread == 1 ? "." : "s.");
		okayflag=fscanf(infile, "%d, %d, %d\n", &tempradius, &waistx, &waisty);
		if (okayflag >= 0) {
			numread++;
			retval=(Skeleton **)
				realloc (
				retval, (numread+1)*sizeof (Skeleton *));

			retval[numread-1]=(Skeleton *)calloc (1, sizeof (Skeleton));

			retval[numread]=0;
			current=retval[numread-1];
		}else
			printf ("Nothing else to read\n");
	}
	return (retval);
}

int Fill(FILE* filep, RayPtr rayp)
{
	int inputthingie1;
	float inputthingie2;
	int i=fscanf(filep, "{%d, %f}\n", &inputthingie1, &inputthingie2);
	rayp->r=inputthingie1;
	rayp->t=(double) inputthingie2;
	return i;
}
