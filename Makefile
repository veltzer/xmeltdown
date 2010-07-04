CFLAGS=-Wall -Werror -O3
RM=rm
CC=gcc
SYS_LIBRARIES=-lX11 -lm
DEST=/usr/bin

ALL:=bin/stickman bin/stickread bin/dance bin/xmeltdown

.PHONY: all
all: $(ALL) 

.PHONY: clean
clean:
	-$(RM) -f *.o $(ALL)

bin/stickman: skel.o draw.o
	$(CC) -o $@ skel.o draw.o $(SYS_LIBRARIES)

bin/stickread: stickread.o draw.o
	$(CC) -o $@ stickread.o draw.o $(SYS_LIBRARIES)

bin/dance: dance.o draw.o
	$(CC) -o $@ dance.o draw.o $(SYS_LIBRARIES)

bin/xmeltdown: xmeltdown.o
	$(CC) -o $@ xmeltdown.o $(SYS_LIBRARIES)

.PHONY: install
install:
	install $(ALL) $(DEST)

# dependency information (should be deduced automatically)
skel.o:	skel.c skel.h
draw.o:	draw.c skel.h
stickread.o: stickread.c skel.h
xmeltdown.o: xmeltdown.c skel.h
