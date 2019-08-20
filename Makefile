##############
# Parameters #
##############
# do you want to debug the makefile ?
DO_MKDBG:=0
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
# version of gcc
GCCVER:=$(shell gcc --version | head -1 | cut -f 4 -d " ")
# short version of GCC
GCCVER_SHORT:=$(shell echo $(GCCVER)| cut -b 1-3)

#########################
# Processing parameters #
#########################
SRC:=$(shell find . -name "*.c")
OBJ:=$(addprefix obj/,$(notdir $(addsuffix .o,$(basename $(SRC)))))
ALL:=tools.stamp $(BIN_FOLDER)/stickman $(BIN_FOLDER)/stickread $(BIN_FOLDER)/dance $(BIN_FOLDER)/xmeltdown $(BIN_FOLDER)/grid

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
	@true

tools.stamp: templardefs/deps.py
	$(info doing [$@])
	@templar install_deps
	@make_helper touch-mkdir $@

.PHONY: clean
clean: $(ALL_DEP)
	$(info doing [$@])
	$(Q)-rm -rf *.o $(BIN_FOLDER)

.PHONY: clean_git
clean_git: $(ALL_DEP)
	$(info doing [$@])
	$(Q)git clean -xdf > /dev/null

OBJ_GRID:=obj/grid.o
$(BIN_FOLDER)/grid: $(OBJ_GRID) $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) -o $@ $(OBJ_GRID) $(LDFLAGS)

OBJ_STICKMAN:=obj/stickman.o obj/draw.o
$(BIN_FOLDER)/stickman: $(OBJ_STICKMAN) $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) -o $@ $(OBJ_STICKMAN) $(LDFLAGS)

OBJ_STICKREAD:=obj/stickread.o obj/draw.o
$(BIN_FOLDER)/stickread: $(OBJ_STICKREAD) $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) -o $@ $(OBJ_STICKREAD) $(LDFLAGS)

OBJ_DANCE:=obj/dance.o obj/draw.o
$(BIN_FOLDER)/dance: $(OBJ_DANCE) $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) -o $@ $(OBJ_DANCE) $(LDFLAGS)

OBJ_XMELTDOWN:=obj/xmeltdown.o
$(BIN_FOLDER)/xmeltdown: $(OBJ_XMELTDOWN) $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) -o $@ $(OBJ_XMELTDOWN) $(LDFLAGS)

.PHONY: install
install: $(ALL_DEP)
	$(info doing [$@])
	$(Q)install $(ALL) $(DEST)

.PHONY: depend
depend: $(ALL_DEP)
	$(info doing [$@])
	$(Q)makedepend -I/usr/include/linux -I/usr/include/c++/$(GCCVER)/tr1 -I/usr/include/c++/$(GCCVER) -I/usr/include/x86_64-linux-gnu/c++/$(GCCVER_SHORT) -- $(CFLAGS) -- $(SRC)
	$(Q)rm -f Makefile.bak

.PHONY: debug
debug: $(ALL_DEP)
	$(info SRC is $(SRC))
	$(info OBJ is $(OBJ))
	$(info CC is $(CC))
	$(info ALL is $(ALL))
	$(info GCCVER is $(GCCVER))
	$(info GCCVER_SHORT is $(GCCVER_SHORT))

.PHONY: format_uncrustify
format_uncrustify: $(ALL_DEP)
	$(info doing [$@])
	$(Q)uncrustify -c support/uncrustify.cfg --no-backup -l C $(SRC)

#################
# Generic rules #
#################
$(OBJ): obj/%.o: src/%.c $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) $(CFLAGS) -c -o $@ $<

# DO NOT DELETE

