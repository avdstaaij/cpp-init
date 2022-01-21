# Generic C/C++ Makefile
# Made by Arthur van der Staaij and Aron de Jong

# To download the latest version, report issues or request new features, visit
# https://github.com/avdstaaij/cpp-init

#==============================================================================#
#----------------------------- Usage instructions -----------------------------#
#==============================================================================#

# Besides actual build targets, the following rules are provided:
# all:      Build the release binary (with FLAGS_R)
# release:  Build the release binary (with FLAGS_R)
# debug:    Build the debug binary (with FLAGS_D)
# run:      Build the release binary and run it
# rrun:     Build the release binary and run it
# drun:     Build the debug binary and run it
# c:        Clean all build byproducts
# clean:    Clean all build byproducts and the binaries

# To use "run" and "drun" with arguments, use:
# make run ARGS="arguments here"

# The rules in this Makefile store generated object files and keep track of
# dependencies through dependency files to minimize recompilation time.
# Because the dependency generation is fully automated using compiler tools,
# there is no need to specify a header extension (e.g. ".h").

# The variables below the "Settings" header can be altered to change the build
# behavior. Their meaning is as follows:

# BINNAME_R  The name of the generated release binary
# BINNAME_D  The name of the genereated debug binary

# CC         The C compiler
# CXX        The C++ compiler
# FLAGS      By default, prepended to CFLAGS and CXXFLANGS; common C/C++ flags
# CFLAGS     Compiler flags used for building C object files
# CXXFLAGS   Compiler flags used for building and linking C++ object files
# FLAGS_R    Release-specific compiler flags
# FLAGS_D    Debug-specific compiler flags
# LDFLAGS    Compiler flags used when linking the the binary
# INCFLAGS   Compiler flags for file inclusion; used for building object files

# BINDIR     Directory in which the binaries are placed
# SRCDIR     Directory in which to look for C/C++ source files
# BLDDIR     Directory in which generated object and dependency files are placed

# SRCEXT_CXX Extension of C++ source files
# SRCEXT_C   Extension of C source files
# ARGS       Text to append to binary invocations (rules "run" and "drun")
# RM         The command that is used to remove files (rules "c" and "clean")

# MKBIN_R and MKBIN_D are the commands used to build the final binaries. These
# can be changed for advanced usage, such as building libraries. Make will run
# these commands with $^ set to the list of object files and $@ set to the path
# of the binary to create.

# VERBOSE    Should be 0 or 1; if 1, all executed commands are fully printed
# FILE_TPUT  The tput commands used to style filenames in progress messages

#==============================================================================#
#---------------------------------- Settings ----------------------------------#
#==============================================================================#

BINNAME_R = BINARYNAME_PLACEHOLDER
BINNAME_D = $(BINNAME_R)_debug

CC        = gcc
CXX       = g++
FLAGS     = -Wall -Wextra -Wignored-qualifiers
CFLAGS    = $(FLAGS)
CXXFLAGS  = $(FLAGS) -std=c++17
FLAGS_R   = -O2 -DNDEBUG
FLAGS_D   = -Og -g3 -DDEBUG
LDFLAGS   =
INCFLAGS  = -I $(SRCDIR)

BINDIR    = bin
SRCDIR    = src
BLDDIR    = build

SRCEXT_CXX = .cpp
SRCEXT_C   = .c
ARGS       =
RM         = rm -f

MKBIN_R   = $(CXX) $(CXXFLAGS) $(FLAGS_R) $^ $(LDFLAGS) -o $@
MKBIN_D   = $(CXX) $(CXXFLAGS) $(FLAGS_D) $^ $(LDFLAGS) -o $@

VERBOSE   = 0
FILE_TPUT = tput bold; tput setaf 3

#==============================================================================#
#------------------ Are you sure you know what you're doing? ------------------#
#==============================================================================#

# Checks

ifeq ($(BLDDIR), .)
  $(error You MONSTER, never set BLDDIR to '.'! It would clutter your project directory)
endif

ifeq ($(findstring $(VERBOSE),01),)
  $(error The VERBOSE variable is set to "$(VERBOSE)", but it should be either 0 or 1)
endif


# Functions

rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))


# Variables

OBJDIR := $(BLDDIR)/obj
DEPDIR := $(BLDDIR)/dep

SUBDIR_R   := release
SUBDIR_D   := debug
SUBDIR_CXX := cpp
SUBDIR_C   := c

