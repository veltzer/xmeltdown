#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <sys/types.h>
#include <sys/time.h>

#include "skel.h"

#define PLAYERS 3
#define OFFSET 100
#define LINE_WIDTH 0	/* single pixel */

void Initialize(int argc, char** argv);
void DanceMainLoop(int* routine);
void ClearFrame();
void DrawTween(double factor, int which, int curbuf);
void ShowFrame(int curbuf);
void clock_usleep (unsigned long usecs);
void HandleKeyPress(XKeyEvent* pevent);
void RandomMove();
void DrawSkel(SkeletonPtr s, GC gc, Window where);
int Fill(FILE* filep, RayPtr rayp);
Skeleton**ReadFile(char* filename);
int*ReadRoutineFile(char* filename);

extern Display* dpy;
extern Window win;
extern Window buffer[2];
Skeleton tween[PLAYERS];
int waistx;
int waisty;
GC set_gc, noop_gc, unset_gc, neg_gc;
Skeleton** skellist;
int numread;
int steps;

SkeletonPtr fromskel[PLAYERS], toskel[PLAYERS], tweenskel[PLAYERS];

int main(int argc, char** argv)
{
	char* posefile;
	char* routinefile;
	XGCValues my_gcvalues;
	int i;
	int* routine=NULL;
	if (argc < 2) {
		printf ("Usage: %s posefile [framecount [routinefile]\n", argv[0]);
		exit (1);
	}
	posefile=argv[1];
	if (argc >= 3)
		steps=atoi(argv[2]);
	else
		steps=10;
	if (argc == 4)
		routinefile=argv[3];
	else
		routinefile=NULL;
	for (i=0; i < PLAYERS; i++)
		tweenskel[i]=&tween[i];
	Initialize(argc, argv);
	XSelectInput(dpy, win,
		ExposureMask|ButtonPressMask|KeyPressMask);
	my_gcvalues.line_width=LINE_WIDTH;
	my_gcvalues.line_style=LineSolid;

#ifdef NOCOLOR
	my_gcvalues.function=GXset;
#else
	my_gcvalues.function=GXclear;
#endif

	set_gc=XCreateGC(dpy, win,
		GCFunction|GCLineWidth|GCLineStyle,
		&my_gcvalues);

	my_gcvalues.line_width=LINE_WIDTH;
	my_gcvalues.line_style=LineSolid;

#ifdef NOCOLOR
	my_gcvalues.function=GXclear;
#else
	my_gcvalues.function=GXset;
#endif

	unset_gc=XCreateGC(dpy, win,
		GCFunction|GCLineWidth|GCLineStyle,
		&my_gcvalues);

	my_gcvalues.line_width=LINE_WIDTH;
	my_gcvalues.line_style=LineSolid;
	my_gcvalues.function=GXnoop;

	noop_gc=XCreateGC(dpy, win,
		GCFunction|GCLineWidth|GCLineStyle,
		&my_gcvalues);

	my_gcvalues.line_width=LINE_WIDTH;
	my_gcvalues.line_style=LineSolid;
	my_gcvalues.function=GXinvert;

	neg_gc=XCreateGC(dpy, win,
		GCFunction|GCLineWidth|GCLineStyle,
		&my_gcvalues);

	skellist=ReadFile(posefile);
	if (routinefile)
		routine=ReadRoutineFile(routinefile);
	DanceMainLoop(routine);
	return(0);
}

void DanceMainLoop(int* routine)
{
	double factor;
	XEvent my_event;
	int stepctr, i;
	int curbuf=0;
	int newpose;
	int* routine1=routine;
	if (!routine)
		for (i=0; i < PLAYERS; i++) {
			fromskel[i]=skellist[0];
			toskel[i]=skellist[0];
		}
	else
		for (i=0; i < PLAYERS; i++) {
			fromskel[i]=skellist[*routine];
			toskel[i]=skellist[*routine];
		}
	while (1) {
		for (stepctr=1; stepctr <= steps; stepctr++) {
			factor=(double) (steps-stepctr)/(double) steps;
			ClearFrame();
			for (i=0; i < PLAYERS; i++)
				DrawTween(factor, i, curbuf);
			ShowFrame(curbuf);

			curbuf=!curbuf;

			clock_usleep(30000L);
			if (XPending(dpy) && XCheckMaskEvent(dpy, KeyPressMask, &my_event)) {
				HandleKeyPress((XKeyEvent*)&my_event);
				stepctr=0;
			}
		}
#ifdef CHECK_EACH_MOVE
		XNextEvent (dpy, &my_event);
		if (my_event.type == KeyPress)
			HandleKeyPress((XKeyEvent*)&my_event);
#endif
		if (!routine)
			RandomMove();
		else {
			newpose=*(++routine1);
			if (newpose == -1) {
				routine1=routine;
				newpose=*(++routine1);
			}
			for (i=0; i < PLAYERS; i++) {
				fromskel[i]=tweenskel[0];
				toskel[i]=skellist[newpose];
			}
		}
	}
}

