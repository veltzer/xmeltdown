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
	@templar_cmd install_deps
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

./src/draw.o: /usr/include/c++/6.2.0/tr1/math.h
./src/draw.o: /usr/include/c++/6.2.0/tr1/cmath
./src/draw.o: /usr/include/c++/6.2.0/tr1/cmath
./src/draw.o: /usr/include/c++/6.2.0/bits/stl_algobase.h
./src/draw.o: /usr/include/c++/6.2.0/bits/functexcept.h
./src/draw.o: /usr/include/c++/6.2.0/bits/exception_defines.h
./src/draw.o: /usr/include/c++/6.2.0/bits/cpp_type_traits.h
./src/draw.o: /usr/include/c++/6.2.0/ext/type_traits.h
./src/draw.o: /usr/include/c++/6.2.0/ext/numeric_traits.h
./src/draw.o: /usr/include/c++/6.2.0/bits/stl_pair.h
./src/draw.o: /usr/include/c++/6.2.0/bits/move.h
./src/draw.o: /usr/include/c++/6.2.0/bits/concept_check.h
./src/draw.o: /usr/include/c++/6.2.0/bits/stl_iterator_base_types.h
./src/draw.o: /usr/include/c++/6.2.0/bits/stl_iterator_base_funcs.h
./src/draw.o: /usr/include/c++/6.2.0/debug/assertions.h
./src/draw.o: /usr/include/c++/6.2.0/bits/stl_iterator.h
./src/draw.o: /usr/include/c++/6.2.0/bits/ptr_traits.h
./src/draw.o: /usr/include/c++/6.2.0/debug/debug.h
./src/draw.o: /usr/include/c++/6.2.0/bits/predefined_ops.h
./src/draw.o: /usr/include/c++/6.2.0/limits
./src/draw.o: /usr/include/c++/6.2.0/tr1/type_traits
./src/draw.o: /usr/include/c++/6.2.0/tr1/gamma.tcc
./src/draw.o: /usr/include/c++/6.2.0/tr1/special_function_util.h
./src/draw.o: /usr/include/c++/6.2.0/tr1/bessel_function.tcc
./src/draw.o: /usr/include/c++/6.2.0/tr1/special_function_util.h
./src/draw.o: /usr/include/c++/6.2.0/tr1/beta_function.tcc
./src/draw.o: /usr/include/c++/6.2.0/tr1/ell_integral.tcc
./src/draw.o: /usr/include/c++/6.2.0/tr1/exp_integral.tcc
./src/draw.o: /usr/include/c++/6.2.0/tr1/hypergeometric.tcc
./src/draw.o: /usr/include/c++/6.2.0/tr1/legendre_function.tcc
./src/draw.o: /usr/include/c++/6.2.0/tr1/modified_bessel_func.tcc
./src/draw.o: /usr/include/c++/6.2.0/tr1/poly_hermite.tcc
./src/draw.o: /usr/include/c++/6.2.0/tr1/poly_laguerre.tcc
./src/draw.o: /usr/include/c++/6.2.0/tr1/riemann_zeta.tcc
./src/draw.o: /usr/include/c++/6.2.0/tr1/stdio.h
./src/draw.o: /usr/include/c++/6.2.0/tr1/cstdio
./src/draw.o: /usr/include/c++/6.2.0/tr1/cstdio /usr/include/X11/Xlib.h
./src/draw.o: /usr/include/sys/types.h /usr/include/features.h
./src/draw.o: /usr/include/stdc-predef.h /usr/include/sys/cdefs.h
./src/draw.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
./src/draw.o: /usr/include/bits/types.h /usr/include/bits/typesizes.h
./src/draw.o: /usr/include/linux/time.h /usr/include/linux/types.h
./src/draw.o: /usr/include/asm/types.h /usr/include/asm-generic/types.h
./src/draw.o: /usr/include/asm-generic/int-ll64.h
./src/draw.o: /usr/include/asm/bitsperlong.h
./src/draw.o: /usr/include/asm-generic/bitsperlong.h
./src/draw.o: /usr/include/linux/posix_types.h /usr/include/linux/stddef.h
./src/draw.o: /usr/include/asm/posix_types.h
./src/draw.o: /usr/include/asm/posix_types_64.h
./src/draw.o: /usr/include/asm-generic/posix_types.h
./src/draw.o: /usr/include/linux/stddef.h /usr/include/endian.h
./src/draw.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
./src/draw.o: /usr/include/bits/byteswap-16.h /usr/include/sys/select.h
./src/draw.o: /usr/include/bits/select.h /usr/include/bits/sigset.h
./src/draw.o: /usr/include/bits/time.h /usr/include/sys/sysmacros.h
./src/draw.o: /usr/include/bits/pthreadtypes.h /usr/include/X11/X.h
./src/draw.o: /usr/include/X11/Xfuncproto.h /usr/include/X11/Xosdefs.h
./src/draw.o: /usr/include/X11/Xutil.h /usr/include/X11/keysym.h
./src/draw.o: /usr/include/X11/keysymdef.h
./src/draw.o: /usr/include/c++/6.2.0/tr1/stdlib.h
./src/draw.o: /usr/include/c++/6.2.0/tr1/cstdlib
./src/draw.o: /usr/include/c++/6.2.0/tr1/cstdlib ./src/stickman.h
./src/grid.o: /usr/include/c++/6.2.0/tr1/stdio.h
./src/grid.o: /usr/include/c++/6.2.0/tr1/cstdio
./src/grid.o: /usr/include/c++/6.2.0/tr1/cstdio /usr/include/X11/Xlib.h
./src/grid.o: /usr/include/sys/types.h /usr/include/features.h
./src/grid.o: /usr/include/stdc-predef.h /usr/include/sys/cdefs.h
./src/grid.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
./src/grid.o: /usr/include/bits/types.h /usr/include/bits/typesizes.h
./src/grid.o: /usr/include/linux/time.h /usr/include/linux/types.h
./src/grid.o: /usr/include/asm/types.h /usr/include/asm-generic/types.h
./src/grid.o: /usr/include/asm-generic/int-ll64.h
./src/grid.o: /usr/include/asm/bitsperlong.h
./src/grid.o: /usr/include/asm-generic/bitsperlong.h
./src/grid.o: /usr/include/linux/posix_types.h /usr/include/linux/stddef.h
./src/grid.o: /usr/include/asm/posix_types.h
./src/grid.o: /usr/include/asm/posix_types_64.h
./src/grid.o: /usr/include/asm-generic/posix_types.h
./src/grid.o: /usr/include/linux/stddef.h /usr/include/endian.h
./src/grid.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
./src/grid.o: /usr/include/bits/byteswap-16.h /usr/include/sys/select.h
./src/grid.o: /usr/include/bits/select.h /usr/include/bits/sigset.h
./src/grid.o: /usr/include/bits/time.h /usr/include/sys/sysmacros.h
./src/grid.o: /usr/include/bits/pthreadtypes.h /usr/include/X11/X.h
./src/grid.o: /usr/include/X11/Xfuncproto.h /usr/include/X11/Xosdefs.h
./src/grid.o: /usr/include/X11/Xutil.h /usr/include/X11/keysym.h
./src/grid.o: /usr/include/X11/keysymdef.h
./src/grid.o: /usr/include/c++/6.2.0/tr1/stdlib.h
./src/grid.o: /usr/include/c++/6.2.0/tr1/cstdlib
./src/grid.o: /usr/include/c++/6.2.0/tr1/cstdlib
./src/stickman.o: /usr/include/c++/6.2.0/tr1/math.h
./src/stickman.o: /usr/include/c++/6.2.0/tr1/cmath
./src/stickman.o: /usr/include/c++/6.2.0/tr1/cmath
./src/stickman.o: /usr/include/c++/6.2.0/bits/stl_algobase.h
./src/stickman.o: /usr/include/c++/6.2.0/bits/functexcept.h
./src/stickman.o: /usr/include/c++/6.2.0/bits/exception_defines.h
./src/stickman.o: /usr/include/c++/6.2.0/bits/cpp_type_traits.h
./src/stickman.o: /usr/include/c++/6.2.0/ext/type_traits.h
./src/stickman.o: /usr/include/c++/6.2.0/ext/numeric_traits.h
./src/stickman.o: /usr/include/c++/6.2.0/bits/stl_pair.h
./src/stickman.o: /usr/include/c++/6.2.0/bits/move.h
./src/stickman.o: /usr/include/c++/6.2.0/bits/concept_check.h
./src/stickman.o: /usr/include/c++/6.2.0/bits/stl_iterator_base_types.h
./src/stickman.o: /usr/include/c++/6.2.0/bits/stl_iterator_base_funcs.h
./src/stickman.o: /usr/include/c++/6.2.0/debug/assertions.h
./src/stickman.o: /usr/include/c++/6.2.0/bits/stl_iterator.h
./src/stickman.o: /usr/include/c++/6.2.0/bits/ptr_traits.h
./src/stickman.o: /usr/include/c++/6.2.0/debug/debug.h
./src/stickman.o: /usr/include/c++/6.2.0/bits/predefined_ops.h
./src/stickman.o: /usr/include/c++/6.2.0/limits
./src/stickman.o: /usr/include/c++/6.2.0/tr1/type_traits
./src/stickman.o: /usr/include/c++/6.2.0/tr1/gamma.tcc
./src/stickman.o: /usr/include/c++/6.2.0/tr1/special_function_util.h
./src/stickman.o: /usr/include/c++/6.2.0/tr1/bessel_function.tcc
./src/stickman.o: /usr/include/c++/6.2.0/tr1/special_function_util.h
./src/stickman.o: /usr/include/c++/6.2.0/tr1/beta_function.tcc
./src/stickman.o: /usr/include/c++/6.2.0/tr1/ell_integral.tcc
./src/stickman.o: /usr/include/c++/6.2.0/tr1/exp_integral.tcc
./src/stickman.o: /usr/include/c++/6.2.0/tr1/hypergeometric.tcc
./src/stickman.o: /usr/include/c++/6.2.0/tr1/legendre_function.tcc
./src/stickman.o: /usr/include/c++/6.2.0/tr1/modified_bessel_func.tcc
./src/stickman.o: /usr/include/c++/6.2.0/tr1/poly_hermite.tcc
./src/stickman.o: /usr/include/c++/6.2.0/tr1/poly_laguerre.tcc
./src/stickman.o: /usr/include/c++/6.2.0/tr1/riemann_zeta.tcc
./src/stickman.o: /usr/include/c++/6.2.0/tr1/stdio.h
./src/stickman.o: /usr/include/c++/6.2.0/tr1/cstdio
./src/stickman.o: /usr/include/c++/6.2.0/tr1/cstdio
./src/stickman.o: /usr/include/c++/6.2.0/tr1/stdlib.h
./src/stickman.o: /usr/include/c++/6.2.0/tr1/cstdlib
./src/stickman.o: /usr/include/c++/6.2.0/tr1/cstdlib /usr/include/X11/Xlib.h
./src/stickman.o: /usr/include/sys/types.h /usr/include/features.h
./src/stickman.o: /usr/include/stdc-predef.h /usr/include/sys/cdefs.h
./src/stickman.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
./src/stickman.o: /usr/include/bits/types.h /usr/include/bits/typesizes.h
./src/stickman.o: /usr/include/linux/time.h /usr/include/linux/types.h
./src/stickman.o: /usr/include/asm/types.h /usr/include/asm-generic/types.h
./src/stickman.o: /usr/include/asm-generic/int-ll64.h
./src/stickman.o: /usr/include/asm/bitsperlong.h
./src/stickman.o: /usr/include/asm-generic/bitsperlong.h
./src/stickman.o: /usr/include/linux/posix_types.h
./src/stickman.o: /usr/include/linux/stddef.h /usr/include/asm/posix_types.h
./src/stickman.o: /usr/include/asm/posix_types_64.h
./src/stickman.o: /usr/include/asm-generic/posix_types.h
./src/stickman.o: /usr/include/linux/stddef.h /usr/include/endian.h
./src/stickman.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
./src/stickman.o: /usr/include/bits/byteswap-16.h /usr/include/sys/select.h
./src/stickman.o: /usr/include/bits/select.h /usr/include/bits/sigset.h
./src/stickman.o: /usr/include/bits/time.h /usr/include/sys/sysmacros.h
./src/stickman.o: /usr/include/bits/pthreadtypes.h /usr/include/X11/X.h
./src/stickman.o: /usr/include/X11/Xfuncproto.h /usr/include/X11/Xosdefs.h
./src/stickman.o: /usr/include/X11/Xutil.h /usr/include/X11/keysym.h
./src/stickman.o: /usr/include/X11/keysymdef.h ./src/stickman.h
./src/xmeltdown.o: /usr/include/X11/Xlib.h /usr/include/sys/types.h
./src/xmeltdown.o: /usr/include/features.h /usr/include/stdc-predef.h
./src/xmeltdown.o: /usr/include/sys/cdefs.h /usr/include/bits/wordsize.h
./src/xmeltdown.o: /usr/include/gnu/stubs.h /usr/include/bits/types.h
./src/xmeltdown.o: /usr/include/bits/typesizes.h /usr/include/linux/time.h
./src/xmeltdown.o: /usr/include/linux/types.h /usr/include/asm/types.h
./src/xmeltdown.o: /usr/include/asm-generic/types.h
./src/xmeltdown.o: /usr/include/asm-generic/int-ll64.h
./src/xmeltdown.o: /usr/include/asm/bitsperlong.h
./src/xmeltdown.o: /usr/include/asm-generic/bitsperlong.h
./src/xmeltdown.o: /usr/include/linux/posix_types.h
./src/xmeltdown.o: /usr/include/linux/stddef.h /usr/include/asm/posix_types.h
./src/xmeltdown.o: /usr/include/asm/posix_types_64.h
./src/xmeltdown.o: /usr/include/asm-generic/posix_types.h
./src/xmeltdown.o: /usr/include/linux/stddef.h /usr/include/endian.h
./src/xmeltdown.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
./src/xmeltdown.o: /usr/include/bits/byteswap-16.h /usr/include/sys/select.h
./src/xmeltdown.o: /usr/include/bits/select.h /usr/include/bits/sigset.h
./src/xmeltdown.o: /usr/include/bits/time.h /usr/include/sys/sysmacros.h
./src/xmeltdown.o: /usr/include/bits/pthreadtypes.h /usr/include/X11/X.h
./src/xmeltdown.o: /usr/include/X11/Xfuncproto.h /usr/include/X11/Xosdefs.h
./src/xmeltdown.o: /usr/include/c++/6.2.0/tr1/stdio.h
./src/xmeltdown.o: /usr/include/c++/6.2.0/tr1/cstdio
./src/xmeltdown.o: /usr/include/c++/6.2.0/tr1/cstdio
./src/xmeltdown.o: /usr/include/c++/6.2.0/tr1/stdlib.h
./src/xmeltdown.o: /usr/include/c++/6.2.0/tr1/cstdlib
./src/xmeltdown.o: /usr/include/c++/6.2.0/tr1/cstdlib
./src/xmeltdown.o: /usr/include/linux/unistd.h /usr/include/asm/unistd.h
./src/xmeltdown.o: /usr/include/asm/unistd_64.h /usr/include/linux/string.h
./src/stickread.o: /usr/include/c++/6.2.0/tr1/math.h
./src/stickread.o: /usr/include/c++/6.2.0/tr1/cmath
./src/stickread.o: /usr/include/c++/6.2.0/tr1/cmath
./src/stickread.o: /usr/include/c++/6.2.0/bits/stl_algobase.h
./src/stickread.o: /usr/include/c++/6.2.0/bits/functexcept.h
./src/stickread.o: /usr/include/c++/6.2.0/bits/exception_defines.h
./src/stickread.o: /usr/include/c++/6.2.0/bits/cpp_type_traits.h
./src/stickread.o: /usr/include/c++/6.2.0/ext/type_traits.h
./src/stickread.o: /usr/include/c++/6.2.0/ext/numeric_traits.h
./src/stickread.o: /usr/include/c++/6.2.0/bits/stl_pair.h
./src/stickread.o: /usr/include/c++/6.2.0/bits/move.h
./src/stickread.o: /usr/include/c++/6.2.0/bits/concept_check.h
./src/stickread.o: /usr/include/c++/6.2.0/bits/stl_iterator_base_types.h
./src/stickread.o: /usr/include/c++/6.2.0/bits/stl_iterator_base_funcs.h
./src/stickread.o: /usr/include/c++/6.2.0/debug/assertions.h
./src/stickread.o: /usr/include/c++/6.2.0/bits/stl_iterator.h
./src/stickread.o: /usr/include/c++/6.2.0/bits/ptr_traits.h
./src/stickread.o: /usr/include/c++/6.2.0/debug/debug.h
./src/stickread.o: /usr/include/c++/6.2.0/bits/predefined_ops.h
./src/stickread.o: /usr/include/c++/6.2.0/limits
./src/stickread.o: /usr/include/c++/6.2.0/tr1/type_traits
./src/stickread.o: /usr/include/c++/6.2.0/tr1/gamma.tcc
./src/stickread.o: /usr/include/c++/6.2.0/tr1/special_function_util.h
./src/stickread.o: /usr/include/c++/6.2.0/tr1/bessel_function.tcc
./src/stickread.o: /usr/include/c++/6.2.0/tr1/special_function_util.h
./src/stickread.o: /usr/include/c++/6.2.0/tr1/beta_function.tcc
./src/stickread.o: /usr/include/c++/6.2.0/tr1/ell_integral.tcc
./src/stickread.o: /usr/include/c++/6.2.0/tr1/exp_integral.tcc
./src/stickread.o: /usr/include/c++/6.2.0/tr1/hypergeometric.tcc
./src/stickread.o: /usr/include/c++/6.2.0/tr1/legendre_function.tcc
./src/stickread.o: /usr/include/c++/6.2.0/tr1/modified_bessel_func.tcc
./src/stickread.o: /usr/include/c++/6.2.0/tr1/poly_hermite.tcc
./src/stickread.o: /usr/include/c++/6.2.0/tr1/poly_laguerre.tcc
./src/stickread.o: /usr/include/c++/6.2.0/tr1/riemann_zeta.tcc
./src/stickread.o: /usr/include/c++/6.2.0/tr1/stdio.h
./src/stickread.o: /usr/include/c++/6.2.0/tr1/cstdio
./src/stickread.o: /usr/include/c++/6.2.0/tr1/cstdio /usr/include/X11/Xlib.h
./src/stickread.o: /usr/include/sys/types.h /usr/include/features.h
./src/stickread.o: /usr/include/stdc-predef.h /usr/include/sys/cdefs.h
./src/stickread.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
./src/stickread.o: /usr/include/bits/types.h /usr/include/bits/typesizes.h
./src/stickread.o: /usr/include/linux/time.h /usr/include/linux/types.h
./src/stickread.o: /usr/include/asm/types.h /usr/include/asm-generic/types.h
./src/stickread.o: /usr/include/asm-generic/int-ll64.h
./src/stickread.o: /usr/include/asm/bitsperlong.h
./src/stickread.o: /usr/include/asm-generic/bitsperlong.h
./src/stickread.o: /usr/include/linux/posix_types.h
./src/stickread.o: /usr/include/linux/stddef.h /usr/include/asm/posix_types.h
./src/stickread.o: /usr/include/asm/posix_types_64.h
./src/stickread.o: /usr/include/asm-generic/posix_types.h
./src/stickread.o: /usr/include/linux/stddef.h /usr/include/endian.h
./src/stickread.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
./src/stickread.o: /usr/include/bits/byteswap-16.h /usr/include/sys/select.h
./src/stickread.o: /usr/include/bits/select.h /usr/include/bits/sigset.h
./src/stickread.o: /usr/include/bits/time.h /usr/include/sys/sysmacros.h
./src/stickread.o: /usr/include/bits/pthreadtypes.h /usr/include/X11/X.h
./src/stickread.o: /usr/include/X11/Xfuncproto.h /usr/include/X11/Xosdefs.h
./src/stickread.o: /usr/include/X11/Xutil.h /usr/include/X11/keysym.h
./src/stickread.o: /usr/include/X11/keysymdef.h
./src/stickread.o: /usr/include/c++/6.2.0/tr1/stdlib.h
./src/stickread.o: /usr/include/c++/6.2.0/tr1/cstdlib
./src/stickread.o: /usr/include/c++/6.2.0/tr1/cstdlib ./src/stickman.h
./src/dance.o: /usr/include/c++/6.2.0/tr1/math.h
./src/dance.o: /usr/include/c++/6.2.0/tr1/cmath
./src/dance.o: /usr/include/c++/6.2.0/tr1/cmath
./src/dance.o: /usr/include/c++/6.2.0/bits/stl_algobase.h
./src/dance.o: /usr/include/c++/6.2.0/bits/functexcept.h
./src/dance.o: /usr/include/c++/6.2.0/bits/exception_defines.h
./src/dance.o: /usr/include/c++/6.2.0/bits/cpp_type_traits.h
./src/dance.o: /usr/include/c++/6.2.0/ext/type_traits.h
./src/dance.o: /usr/include/c++/6.2.0/ext/numeric_traits.h
./src/dance.o: /usr/include/c++/6.2.0/bits/stl_pair.h
./src/dance.o: /usr/include/c++/6.2.0/bits/move.h
./src/dance.o: /usr/include/c++/6.2.0/bits/concept_check.h
./src/dance.o: /usr/include/c++/6.2.0/bits/stl_iterator_base_types.h
./src/dance.o: /usr/include/c++/6.2.0/bits/stl_iterator_base_funcs.h
./src/dance.o: /usr/include/c++/6.2.0/debug/assertions.h
./src/dance.o: /usr/include/c++/6.2.0/bits/stl_iterator.h
./src/dance.o: /usr/include/c++/6.2.0/bits/ptr_traits.h
./src/dance.o: /usr/include/c++/6.2.0/debug/debug.h
./src/dance.o: /usr/include/c++/6.2.0/bits/predefined_ops.h
./src/dance.o: /usr/include/c++/6.2.0/limits
./src/dance.o: /usr/include/c++/6.2.0/tr1/type_traits
./src/dance.o: /usr/include/c++/6.2.0/tr1/gamma.tcc
./src/dance.o: /usr/include/c++/6.2.0/tr1/special_function_util.h
./src/dance.o: /usr/include/c++/6.2.0/tr1/bessel_function.tcc
./src/dance.o: /usr/include/c++/6.2.0/tr1/special_function_util.h
./src/dance.o: /usr/include/c++/6.2.0/tr1/beta_function.tcc
./src/dance.o: /usr/include/c++/6.2.0/tr1/ell_integral.tcc
./src/dance.o: /usr/include/c++/6.2.0/tr1/exp_integral.tcc
./src/dance.o: /usr/include/c++/6.2.0/tr1/hypergeometric.tcc
./src/dance.o: /usr/include/c++/6.2.0/tr1/legendre_function.tcc
./src/dance.o: /usr/include/c++/6.2.0/tr1/modified_bessel_func.tcc
./src/dance.o: /usr/include/c++/6.2.0/tr1/poly_hermite.tcc
./src/dance.o: /usr/include/c++/6.2.0/tr1/poly_laguerre.tcc
./src/dance.o: /usr/include/c++/6.2.0/tr1/riemann_zeta.tcc
./src/dance.o: /usr/include/c++/6.2.0/tr1/stdio.h
./src/dance.o: /usr/include/c++/6.2.0/tr1/cstdio
./src/dance.o: /usr/include/c++/6.2.0/tr1/cstdio
./src/dance.o: /usr/include/c++/6.2.0/tr1/stdlib.h
./src/dance.o: /usr/include/c++/6.2.0/tr1/cstdlib
./src/dance.o: /usr/include/c++/6.2.0/tr1/cstdlib /usr/include/X11/Xlib.h
./src/dance.o: /usr/include/sys/types.h /usr/include/features.h
./src/dance.o: /usr/include/stdc-predef.h /usr/include/sys/cdefs.h
./src/dance.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
./src/dance.o: /usr/include/bits/types.h /usr/include/bits/typesizes.h
./src/dance.o: /usr/include/linux/time.h /usr/include/linux/types.h
./src/dance.o: /usr/include/asm/types.h /usr/include/asm-generic/types.h
./src/dance.o: /usr/include/asm-generic/int-ll64.h
./src/dance.o: /usr/include/asm/bitsperlong.h
./src/dance.o: /usr/include/asm-generic/bitsperlong.h
./src/dance.o: /usr/include/linux/posix_types.h /usr/include/linux/stddef.h
./src/dance.o: /usr/include/asm/posix_types.h
./src/dance.o: /usr/include/asm/posix_types_64.h
./src/dance.o: /usr/include/asm-generic/posix_types.h
./src/dance.o: /usr/include/linux/stddef.h /usr/include/endian.h
./src/dance.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
./src/dance.o: /usr/include/bits/byteswap-16.h /usr/include/sys/select.h
./src/dance.o: /usr/include/bits/select.h /usr/include/bits/sigset.h
./src/dance.o: /usr/include/bits/time.h /usr/include/sys/sysmacros.h
./src/dance.o: /usr/include/bits/pthreadtypes.h /usr/include/X11/X.h
./src/dance.o: /usr/include/X11/Xfuncproto.h /usr/include/X11/Xosdefs.h
./src/dance.o: /usr/include/X11/Xutil.h /usr/include/X11/keysym.h
./src/dance.o: /usr/include/X11/keysymdef.h /usr/include/sys/time.h
./src/dance.o: ./src/stickman.h