OBJDIR_R_CXX := $(OBJDIR)/$(SUBDIR_R)/$(SUBDIR_CXX)
OBJDIR_D_CXX := $(OBJDIR)/$(SUBDIR_D)/$(SUBDIR_CXX)
DEPDIR_R_CXX := $(DEPDIR)/$(SUBDIR_R)/$(SUBDIR_CXX)
DEPDIR_D_CXX := $(DEPDIR)/$(SUBDIR_D)/$(SUBDIR_CXX)
OBJDIR_R_C   := $(OBJDIR)/$(SUBDIR_R)/$(SUBDIR_C)
OBJDIR_D_C   := $(OBJDIR)/$(SUBDIR_D)/$(SUBDIR_C)
DEPDIR_R_C   := $(DEPDIR)/$(SUBDIR_R)/$(SUBDIR_C)
DEPDIR_D_C   := $(DEPDIR)/$(SUBDIR_D)/$(SUBDIR_C)

SOURCES_CXX := $(call rwildcard,$(SRCDIR)/,*$(SRCEXT_CXX))
SOURCES_C   := $(call rwildcard,$(SRCDIR)/,*$(SRCEXT_C))
OBJS_R      := $(patsubst $(SRCDIR)/%$(SRCEXT_CXX),$(OBJDIR_R_CXX)/%.o,$(SOURCES_CXX)) \
               $(patsubst $(SRCDIR)/%$(SRCEXT_C),$(OBJDIR_R_C)/%.o,$(SOURCES_C))
OBJS_D      := $(patsubst $(SRCDIR)/%$(SRCEXT_CXX),$(OBJDIR_D_CXX)/%.o,$(SOURCES_CXX)) \
               $(patsubst $(SRCDIR)/%$(SRCEXT_C),$(OBJDIR_D_C)/%.o,$(SOURCES_C))

DEPS := $(patsubst $(SRCDIR)/%$(SRCEXT_CXX),$(DEPDIR_R_CXX)/%.d,$(SOURCES_CXX)) \
        $(patsubst $(SRCDIR)/%$(SRCEXT_CXX),$(DEPDIR_D_CXX)/%.d,$(SOURCES_CXX)) \
        $(patsubst $(SRCDIR)/%$(SRCEXT_C),$(DEPDIR_R_C)/%.d,$(SOURCES_C))     \
        $(patsubst $(SRCDIR)/%$(SRCEXT_C),$(DEPDIR_D_C)/%.d,$(SOURCES_C))

BIN_R := $(BINDIR)/$(BINNAME_R)
BIN_D := $(BINDIR)/$(BINNAME_D)

DEPGENFLAGS_R_CXX = -MT "$@" -MMD -MP -MF $(DEPDIR_R_CXX)/$*.Td
DEPGENFLAGS_D_CXX = -MT "$@" -MMD -MP -MF $(DEPDIR_D_CXX)/$*.Td
DEPGENFLAGS_R_C = -MT "$@" -MMD -MP -MF $(DEPDIR_R_C)/$*.Td
DEPGENFLAGS_D_C = -MT "$@" -MMD -MP -MF $(DEPDIR_D_C)/$*.Td

POSTCOMPILE_R_CXX = mv -f $(DEPDIR_R_CXX)/$*.Td $(DEPDIR_R_CXX)/$*.d && touch $@
POSTCOMPILE_D_CXX = mv -f $(DEPDIR_D_CXX)/$*.Td $(DEPDIR_D_CXX)/$*.d && touch $@
POSTCOMPILE_R_C = mv -f $(DEPDIR_R_C)/$*.Td $(DEPDIR_R_C)/$*.d && touch $@
POSTCOMPILE_D_C = mv -f $(DEPDIR_D_C)/$*.Td $(DEPDIR_D_C)/$*.d && touch $@

QUIET := @
ifeq ($(VERBOSE),1)
	QUIET :=
endif

FILE_TPUT_BEGIN :=
FILE_TPUT_END   :=
ifneq ($(shell tput -V 2>/dev/null),)
	FILE_TPUT_BEGIN := $(shell $(FILE_TPUT))
	FILE_TPUT_END   := $(shell tput sgr0)
endif


# Targets

.PRECIOUS: $(BINDIR)/. $(SRCDIR)/. \
           $(addsuffix .,$(dir $(OBJS_R))) $(addsuffix .,$(dir $(OBJS_D))) \
           $(addsuffix .,$(dir $(DEPS)))