void RandomMove()
{
	int i;
	int randnum;
	static int lastnum=999;
	do {
		randnum=rand()%numread;
	} while (randnum == lastnum);
	lastnum=randnum;
	for (i=0; i < PLAYERS; i++) {
		fromskel[i]=tweenskel[0];
		toskel[i]=skellist[randnum];
	}
}

void HandleKeyPress(XKeyEvent* pevent)
{
	char charback;
	/* int	i; */

	XLookupString(pevent, &charback, 1, NULL, NULL);
	if (charback == 'q')
		exit(0);
	if (charback == '+') {
		steps++;
		printf ("Dancing at speed %d\n", steps);
	}
	if (charback == '-') {
		steps--;
		printf ("Dancing at speed %d\n", steps);
	}
	if (charback >= '1' && charback <= '9') {
		steps=(int) (charback-'1')+1;
		printf ("Dancing at speed %d\n", steps);
	}
}

void DrawTween(double factor, int which, int curbuf)
/* what fraction the movement is completed
 * which player
 * which buffer not to draw into */
{
	RayPtr toray, fromray, tweenray;
	int bonesize=sizeof(Ray);
	int bone;
/*	int		stepctr, skelctr; */
	/* static int	lastbuf = 0; */
/*	int		flag1 = 1;
 * int		flag2 = 1;
 * int		flag3 = 1;
 * int		flag4 = 0; */
	for (bone=0; bone < 11; bone++) {
		fromray=(RayPtr) ((long) &(fromskel[which]->torso)+(long) (bone*bonesize));
		toray=(RayPtr) ((long) &(toskel[which]->torso)+(long) (bone*bonesize));
		tweenray=(RayPtr) ((long) &(tweenskel[which]->torso)+(long) (bone*bonesize));
/*
** Never rotate through an angle > PI. I.e., take the shortest path.
*/
		if ((fromray->t-toray->t) > M_PI)
			toray->t+=2*M_PI;
		else if ((toray->t-fromray->t) > M_PI)
			fromray->t+=2*M_PI;
		tweenray->t=(fromray->t*factor+toray->t*(1.0-factor));
		tweenray->r=(fromray->r*factor+toray->r*(1.0-factor));
	}
	tweenskel[which]->headradius=fromskel[which]->headradius*factor+toskel[which]->headradius*(1.0-factor);
	tweenskel[which]->waistx=fromskel[which]->waistx*factor+toskel[which]->waistx*(1.0-factor);
	tweenskel[which]->waisty=fromskel[which]->waisty*factor+toskel[which]->waisty*(1.0-factor);

	tweenskel[which]->waistx=OFFSET+(which*OFFSET);

	DrawSkel(tweenskel[which], unset_gc, buffer[!curbuf]);
}

static int curbuf;
void ClearFrame() {
	XClearWindow(dpy, buffer[!curbuf]);
}

void ShowFrame(int curbuf)
{
	XMapWindow(dpy, buffer[!curbuf]);
	XUnmapWindow(dpy, buffer[curbuf]);
}

/*
** return list of integers corresponding to poses to strike, in order
*/

int*ReadRoutineFile(char* filename)
{
	FILE* infile;
	int okayflag=1;
	int* retval;
	int numread=0;

	infile=fopen(filename, "r");
	if (infile == NULL) {
		fprintf(stderr, "Cannot open file %s\n", filename);
		exit(1);
	}
	retval=(int *) calloc (1, sizeof (int));
	numread=0;
	while (okayflag >= 0) {
		okayflag=fscanf(infile, "%d\n", &(retval[numread]));
		if (okayflag >= 0) {
			numread++;
			retval=(int *) realloc (retval, (numread+1)*sizeof (int));
		}
	}
	retval[numread]=-1;
	return (retval);
}

Skeleton**ReadFile(char* filename)
{
	FILE* infile;
	Skeleton** retval;
	int okayflag=1, tempradius;
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
	numread=1;
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

			retval[numread-1]=(Skeleton *) calloc (1, sizeof (Skeleton));

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

void clock_usleep (unsigned long usecs)
{
	struct timeval tv;
	tv.tv_sec=usecs/1000000L;
	tv.tv_usec=usecs%1000000L;
	(void) select (0, 0, 0, 0, &tv);
}
