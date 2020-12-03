# cpp-init

*One Makefile to rule them all*

[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)

This repository contains a generic Makefile and other files for building and
managing C++ projects.

## Installation

First download this repository using git:  
```bash
git clone https://github.com/avdstaaij/cpp-init
```

Then use the provided script `cpp-init/newproject` to initialize a new project.
Alternatively, you can manually copy only the files you need to an existing
project:
```bash
cp -i cpp-init/Makefile /path/to/your/project/Makefile
cp -i cpp-init/gitignore /path/to/your/project/.gitignore
```

## Usage

With the Makefile in place, you can build your project using
[GNU Make](https://www.gnu.org/software/make/):
```bash
make
```

Build settings can be configured by editing the Makefile. Instructions for this
are included at the top of the Makefile. The Makefile contains various special
targets, such as `run`, `clean` and `debug`. These are described in detail at
the top of the Makefile as well.

## Makefile features

The Makefile has the following features:
 - **Building with one command.**
   Using `make` builds the entire C++ project at once, even if it is split up
   into many source and header files. You can also use `make run` to build and
   run in one go.
 - **Customizable build settings.**
   Almost all build settings, such as compiler flags and project directories,
   can be easily configured using variables at the top of the Makefile.
 - **Object file caching.**
   Generated object files are stored to reduce recompilation time.
 - **Automatic dependency detection.**
   Code dependencies (`#include`) are automatically detected using compiler
   tools and are stored in dependency files. This is done as a side-effect of
   compilation for maximum efficiency. On recompilation, these files are used to
   compile those and only those files that are affected by the changes.
   Combined with the object file caching, this minimizes recompilation time.
   The dependency generation is fully automated, so there is no need to manually
   specify dependencies.
 - **Source file trees.**
   Source files can be organized with subdirectories, and the Makefile will
   handle them just as well.
 - **Separate release and debug builds.**
   The Makefile has a system to separately build release and debug binaries,
   using different compiler flags for each.
 - **Project cleaning.**
   The Makefile has rules to clean generated files from your project. You can
   choose whether you want to keep the final binary or not. The cleaning rules
   actually clean everything: they won't leave any annoying empty directories.
 - **Library building support.**
   By adjusting certain setting variables, the Makefile can easily be configured
   to build static or dynamic libraries instead of executables.
 
The top of the makefile contains instructions that explain how to use the
various features.

## License

This project is released into the public domain.
See LICENSE.txt for details.
