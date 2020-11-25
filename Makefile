# Generic C++ Makefile
# Arthur van der Staaij and Aron de Jong, 2020-9-24

# Besides  actual build targets, the following rules are provided:
# all:     build the release binary (with FLAGS_R)
# release: build the release binary (with FLAGS_R)
# debug:   build the debug binary (with FLAGS_D)
# run:     build the release binary and run it
# rrun:    build the release binary and run it
# drun:    build the debug binary and run it
# c:       clean object and dependency files
# clean:   clean all build byproducts, the binary and empty directories

# To use "run" and "drun" with arguments, use:
# make run ARGS="arguments here"

# The rules in this Makefile store generated object files and keep track of C++
# dependencies through dependency files to minimize recompilation time.
# Because the dependency generation is fully automated using compiler tools,
# there is no need to specify a header extension (e.g. ".h").

# The lines above the #-line can be altered to change the build behavior.
# CXX specifies the compiler, CXXFLAGS the compiler flags.
# FLAGS_R and FLAGS_D contain release and debug-specific flags respectively.
# LDFLAGS contains the compiler flags related to linking.
# INCFLAGS contains the compiler flags related to file inclusion.
# BINNAME_R and BINNAME_D are the names of the release and debug binaries.
# The binaries will be placed in BINDIR. Source files are read from SRCDIR.
# Object files are kept in OBJDIR/SUBDIR_R and OBJDIR/SUBDIR_D.
# Dependency files are kept in DEPDIR/SUBDIR_R and DEPDIR/SUBDIR_D.
# SRCEXT specifies the extension of source files (e.g. ".cpp").
# RM contains the command that is used to clean files (rules "c" and "clean")
# ARGS is appended to binary invocations (rules "run" and "drun")

# MKBIN_R and MKBIN_D are the commands used to build the final binaries. These
# can be changed for advanced usage, such as building libraries. Make will run
# these commands with $^ set to the list of object files and $@ set to the path
# of the binary to create.

CXX = g++

CXXFLAGS = -std=c++17 -Wall -Wextra -Wignored-qualifiers

FLAGS_R = -O2
FLAGS_D = -g

LDFLAGS =

INCFLAGS = -I include

BINNAME_R = BINARYNAME_PLACEHOLDER
BINNAME_D = $(BINNAME_R)_debug

BINDIR = bin
SRCDIR = src
OBJDIR = build/obj
DEPDIR = build/dep

SUBDIR_R = release
SUBDIR_D = debug

SRCEXT = .cpp

RM = rm -f

ARGS =

MKBIN_R = $(CXX) $(CXXFLAGS) $(FLAGS_R) $^ $(LDFLAGS) -o $@
MKBIN_D = $(CXX) $(CXXFLAGS) $(FLAGS_D) $^ $(LDFLAGS) -o $@

################################################################################

# Functions

rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

################################################################################

OBJDIR_R ::= $(OBJDIR)/$(SUBDIR_R)
OBJDIR_D ::= $(OBJDIR)/$(SUBDIR_D)
DEPDIR_R ::= $(DEPDIR)/$(SUBDIR_R)
DEPDIR_D ::= $(DEPDIR)/$(SUBDIR_D)

SOURCES ::= $(call rwildcard,$(SRCDIR)/,*$(SRCEXT))
OBJS_R  ::= $(patsubst $(SRCDIR)/%$(SRCEXT),$(OBJDIR_R)/%.o,$(SOURCES))
OBJS_D  ::= $(patsubst $(SRCDIR)/%$(SRCEXT),$(OBJDIR_D)/%.o,$(SOURCES))

DEPS ::= $(patsubst $(SRCDIR)/%$(SRCEXT),$(DEPDIR_R)/%.d,$(SOURCES)) \
         $(patsubst $(SRCDIR)/%$(SRCEXT),$(DEPDIR_D)/%.d,$(SOURCES))

BIN_R ::= $(BINDIR)/$(BINNAME_R)
BIN_D ::= $(BINDIR)/$(BINNAME_D)

DEPGENFLAGS_R = -MT "$@" -MMD -MP -MF $(DEPDIR_R)/$*.Td
DEPGENFLAGS_D = -MT "$@" -MMD -MP -MF $(DEPDIR_D)/$*.Td

POSTCOMPILE_R = mv -f $(DEPDIR_R)/$*.Td $(DEPDIR_R)/$*.d && touch $@
POSTCOMPILE_D = mv -f $(DEPDIR_D)/$*.Td $(DEPDIR_D)/$*.d && touch $@

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
	$(BIN_R) $(ARGS)
drun: debug
	$(BIN_D) $(ARGS)

%/.:
	mkdir -p $@

$(BIN_R): $(OBJS_R) | $(BINDIR)/.
	$(MKBIN_R)

$(BIN_D): $(OBJS_D) | $(BINDIR)/.
	$(MKBIN_D)

$(DEPS): ;
include $(wildcard $(DEPS))

.SECONDEXPANSION:
$(OBJDIR_R)/%.o: $(SRCDIR)/%$(SRCEXT) $(DEPDIR_R)/%.d | $$(dir $$@). $$(dir $(DEPDIR_R)/$$*.d).
	$(CXX) $(CXXFLAGS) $(FLAGS_R) $(INCFLAGS) -c $< -o $@ $(DEPGENFLAGS_R)
	$(POSTCOMPILE_R)

$(OBJDIR_D)/%.o: $(SRCDIR)/%$(SRCEXT) $(DEPDIR_D)/%.d | $$(dir $$@). $$(dir $(DEPDIR_D)/$$*.d).
	$(CXX) $(CXXFLAGS) $(FLAGS_D) $(INCFLAGS) -c $< -o $@ $(DEPGENFLAGS_D)
	$(POSTCOMPILE_D)

.PHONY: c
c:
	-find . -type f -path './$(OBJDIR)/*.o'  -delete
	-find . -type f -path './$(DEPDIR)/*.d'  -delete
	-find . -type f -path './$(DEPDIR)/*.Td' -delete

.PHONY: clean
clean: c
	-$(RM) $(BIN_R)
	-$(RM) $(BIN_D)
	-find $(OBJDIR) $(DEPDIR) $(BINDIR) -type d -empty -exec 'rmdir' '-p' {} \; 2>/dev/null || true
