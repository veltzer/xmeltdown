#!/usr/bin/env python

""" Build the five X11 demos, reproducing the Makefile: compile each src/*.c to
out/obj/<name>.o, then link the per-binary object groups (draw.o is shared by
stickman, stickread and dance) with -lX11 -lm. File arguments are ignored -- the
object groups below define the build. """

import os
import subprocess
import sys

CC = "gcc"
CFLAGS = ["-Wall", "-Werror", "-O3"]
LDFLAGS = ["-lX11", "-lm"]
OBJ_FOLDER = os.path.join("out", "obj")
BIN_FOLDER = os.path.join("out", "bin")

# binary name -> object stems it links
BINARIES = {
    "grid": ["grid"],
    "stickman": ["stickman", "draw"],
    "stickread": ["stickread", "draw"],
    "dance": ["dance", "draw"],
    "xmeltdown": ["xmeltdown"],
}


def run(cmd):
    """ Run a command, exiting the process on the first failure. """
    ret = subprocess.call(cmd)
    if ret != 0:
        sys.exit(ret)


def compile_objects(stems):
    """ Compile each unique source stem to an object file. """
    os.makedirs(OBJ_FOLDER, exist_ok=True)
    for stem in stems:
        obj = os.path.join(OBJ_FOLDER, stem + ".o")
        run([CC] + CFLAGS + ["-c", "-o", obj, os.path.join("src", stem + ".c")])


def main():
    """ main entry point """
    stems = sorted({stem for group in BINARIES.values() for stem in group})
    compile_objects(stems)
    os.makedirs(BIN_FOLDER, exist_ok=True)
    for name, group in BINARIES.items():
        objs = [os.path.join(OBJ_FOLDER, stem + ".o") for stem in group]
        run([CC, "-o", os.path.join(BIN_FOLDER, name)] + objs + LDFLAGS)


if __name__ == "__main__":
    main()
