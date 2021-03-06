################################################################################
#
#	Makefile for RMG
#
################################################################################

# The directory in which the source files can be found
SOURCEDIR=$(CURDIR)/source

# The directory in which to place temporary compiled files
BUILDDIR=$(CURDIR)/build

# The directory in which to place compiled executables and JAR files
BINDIR=$(CURDIR)/bin

# The directory in which to run RMG (used for the test)
RUNDIR=$(CURDIR)/run

# The Fortran 90 compiler to use and flags to use when compiling Fortran 90 
# code
F90=g95
F90FLAGS=-fbounds-check -ftrace=full -fmod=$(BUILDDIR) -Wall -O3
F90FLAGS_NDEBUG=-fmod=$(BUILDDIR) -ftrace=full 
# these are added to the LDFLAGS of the subsidiary makefiles
#F90_EXTRA_LDFLAGS = -L/home/local/lib -lg2c  # required for Monch
#F90_EXTRA_LDFLAGS =  -framework vecLIB # for optimized blas and lapack on MacOS X, if they're not found automatically

#F90=gfortran
#F90FLAGS=-fbounds-check -fbacktrace -Wall -O3
#F90FLAGS_NDEBUG=-fbacktrace
#F90=gfortran
#F90FLAGS = -ffpe-trap=invalid,zero,overflow -ftrapv -fbounds-check -ggdb -J""$(BUILDDIR)"" -Wall -O3 


################################################################################

# Default is to build those that come complete with the RMG distribution
base: dirs fame frankie GATPFit dassl RMG

# Make just the Fortran dependencies (i.e. not the Java)
fortran: dirs fame frankie GATPFit dassl

# Make all the Fortran (including DASPK)
all_fortran: dirs fame frankie GATPFit dassl daspk

# You can also build everything
all: dirs fame frankie GATPFit dassl daspk RMG

RMG: dirs 
	mkdir -p $(BUILDDIR)/RMG
	ant clean # we don't trust ant to spot what needs doing!
	ant compile
	ant jar

fame: dirs
	make -C $(SOURCEDIR)/fame SOURCEDIR=$(SOURCEDIR)/fame BUILDDIR=$(BUILDDIR)/fame BINDIR=$(BINDIR) F90=$(F90) F90FLAGS="$(F90FLAGS)" F90_EXTRA_LDFLAGS="$(F90_EXTRA_LDFLAGS)"

frankie: dirs
	make -C $(SOURCEDIR)/frankie SOURCEDIR=$(SOURCEDIR)/frankie BUILDDIR=$(BUILDDIR)/frankie BINDIR=$(BINDIR) F90=$(F90) F90FLAGS="$(F90FLAGS)" F90_EXTRA_LDFLAGS="$(F90_EXTRA_LDFLAGS)"

dassl: dirs
	make -C $(SOURCEDIR)/dassl SOURCEDIR=$(SOURCEDIR)/dassl BUILDDIR=$(BUILDDIR)/dassl BINDIR=$(BINDIR) F90=$(F90) F90FLAGS="$(F90FLAGS_NDEBUG)" F90_EXTRA_LDFLAGS="$(F90_EXTRA_LDFLAGS)"

daspk: dirs
	make -C $(SOURCEDIR)/daspk SOURCEDIR=$(SOURCEDIR)/daspk BUILDDIR=$(BUILDDIR)/daspk BINDIR=$(BINDIR) F90=$(F90) F90FLAGS="$(F90FLAGS_NDEBUG)" F90_EXTRA_LDFLAGS="$(F90_EXTRA_LDFLAGS)"

GATPFit: dirs
	make -C $(SOURCEDIR)/GATPFit SOURCEDIR=$(SOURCEDIR)/GATPFit BUILDDIR=$(BUILDDIR)/GATPFit BINDIR=$(BINDIR) F90=$(F90) F90FLAGS="$(F90FLAGS)" F90_EXTRA_LDFLAGS="$(F90_EXTRA_LDFLAGS)"




dirs:
	mkdir -p $(BUILDDIR)
	mkdir -p $(BINDIR)

clean:
	make -C $(SOURCEDIR)/fame clean SOURCEDIR=$(SOURCEDIR)/fame BUILDDIR=$(BUILDDIR)/fame BINDIR=$(BINDIR) 
	make -C $(SOURCEDIR)/frankie clean SOURCEDIR=$(SOURCEDIR)/frankie BUILDDIR=$(BUILDDIR)/frankie BINDIR=$(BINDIR) 
	make -C $(SOURCEDIR)/dassl clean SOURCEDIR=$(SOURCEDIR)/dassl BUILDDIR=$(BUILDDIR)/dassl BINDIR=$(BINDIR) 
	make -C $(SOURCEDIR)/daspk clean SOURCEDIR=$(SOURCEDIR)/daspk BUILDDIR=$(BUILDDIR)/daspk BINDIR=$(BINDIR) 
	make -C $(SOURCEDIR)/GATPFit clean SOURCEDIR=$(SOURCEDIR)/GATPFit BUILDDIR=$(BUILDDIR)/GATPFit BINDIR=$(BINDIR) 
	ant clean
	rm -rf $(BUILDDIR)
	rm -rf $(BINDIR)
	rm -rf $(RUNDIR)

# Run a test case
test:
	mkdir -p $(RUNDIR)
	cp examples/RMG/1,3-hexadiene/condition.txt $(RUNDIR)
	export RMG=$(CURDIR); cd $(RUNDIR); java -jar $(BINDIR)/RMG.jar condition.txt | tee RMG.log

help:
	@echo ""
	@echo "This makefile can be used to build all of the code required by RMG."
	@echo ""
	@echo "Typing \`make\` with no arguments will make all of the executables that come"
	@echo "completely bundled with RMG (indicated in the list below with an asterisk)."
	@echo ""
	@echo "Typing 'make test' will run an example file in the folder 'run'."
	@echo ""
	@echo "Typing \`make clean\` will remove all object files, modules, and executables"
	@echo "for all of the applications, and the 'run' folder."
	@echo ""
	@echo "Otherwise individual dependencies can be specified using \`make <target>\`"
	@echo "where <target> is one of:"
	@echo ""
	@echo "*    fame      to make fame, the pressure dependence code"
	@echo "*    frankie   to make frankie, the density of states code"
	@echo "*    dassl     to make dassl, the basic differential equation solver"
	@echo "     daspk     to make daspk, the diff. eq. solver with sensitivity"
	@echo "*    GATPFit   to make GATPFit"
	@echo "*    RMG       to make RMG"
	@echo ""