.PHONY: all run
all: release
run: rrun

.PHONY: debug release
debug: $(BIN_D)
release: $(BIN_R)

.PHONY: rrun drun
rrun: release
	$(QUIET)$(BIN_R) $(ARGS)
drun: debug
	$(QUIET)$(BIN_D) $(ARGS)

%/.:
	$(QUIET)mkdir -p $@

$(BIN_R): $(OBJS_R) | $(BINDIR)/.
	@echo 'Creating $(FILE_TPUT_BEGIN)$@$(FILE_TPUT_END)'
	$(QUIET)$(MKBIN_R)

$(BIN_D): $(OBJS_D) | $(BINDIR)/.
	@echo 'Creating $(FILE_TPUT_BEGIN)$@$(FILE_TPUT_END)'
	$(QUIET)$(MKBIN_D)

$(DEPS): ;
include $(wildcard $(DEPS))

.PHONY: c
c:
	@echo 'Removing cached build byproducts'
	$(QUIET)-if [ -d '$(OBJDIR)' ]; then find '$(OBJDIR)' -type f -name '*.o'  -exec $(RM) {} +; fi
	$(QUIET)-if [ -d '$(DEPDIR)' ]; then find '$(DEPDIR)' -type f -name '*.d'  -exec $(RM) {} +; fi
	$(QUIET)-if [ -d '$(DEPDIR)' ]; then find '$(DEPDIR)' -type f -name '*.Td' -exec $(RM) {} +; fi
	$(QUIET)-find $(OBJDIR) $(DEPDIR) -type d -empty -exec 'rmdir' '-p' {} \; 2>/dev/null || true

.PHONY: clean
clean: c
	@echo 'Removing generated binaries'
	$(QUIET)-$(RM) $(BIN_R)
	$(QUIET)-$(RM) $(BIN_D)
	$(QUIET)-if [ -d $(BINDIR) ]; then rmdir --ignore-fail-on-non-empty -p "$$(cd '$(BINDIR)'; pwd)"; fi


.SECONDEXPANSION:

$(OBJDIR_R_CXX)/%.o: $(SRCDIR)/%$(SRCEXT_CXX) $(DEPDIR_R_CXX)/%.d | $$(dir $$@). $$(dir $(DEPDIR_R_CXX)/$$*.d).
	@echo 'Compiling $(FILE_TPUT_BEGIN)$<$(FILE_TPUT_END)'
	$(QUIET)$(CXX) $(CXXFLAGS) $(FLAGS_R) $(INCFLAGS) -c $< -o $@ $(DEPGENFLAGS_R_CXX)
	$(QUIET)$(POSTCOMPILE_R_CXX)

$(OBJDIR_D_CXX)/%.o: $(SRCDIR)/%$(SRCEXT_CXX) $(DEPDIR_D_CXX)/%.d | $$(dir $$@). $$(dir $(DEPDIR_D_CXX)/$$*.d).
	@echo 'Compiling $(FILE_TPUT_BEGIN)$<$(FILE_TPUT_END)'
	$(QUIET)$(CXX) $(CXXFLAGS) $(FLAGS_D) $(INCFLAGS) -c $< -o $@ $(DEPGENFLAGS_D_CXX)
	$(QUIET)$(POSTCOMPILE_D_CXX)

$(OBJDIR_R_C)/%.o: $(SRCDIR)/%$(SRCEXT_C) $(DEPDIR_R_C)/%.d | $$(dir $$@). $$(dir $(DEPDIR_R_C)/$$*.d).
	@echo 'Compiling $(FILE_TPUT_BEGIN)$<$(FILE_TPUT_END)'
	$(QUIET)$(CC) $(CFLAGS) $(FLAGS_R) $(INCFLAGS) -c $< -o $@ $(DEPGENFLAGS_R_C)
	$(QUIET)$(POSTCOMPILE_R_C)

$(OBJDIR_D_C)/%.o: $(SRCDIR)/%$(SRCEXT_C) $(DEPDIR_D_C)/%.d | $$(dir $$@). $$(dir $(DEPDIR_D_C)/$$*.d).
	@echo 'Compiling $(FILE_TPUT_BEGIN)$<$(FILE_TPUT_END)'
	$(QUIET)$(CC) $(CFLAGS) $(FLAGS_D) $(INCFLAGS) -c $< -o $@ $(DEPGENFLAGS_D_C)
	$(QUIET)$(POSTCOMPILE_D_C)
