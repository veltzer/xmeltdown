/*
 * Bug fixes and forward port to Linux,gcc-3.2 by Mark Veltzer <mark@veltzer.org>
 */
typedef struct ray{
	int		r;		/* How long this Ray is */
	double		t;		/* at what angle (polar) from anchor */
	int		x, y;		/* endpoint */
	struct ray	*anchor;	/* the Ray this comes out from */
} Ray, *RayPtr;

typedef struct {
	int	headradius, waistx, waisty;

	Ray	torso;
	Ray	rthigh;
	Ray	rshin;
	Ray	rfoot;
	Ray	rbicep;
	Ray	rtricep;

	Ray	lthigh;
	Ray	lshin;
	Ray	lfoot;
	Ray	lbicep;
	Ray	ltricep;
} Skeleton, *SkeletonPtr;