./src/draw.o: /usr/include/math.h /usr/include/bits/libc-header-start.h
./src/draw.o: /usr/include/features.h /usr/include/stdc-predef.h
./src/draw.o: /usr/include/sys/cdefs.h /usr/include/bits/wordsize.h
./src/draw.o: /usr/include/bits/long-double.h /usr/include/gnu/stubs.h
./src/draw.o: /usr/include/bits/types.h /usr/include/bits/timesize.h
./src/draw.o: /usr/include/bits/typesizes.h /usr/include/bits/time64.h
./src/draw.o: /usr/include/bits/math-vector.h
./src/draw.o: /usr/include/bits/libm-simd-decl-stubs.h
./src/draw.o: /usr/include/bits/floatn.h /usr/include/bits/floatn-common.h
./src/draw.o: /usr/include/bits/flt-eval-method.h /usr/include/bits/fp-logb.h
./src/draw.o: /usr/include/bits/fp-fast.h
./src/draw.o: /usr/include/bits/mathcalls-helper-functions.h
./src/draw.o: /usr/include/bits/mathcalls.h
./src/draw.o: /usr/include/bits/mathcalls-narrow.h
./src/draw.o: /usr/include/bits/iscanonical.h /usr/include/stdio.h
./src/draw.o: /usr/include/linux/stddef.h /usr/include/bits/types/__fpos_t.h
./src/draw.o: /usr/include/bits/types/__mbstate_t.h
./src/draw.o: /usr/include/bits/types/__fpos64_t.h
./src/draw.o: /usr/include/bits/types/__FILE.h /usr/include/bits/types/FILE.h
./src/draw.o: /usr/include/bits/types/struct_FILE.h
./src/draw.o: /usr/include/bits/stdio_lim.h /usr/include/bits/sys_errlist.h
./src/draw.o: /usr/include/X11/Xlib.h /usr/include/sys/types.h
./src/draw.o: /usr/include/bits/types/clock_t.h
./src/draw.o: /usr/include/bits/types/clockid_t.h
./src/draw.o: /usr/include/bits/types/time_t.h
./src/draw.o: /usr/include/bits/types/timer_t.h
./src/draw.o: /usr/include/bits/stdint-intn.h /usr/include/endian.h
./src/draw.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
./src/draw.o: /usr/include/bits/uintn-identity.h /usr/include/sys/select.h
./src/draw.o: /usr/include/bits/select.h /usr/include/bits/types/sigset_t.h
./src/draw.o: /usr/include/bits/types/__sigset_t.h
./src/draw.o: /usr/include/bits/types/struct_timeval.h
./src/draw.o: /usr/include/bits/types/struct_timespec.h
./src/draw.o: /usr/include/bits/pthreadtypes.h
./src/draw.o: /usr/include/bits/thread-shared-types.h
./src/draw.o: /usr/include/bits/pthreadtypes-arch.h /usr/include/X11/X.h
./src/draw.o: /usr/include/X11/Xfuncproto.h /usr/include/X11/Xosdefs.h
./src/draw.o: /usr/include/X11/Xutil.h /usr/include/X11/keysym.h
./src/draw.o: /usr/include/X11/keysymdef.h /usr/include/stdlib.h
./src/draw.o: /usr/include/bits/waitflags.h /usr/include/bits/waitstatus.h
./src/draw.o: /usr/include/alloca.h /usr/include/bits/stdlib-float.h
./src/draw.o: ./src/stickman.h
./src/grid.o: /usr/include/stdio.h /usr/include/bits/libc-header-start.h
./src/grid.o: /usr/include/features.h /usr/include/stdc-predef.h
./src/grid.o: /usr/include/sys/cdefs.h /usr/include/bits/wordsize.h
./src/grid.o: /usr/include/bits/long-double.h /usr/include/gnu/stubs.h
./src/grid.o: /usr/include/linux/stddef.h /usr/include/bits/types.h
./src/grid.o: /usr/include/bits/timesize.h /usr/include/bits/typesizes.h
./src/grid.o: /usr/include/bits/time64.h /usr/include/bits/types/__fpos_t.h
./src/grid.o: /usr/include/bits/types/__mbstate_t.h
./src/grid.o: /usr/include/bits/types/__fpos64_t.h
./src/grid.o: /usr/include/bits/types/__FILE.h /usr/include/bits/types/FILE.h
./src/grid.o: /usr/include/bits/types/struct_FILE.h
./src/grid.o: /usr/include/bits/stdio_lim.h /usr/include/bits/sys_errlist.h
./src/grid.o: /usr/include/X11/Xlib.h /usr/include/sys/types.h
./src/grid.o: /usr/include/bits/types/clock_t.h
./src/grid.o: /usr/include/bits/types/clockid_t.h
./src/grid.o: /usr/include/bits/types/time_t.h
./src/grid.o: /usr/include/bits/types/timer_t.h
./src/grid.o: /usr/include/bits/stdint-intn.h /usr/include/endian.h
./src/grid.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
./src/grid.o: /usr/include/bits/uintn-identity.h /usr/include/sys/select.h
./src/grid.o: /usr/include/bits/select.h /usr/include/bits/types/sigset_t.h
./src/grid.o: /usr/include/bits/types/__sigset_t.h
./src/grid.o: /usr/include/bits/types/struct_timeval.h
./src/grid.o: /usr/include/bits/types/struct_timespec.h
./src/grid.o: /usr/include/bits/pthreadtypes.h
./src/grid.o: /usr/include/bits/thread-shared-types.h
./src/grid.o: /usr/include/bits/pthreadtypes-arch.h /usr/include/X11/X.h
./src/grid.o: /usr/include/X11/Xfuncproto.h /usr/include/X11/Xosdefs.h
./src/grid.o: /usr/include/X11/Xutil.h /usr/include/X11/keysym.h
./src/grid.o: /usr/include/X11/keysymdef.h /usr/include/stdlib.h
./src/grid.o: /usr/include/bits/waitflags.h /usr/include/bits/waitstatus.h
./src/grid.o: /usr/include/bits/floatn.h /usr/include/bits/floatn-common.h
./src/grid.o: /usr/include/alloca.h /usr/include/bits/stdlib-float.h
./src/stickman.o: /usr/include/math.h /usr/include/bits/libc-header-start.h
./src/stickman.o: /usr/include/features.h /usr/include/stdc-predef.h
./src/stickman.o: /usr/include/sys/cdefs.h /usr/include/bits/wordsize.h
./src/stickman.o: /usr/include/bits/long-double.h /usr/include/gnu/stubs.h
./src/stickman.o: /usr/include/bits/types.h /usr/include/bits/timesize.h
./src/stickman.o: /usr/include/bits/typesizes.h /usr/include/bits/time64.h
./src/stickman.o: /usr/include/bits/math-vector.h
./src/stickman.o: /usr/include/bits/libm-simd-decl-stubs.h
./src/stickman.o: /usr/include/bits/floatn.h
./src/stickman.o: /usr/include/bits/floatn-common.h
./src/stickman.o: /usr/include/bits/flt-eval-method.h
./src/stickman.o: /usr/include/bits/fp-logb.h /usr/include/bits/fp-fast.h
./src/stickman.o: /usr/include/bits/mathcalls-helper-functions.h
./src/stickman.o: /usr/include/bits/mathcalls.h
./src/stickman.o: /usr/include/bits/mathcalls-narrow.h
./src/stickman.o: /usr/include/bits/iscanonical.h /usr/include/stdio.h
./src/stickman.o: /usr/include/linux/stddef.h
./src/stickman.o: /usr/include/bits/types/__fpos_t.h
./src/stickman.o: /usr/include/bits/types/__mbstate_t.h
./src/stickman.o: /usr/include/bits/types/__fpos64_t.h
./src/stickman.o: /usr/include/bits/types/__FILE.h
./src/stickman.o: /usr/include/bits/types/FILE.h
./src/stickman.o: /usr/include/bits/types/struct_FILE.h
./src/stickman.o: /usr/include/bits/stdio_lim.h
./src/stickman.o: /usr/include/bits/sys_errlist.h /usr/include/stdlib.h
./src/stickman.o: /usr/include/bits/waitflags.h
./src/stickman.o: /usr/include/bits/waitstatus.h /usr/include/sys/types.h
./src/stickman.o: /usr/include/bits/types/clock_t.h
./src/stickman.o: /usr/include/bits/types/clockid_t.h
./src/stickman.o: /usr/include/bits/types/time_t.h
./src/stickman.o: /usr/include/bits/types/timer_t.h
./src/stickman.o: /usr/include/bits/stdint-intn.h /usr/include/endian.h
./src/stickman.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
./src/stickman.o: /usr/include/bits/uintn-identity.h
./src/stickman.o: /usr/include/sys/select.h /usr/include/bits/select.h
./src/stickman.o: /usr/include/bits/types/sigset_t.h
./src/stickman.o: /usr/include/bits/types/__sigset_t.h
./src/stickman.o: /usr/include/bits/types/struct_timeval.h
./src/stickman.o: /usr/include/bits/types/struct_timespec.h
./src/stickman.o: /usr/include/bits/pthreadtypes.h
./src/stickman.o: /usr/include/bits/thread-shared-types.h
./src/stickman.o: /usr/include/bits/pthreadtypes-arch.h /usr/include/alloca.h
./src/stickman.o: /usr/include/bits/stdlib-float.h /usr/include/X11/Xlib.h
./src/stickman.o: /usr/include/X11/X.h /usr/include/X11/Xfuncproto.h
./src/stickman.o: /usr/include/X11/Xosdefs.h /usr/include/X11/Xutil.h
./src/stickman.o: /usr/include/X11/keysym.h /usr/include/X11/keysymdef.h
./src/stickman.o: ./src/stickman.h
./src/xmeltdown.o: /usr/include/X11/Xlib.h /usr/include/sys/types.h
./src/xmeltdown.o: /usr/include/features.h /usr/include/stdc-predef.h
./src/xmeltdown.o: /usr/include/sys/cdefs.h /usr/include/bits/wordsize.h
./src/xmeltdown.o: /usr/include/bits/long-double.h /usr/include/gnu/stubs.h
./src/xmeltdown.o: /usr/include/bits/types.h /usr/include/bits/timesize.h
./src/xmeltdown.o: /usr/include/bits/typesizes.h /usr/include/bits/time64.h
./src/xmeltdown.o: /usr/include/bits/types/clock_t.h
./src/xmeltdown.o: /usr/include/bits/types/clockid_t.h
./src/xmeltdown.o: /usr/include/bits/types/time_t.h
./src/xmeltdown.o: /usr/include/bits/types/timer_t.h
./src/xmeltdown.o: /usr/include/linux/stddef.h
./src/xmeltdown.o: /usr/include/bits/stdint-intn.h /usr/include/endian.h
./src/xmeltdown.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
./src/xmeltdown.o: /usr/include/bits/uintn-identity.h
./src/xmeltdown.o: /usr/include/sys/select.h /usr/include/bits/select.h
./src/xmeltdown.o: /usr/include/bits/types/sigset_t.h
./src/xmeltdown.o: /usr/include/bits/types/__sigset_t.h
./src/xmeltdown.o: /usr/include/bits/types/struct_timeval.h
./src/xmeltdown.o: /usr/include/bits/types/struct_timespec.h
./src/xmeltdown.o: /usr/include/bits/pthreadtypes.h
./src/xmeltdown.o: /usr/include/bits/thread-shared-types.h
./src/xmeltdown.o: /usr/include/bits/pthreadtypes-arch.h /usr/include/X11/X.h
./src/xmeltdown.o: /usr/include/X11/Xfuncproto.h /usr/include/X11/Xosdefs.h
./src/xmeltdown.o: /usr/include/stdio.h /usr/include/bits/libc-header-start.h
./src/xmeltdown.o: /usr/include/bits/types/__fpos_t.h
./src/xmeltdown.o: /usr/include/bits/types/__mbstate_t.h
./src/xmeltdown.o: /usr/include/bits/types/__fpos64_t.h
./src/xmeltdown.o: /usr/include/bits/types/__FILE.h
./src/xmeltdown.o: /usr/include/bits/types/FILE.h
./src/xmeltdown.o: /usr/include/bits/types/struct_FILE.h
./src/xmeltdown.o: /usr/include/bits/stdio_lim.h
./src/xmeltdown.o: /usr/include/bits/sys_errlist.h /usr/include/stdlib.h
./src/xmeltdown.o: /usr/include/bits/waitflags.h
./src/xmeltdown.o: /usr/include/bits/waitstatus.h /usr/include/bits/floatn.h
./src/xmeltdown.o: /usr/include/bits/floatn-common.h /usr/include/alloca.h
./src/xmeltdown.o: /usr/include/bits/stdlib-float.h
./src/xmeltdown.o: /usr/include/linux/unistd.h /usr/include/asm/unistd.h
./src/xmeltdown.o: /usr/include/asm/unistd_64.h /usr/include/linux/string.h
./src/stickread.o: /usr/include/math.h /usr/include/bits/libc-header-start.h
./src/stickread.o: /usr/include/features.h /usr/include/stdc-predef.h
./src/stickread.o: /usr/include/sys/cdefs.h /usr/include/bits/wordsize.h
./src/stickread.o: /usr/include/bits/long-double.h /usr/include/gnu/stubs.h
./src/stickread.o: /usr/include/bits/types.h /usr/include/bits/timesize.h
./src/stickread.o: /usr/include/bits/typesizes.h /usr/include/bits/time64.h
./src/stickread.o: /usr/include/bits/math-vector.h
./src/stickread.o: /usr/include/bits/libm-simd-decl-stubs.h
./src/stickread.o: /usr/include/bits/floatn.h
./src/stickread.o: /usr/include/bits/floatn-common.h
./src/stickread.o: /usr/include/bits/flt-eval-method.h
./src/stickread.o: /usr/include/bits/fp-logb.h /usr/include/bits/fp-fast.h
./src/stickread.o: /usr/include/bits/mathcalls-helper-functions.h
./src/stickread.o: /usr/include/bits/mathcalls.h
./src/stickread.o: /usr/include/bits/mathcalls-narrow.h
./src/stickread.o: /usr/include/bits/iscanonical.h /usr/include/stdio.h
./src/stickread.o: /usr/include/linux/stddef.h
./src/stickread.o: /usr/include/bits/types/__fpos_t.h
./src/stickread.o: /usr/include/bits/types/__mbstate_t.h
./src/stickread.o: /usr/include/bits/types/__fpos64_t.h
./src/stickread.o: /usr/include/bits/types/__FILE.h
./src/stickread.o: /usr/include/bits/types/FILE.h
./src/stickread.o: /usr/include/bits/types/struct_FILE.h
./src/stickread.o: /usr/include/bits/stdio_lim.h
./src/stickread.o: /usr/include/bits/sys_errlist.h /usr/include/X11/Xlib.h
./src/stickread.o: /usr/include/sys/types.h /usr/include/bits/types/clock_t.h
./src/stickread.o: /usr/include/bits/types/clockid_t.h
./src/stickread.o: /usr/include/bits/types/time_t.h
./src/stickread.o: /usr/include/bits/types/timer_t.h
./src/stickread.o: /usr/include/bits/stdint-intn.h /usr/include/endian.h
./src/stickread.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
./src/stickread.o: /usr/include/bits/uintn-identity.h
./src/stickread.o: /usr/include/sys/select.h /usr/include/bits/select.h
./src/stickread.o: /usr/include/bits/types/sigset_t.h
./src/stickread.o: /usr/include/bits/types/__sigset_t.h
./src/stickread.o: /usr/include/bits/types/struct_timeval.h
./src/stickread.o: /usr/include/bits/types/struct_timespec.h
./src/stickread.o: /usr/include/bits/pthreadtypes.h
./src/stickread.o: /usr/include/bits/thread-shared-types.h
./src/stickread.o: /usr/include/bits/pthreadtypes-arch.h /usr/include/X11/X.h
./src/stickread.o: /usr/include/X11/Xfuncproto.h /usr/include/X11/Xosdefs.h
./src/stickread.o: /usr/include/X11/Xutil.h /usr/include/X11/keysym.h
./src/stickread.o: /usr/include/X11/keysymdef.h /usr/include/stdlib.h
./src/stickread.o: /usr/include/bits/waitflags.h
./src/stickread.o: /usr/include/bits/waitstatus.h /usr/include/alloca.h
./src/stickread.o: /usr/include/bits/stdlib-float.h ./src/stickman.h
./src/dance.o: /usr/include/math.h /usr/include/bits/libc-header-start.h
./src/dance.o: /usr/include/features.h /usr/include/stdc-predef.h
./src/dance.o: /usr/include/sys/cdefs.h /usr/include/bits/wordsize.h
./src/dance.o: /usr/include/bits/long-double.h /usr/include/gnu/stubs.h
./src/dance.o: /usr/include/bits/types.h /usr/include/bits/timesize.h
./src/dance.o: /usr/include/bits/typesizes.h /usr/include/bits/time64.h
./src/dance.o: /usr/include/bits/math-vector.h
./src/dance.o: /usr/include/bits/libm-simd-decl-stubs.h
./src/dance.o: /usr/include/bits/floatn.h /usr/include/bits/floatn-common.h
./src/dance.o: /usr/include/bits/flt-eval-method.h
./src/dance.o: /usr/include/bits/fp-logb.h /usr/include/bits/fp-fast.h
./src/dance.o: /usr/include/bits/mathcalls-helper-functions.h
./src/dance.o: /usr/include/bits/mathcalls.h
./src/dance.o: /usr/include/bits/mathcalls-narrow.h
./src/dance.o: /usr/include/bits/iscanonical.h /usr/include/stdio.h
./src/dance.o: /usr/include/linux/stddef.h /usr/include/bits/types/__fpos_t.h
./src/dance.o: /usr/include/bits/types/__mbstate_t.h
./src/dance.o: /usr/include/bits/types/__fpos64_t.h
./src/dance.o: /usr/include/bits/types/__FILE.h
./src/dance.o: /usr/include/bits/types/FILE.h
./src/dance.o: /usr/include/bits/types/struct_FILE.h
./src/dance.o: /usr/include/bits/stdio_lim.h /usr/include/bits/sys_errlist.h
./src/dance.o: /usr/include/stdlib.h /usr/include/bits/waitflags.h
./src/dance.o: /usr/include/bits/waitstatus.h /usr/include/sys/types.h
./src/dance.o: /usr/include/bits/types/clock_t.h
./src/dance.o: /usr/include/bits/types/clockid_t.h
./src/dance.o: /usr/include/bits/types/time_t.h
./src/dance.o: /usr/include/bits/types/timer_t.h
./src/dance.o: /usr/include/bits/stdint-intn.h /usr/include/endian.h
./src/dance.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
./src/dance.o: /usr/include/bits/uintn-identity.h /usr/include/sys/select.h
./src/dance.o: /usr/include/bits/select.h /usr/include/bits/types/sigset_t.h
./src/dance.o: /usr/include/bits/types/__sigset_t.h
./src/dance.o: /usr/include/bits/types/struct_timeval.h
./src/dance.o: /usr/include/bits/types/struct_timespec.h
./src/dance.o: /usr/include/bits/pthreadtypes.h
./src/dance.o: /usr/include/bits/thread-shared-types.h
./src/dance.o: /usr/include/bits/pthreadtypes-arch.h /usr/include/alloca.h
./src/dance.o: /usr/include/bits/stdlib-float.h /usr/include/X11/Xlib.h
./src/dance.o: /usr/include/X11/X.h /usr/include/X11/Xfuncproto.h
./src/dance.o: /usr/include/X11/Xosdefs.h /usr/include/X11/Xutil.h
./src/dance.o: /usr/include/X11/keysym.h /usr/include/X11/keysymdef.h
./src/dance.o: /usr/include/sys/time.h ./src/stickman.h
