CFLAGS=-Wall -Werror -O3
RM=rm
CC=gcc
SYS_LIBRARIES=-L/usr/X11R6/lib -lX11 -lm
DEST=/usr/X11R6/bin

all: stickman stickread dance xmeltdown

clean:
	-$(RM) -f *.o stickman stickread dance xmeltdown

stickman: skel.o draw.o
	$(CC) -o $@ skel.o draw.o $(SYS_LIBRARIES)

stickread: stickread.o draw.o
	$(CC) -o $@ stickread.o draw.o $(SYS_LIBRARIES)

dance: dance.o draw.o
	$(CC) -o $@ dance.o draw.o $(SYS_LIBRARIES)

xmeltdown: xmeltdown.o
	$(CC) -o $@ xmeltdown.o $(SYS_LIBRARIES)

skel.o:	skel.c skel.h
draw.o:	draw.c skel.h
stickread.o: stickread.c skel.h
xmeltdown.o: xmeltdown.c skel.h

install:
	install stickman stickread dance xmeltdown $(DEST)
