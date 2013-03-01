##############
# Parameters #
##############
# do you want to debug the makefile ?
DO_MKDBG?=0
# do you want dependency on the Makefile itself ?
DO_ALLDEP:=1
# flags for compilation
CFLAGS:=-Wall -Werror -O3
# libraries to link with
LDFLAGS:=-lX11 -lm
# where to install ?
DEST:=/usr/local/bin
# where to put binaries ?
BIN_FOLDER:=bin

#########################
# Processing parameters #
#########################
SRC:=$(shell find . -name "*.c")
OBJ:=$(addsuffix .o,$(basename $(SRC)))
ALL:=$(BIN_FOLDER)/stickman $(BIN_FOLDER)/stickread $(BIN_FOLDER)/dance $(BIN_FOLDER)/xmeltdown

# dependency on the makefile itself
ifeq ($(DO_ALLDEP),1)
ALL_DEP:=Makefile
else
ALL_DEP:=
endif

# silent stuff
ifeq ($(DO_MKDBG),1)
Q:=
# we are not silent in this branch
else # DO_MKDBG
Q:=@
#.SILENT:
endif # DO_MKDBG

#########
# Rules #
#########
.PHONY: all
all: $(ALL) $(ALL_DEP)
	$(info doing [$@])

.PHONY: clean
clean: $(ALL_DEP)
	$(info doing [$@])
	$(Q)-rm -rf *.o $(BIN_FOLDER)

$(BIN_FOLDER)/stickman: skel.o draw.o $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) -o $@ skel.o draw.o $(LDFLAGS)

$(BIN_FOLDER)/stickread: stickread.o draw.o $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) -o $@ stickread.o draw.o $(LDFLAGS)

$(BIN_FOLDER)/dance: dance.o draw.o $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) -o $@ dance.o draw.o $(LDFLAGS)

$(BIN_FOLDER)/xmeltdown: xmeltdown.o $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) -o $@ xmeltdown.o $(LDFLAGS)

.PHONY: install
install: $(ALL_DEP)
	$(info doing [$@])
	$(Q)install $(ALL) $(DEST)

.PHONY: depend
depend: $(ALL_DEP)
	$(info doing [$@])
	$(Q)makedepend -Y -- $(CFLAGS) -- $(SRC) 2> /dev/null
	$(Q)rm -f Makefile.bak

.PHONY: debug
debug: $(ALL_DEP)
	$(info SRC is $(SRC))
	$(info OBJ is $(OBJ))
	$(info CC is $(CC))
	$(info ALL is $(ALL))

.PHONY: format_uncrustify
format_uncrustify: $(ALL_DEP)
	$(info doing [$@])
	$(Q)uncrustify -c support/uncrustify.cfg --no-backup -l C $(SRC)

#################
# Generic rules #
#################
$(OBJ): %.o: %.c $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) $(CFLAGS) -c -o $@ $<

# DO NOT DELETE

./dance.o: skel.h
./skel.o: skel.h
./stickread.o: skel.h
./draw.o: skel.h
