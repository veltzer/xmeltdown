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
OBJ:=$(addsuffix .o,$(basename $(SRC)))
ALL:=$(BIN_FOLDER)/stickman $(BIN_FOLDER)/stickread $(BIN_FOLDER)/dance $(BIN_FOLDER)/xmeltdown $(BIN_FOLDER)/grid

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

.PHONY: clean
clean: $(ALL_DEP)
	$(info doing [$@])
	$(Q)-rm -rf *.o $(BIN_FOLDER)

.PHONY: clean_git
clean_git: $(ALL_DEP)
	$(info doing [$@])
	$(Q)git clean -xdf > /dev/null

$(BIN_FOLDER)/grid: grid.o $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) -o $@ grid.o $(LDFLAGS)

$(BIN_FOLDER)/stickman: stickman.o draw.o $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) -o $@ stickman.o draw.o $(LDFLAGS)

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
$(OBJ): %.o: %.c $(ALL_DEP)
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CC) $(CFLAGS) -c -o $@ $<

# DO NOT DELETE

./grid.o: /usr/include/c++/5.4.0/tr1/stdio.h
./grid.o: /usr/include/c++/5.4.0/tr1/cstdio /usr/include/c++/5.4.0/tr1/cstdio
./grid.o: /usr/include/c++/5.4.0/tr1/stdlib.h
./grid.o: /usr/include/c++/5.4.0/tr1/cstdlib
./grid.o: /usr/include/c++/5.4.0/tr1/cstdlib
./stickread.o: /usr/include/c++/5.4.0/tr1/math.h
./stickread.o: /usr/include/c++/5.4.0/tr1/cmath
./stickread.o: /usr/include/c++/5.4.0/tr1/cmath
./stickread.o: /usr/include/c++/5.4.0/bits/stl_algobase.h
./stickread.o: /usr/include/c++/5.4.0/bits/functexcept.h
./stickread.o: /usr/include/c++/5.4.0/bits/exception_defines.h
./stickread.o: /usr/include/c++/5.4.0/bits/cpp_type_traits.h
./stickread.o: /usr/include/c++/5.4.0/ext/type_traits.h
./stickread.o: /usr/include/c++/5.4.0/ext/numeric_traits.h
./stickread.o: /usr/include/c++/5.4.0/bits/stl_pair.h
./stickread.o: /usr/include/c++/5.4.0/bits/move.h
./stickread.o: /usr/include/c++/5.4.0/bits/concept_check.h
./stickread.o: /usr/include/c++/5.4.0/bits/stl_iterator_base_types.h
./stickread.o: /usr/include/c++/5.4.0/bits/stl_iterator_base_funcs.h
./stickread.o: /usr/include/c++/5.4.0/debug/debug.h
./stickread.o: /usr/include/c++/5.4.0/bits/stl_iterator.h
./stickread.o: /usr/include/c++/5.4.0/bits/ptr_traits.h
./stickread.o: /usr/include/c++/5.4.0/bits/predefined_ops.h
./stickread.o: /usr/include/c++/5.4.0/limits
./stickread.o: /usr/include/c++/5.4.0/tr1/type_traits
./stickread.o: /usr/include/c++/5.4.0/tr1/gamma.tcc
./stickread.o: /usr/include/c++/5.4.0/tr1/special_function_util.h
./stickread.o: /usr/include/c++/5.4.0/tr1/bessel_function.tcc
./stickread.o: /usr/include/c++/5.4.0/tr1/beta_function.tcc
./stickread.o: /usr/include/c++/5.4.0/tr1/ell_integral.tcc
./stickread.o: /usr/include/c++/5.4.0/tr1/exp_integral.tcc
./stickread.o: /usr/include/c++/5.4.0/tr1/hypergeometric.tcc
./stickread.o: /usr/include/c++/5.4.0/tr1/legendre_function.tcc
./stickread.o: /usr/include/c++/5.4.0/tr1/modified_bessel_func.tcc
./stickread.o: /usr/include/c++/5.4.0/tr1/poly_hermite.tcc
./stickread.o: /usr/include/c++/5.4.0/tr1/poly_laguerre.tcc
./stickread.o: /usr/include/c++/5.4.0/tr1/riemann_zeta.tcc
./stickread.o: /usr/include/c++/5.4.0/tr1/stdio.h
./stickread.o: /usr/include/c++/5.4.0/tr1/cstdio
./stickread.o: /usr/include/c++/5.4.0/tr1/cstdio
./stickread.o: /usr/include/c++/5.4.0/tr1/stdlib.h
./stickread.o: /usr/include/c++/5.4.0/tr1/cstdlib
./stickread.o: /usr/include/c++/5.4.0/tr1/cstdlib stickman.h
./dance.o: /usr/include/c++/5.4.0/tr1/math.h /usr/include/c++/5.4.0/tr1/cmath
./dance.o: /usr/include/c++/5.4.0/tr1/cmath
./dance.o: /usr/include/c++/5.4.0/bits/stl_algobase.h
./dance.o: /usr/include/c++/5.4.0/bits/functexcept.h
./dance.o: /usr/include/c++/5.4.0/bits/exception_defines.h
./dance.o: /usr/include/c++/5.4.0/bits/cpp_type_traits.h
./dance.o: /usr/include/c++/5.4.0/ext/type_traits.h
./dance.o: /usr/include/c++/5.4.0/ext/numeric_traits.h
./dance.o: /usr/include/c++/5.4.0/bits/stl_pair.h
./dance.o: /usr/include/c++/5.4.0/bits/move.h
./dance.o: /usr/include/c++/5.4.0/bits/concept_check.h
./dance.o: /usr/include/c++/5.4.0/bits/stl_iterator_base_types.h
./dance.o: /usr/include/c++/5.4.0/bits/stl_iterator_base_funcs.h
./dance.o: /usr/include/c++/5.4.0/debug/debug.h
./dance.o: /usr/include/c++/5.4.0/bits/stl_iterator.h
./dance.o: /usr/include/c++/5.4.0/bits/ptr_traits.h
./dance.o: /usr/include/c++/5.4.0/bits/predefined_ops.h
./dance.o: /usr/include/c++/5.4.0/limits
./dance.o: /usr/include/c++/5.4.0/tr1/type_traits
./dance.o: /usr/include/c++/5.4.0/tr1/gamma.tcc
./dance.o: /usr/include/c++/5.4.0/tr1/special_function_util.h
./dance.o: /usr/include/c++/5.4.0/tr1/bessel_function.tcc
./dance.o: /usr/include/c++/5.4.0/tr1/beta_function.tcc
./dance.o: /usr/include/c++/5.4.0/tr1/ell_integral.tcc
./dance.o: /usr/include/c++/5.4.0/tr1/exp_integral.tcc
./dance.o: /usr/include/c++/5.4.0/tr1/hypergeometric.tcc
./dance.o: /usr/include/c++/5.4.0/tr1/legendre_function.tcc
./dance.o: /usr/include/c++/5.4.0/tr1/modified_bessel_func.tcc
./dance.o: /usr/include/c++/5.4.0/tr1/poly_hermite.tcc
./dance.o: /usr/include/c++/5.4.0/tr1/poly_laguerre.tcc
./dance.o: /usr/include/c++/5.4.0/tr1/riemann_zeta.tcc
./dance.o: /usr/include/c++/5.4.0/tr1/stdio.h
./dance.o: /usr/include/c++/5.4.0/tr1/cstdio
./dance.o: /usr/include/c++/5.4.0/tr1/cstdio
./dance.o: /usr/include/c++/5.4.0/tr1/stdlib.h
./dance.o: /usr/include/c++/5.4.0/tr1/cstdlib
./dance.o: /usr/include/c++/5.4.0/tr1/cstdlib stickman.h
./xmeltdown.o: /usr/include/c++/5.4.0/tr1/stdio.h
./xmeltdown.o: /usr/include/c++/5.4.0/tr1/cstdio
./xmeltdown.o: /usr/include/c++/5.4.0/tr1/cstdio
./xmeltdown.o: /usr/include/c++/5.4.0/tr1/stdlib.h
./xmeltdown.o: /usr/include/c++/5.4.0/tr1/cstdlib
./xmeltdown.o: /usr/include/c++/5.4.0/tr1/cstdlib /usr/include/linux/unistd.h
./xmeltdown.o: /usr/include/linux/string.h
./draw.o: /usr/include/c++/5.4.0/tr1/math.h /usr/include/c++/5.4.0/tr1/cmath
./draw.o: /usr/include/c++/5.4.0/tr1/cmath
./draw.o: /usr/include/c++/5.4.0/bits/stl_algobase.h
./draw.o: /usr/include/c++/5.4.0/bits/functexcept.h
./draw.o: /usr/include/c++/5.4.0/bits/exception_defines.h
./draw.o: /usr/include/c++/5.4.0/bits/cpp_type_traits.h
./draw.o: /usr/include/c++/5.4.0/ext/type_traits.h
./draw.o: /usr/include/c++/5.4.0/ext/numeric_traits.h
./draw.o: /usr/include/c++/5.4.0/bits/stl_pair.h
./draw.o: /usr/include/c++/5.4.0/bits/move.h
./draw.o: /usr/include/c++/5.4.0/bits/concept_check.h
./draw.o: /usr/include/c++/5.4.0/bits/stl_iterator_base_types.h
./draw.o: /usr/include/c++/5.4.0/bits/stl_iterator_base_funcs.h
./draw.o: /usr/include/c++/5.4.0/debug/debug.h
./draw.o: /usr/include/c++/5.4.0/bits/stl_iterator.h
./draw.o: /usr/include/c++/5.4.0/bits/ptr_traits.h
./draw.o: /usr/include/c++/5.4.0/bits/predefined_ops.h
./draw.o: /usr/include/c++/5.4.0/limits
./draw.o: /usr/include/c++/5.4.0/tr1/type_traits
./draw.o: /usr/include/c++/5.4.0/tr1/gamma.tcc
./draw.o: /usr/include/c++/5.4.0/tr1/special_function_util.h
./draw.o: /usr/include/c++/5.4.0/tr1/bessel_function.tcc
./draw.o: /usr/include/c++/5.4.0/tr1/beta_function.tcc
./draw.o: /usr/include/c++/5.4.0/tr1/ell_integral.tcc
./draw.o: /usr/include/c++/5.4.0/tr1/exp_integral.tcc
./draw.o: /usr/include/c++/5.4.0/tr1/hypergeometric.tcc
./draw.o: /usr/include/c++/5.4.0/tr1/legendre_function.tcc
./draw.o: /usr/include/c++/5.4.0/tr1/modified_bessel_func.tcc
./draw.o: /usr/include/c++/5.4.0/tr1/poly_hermite.tcc
./draw.o: /usr/include/c++/5.4.0/tr1/poly_laguerre.tcc
./draw.o: /usr/include/c++/5.4.0/tr1/riemann_zeta.tcc
./draw.o: /usr/include/c++/5.4.0/tr1/stdio.h
./draw.o: /usr/include/c++/5.4.0/tr1/cstdio /usr/include/c++/5.4.0/tr1/cstdio
./draw.o: /usr/include/c++/5.4.0/tr1/stdlib.h
./draw.o: /usr/include/c++/5.4.0/tr1/cstdlib
./draw.o: /usr/include/c++/5.4.0/tr1/cstdlib stickman.h
./stickman.o: /usr/include/c++/5.4.0/tr1/math.h
./stickman.o: /usr/include/c++/5.4.0/tr1/cmath
./stickman.o: /usr/include/c++/5.4.0/tr1/cmath
./stickman.o: /usr/include/c++/5.4.0/bits/stl_algobase.h
./stickman.o: /usr/include/c++/5.4.0/bits/functexcept.h
./stickman.o: /usr/include/c++/5.4.0/bits/exception_defines.h
./stickman.o: /usr/include/c++/5.4.0/bits/cpp_type_traits.h
./stickman.o: /usr/include/c++/5.4.0/ext/type_traits.h
./stickman.o: /usr/include/c++/5.4.0/ext/numeric_traits.h
./stickman.o: /usr/include/c++/5.4.0/bits/stl_pair.h
./stickman.o: /usr/include/c++/5.4.0/bits/move.h
./stickman.o: /usr/include/c++/5.4.0/bits/concept_check.h
./stickman.o: /usr/include/c++/5.4.0/bits/stl_iterator_base_types.h
./stickman.o: /usr/include/c++/5.4.0/bits/stl_iterator_base_funcs.h
./stickman.o: /usr/include/c++/5.4.0/debug/debug.h
./stickman.o: /usr/include/c++/5.4.0/bits/stl_iterator.h
./stickman.o: /usr/include/c++/5.4.0/bits/ptr_traits.h
./stickman.o: /usr/include/c++/5.4.0/bits/predefined_ops.h
./stickman.o: /usr/include/c++/5.4.0/limits
./stickman.o: /usr/include/c++/5.4.0/tr1/type_traits
./stickman.o: /usr/include/c++/5.4.0/tr1/gamma.tcc
./stickman.o: /usr/include/c++/5.4.0/tr1/special_function_util.h
./stickman.o: /usr/include/c++/5.4.0/tr1/bessel_function.tcc
./stickman.o: /usr/include/c++/5.4.0/tr1/beta_function.tcc
./stickman.o: /usr/include/c++/5.4.0/tr1/ell_integral.tcc
./stickman.o: /usr/include/c++/5.4.0/tr1/exp_integral.tcc
./stickman.o: /usr/include/c++/5.4.0/tr1/hypergeometric.tcc
./stickman.o: /usr/include/c++/5.4.0/tr1/legendre_function.tcc
./stickman.o: /usr/include/c++/5.4.0/tr1/modified_bessel_func.tcc
./stickman.o: /usr/include/c++/5.4.0/tr1/poly_hermite.tcc
./stickman.o: /usr/include/c++/5.4.0/tr1/poly_laguerre.tcc
./stickman.o: /usr/include/c++/5.4.0/tr1/riemann_zeta.tcc
./stickman.o: /usr/include/c++/5.4.0/tr1/stdio.h
./stickman.o: /usr/include/c++/5.4.0/tr1/cstdio
./stickman.o: /usr/include/c++/5.4.0/tr1/cstdio
./stickman.o: /usr/include/c++/5.4.0/tr1/stdlib.h
./stickman.o: /usr/include/c++/5.4.0/tr1/cstdlib
./stickman.o: /usr/include/c++/5.4.0/tr1/cstdlib stickman.h
