#

include arch.mk

SRC_COMMON = check.f90
OBJ_COMMON = $(SRC_COMMON:.f90=.o)

EXE = pzheevd.ex
SRC = benchmark_pzheevd.f90

EXE_ELPA = elpa.ex
SRC_ELPA = benchmark_elpa.f90

OBJ = $(SRC:.f90=.o)
OBJ_ELPA = $(SRC_ELPA:.f90=.o)

default: scalapack 

all: scalapack elpa 

scalapack: $(OBJ_COMMON) $(OBJ)
	$(FC) $(OBJ_COMMON) $(OBJ) -o $(EXE) $(LINKFLAGS) $(SCALAPACKLIB) $(BLASLIB)

$(OBJ): $(SRC)
	$(FC) -c $(SRC) $(FCFLAGS) 

elpa: $(OBJ_COMMON) $(OBJ_ELPA)
	$(FC) $(OBJ_COMMON) $(OBJ_ELPA) -o $(EXE_ELPA) $(LINKFLAGS) $(ELPALIB)  $(SCALAPACKLIB)  $(BLASLIB)

$(OBJ_ELPA): $(SRC_ELPA)
	$(FC) -c $(SRC_ELPA) $(FCFLAGS)  -I/$(ELPAINCLUDE) 

$(OBJ_COMMON): $(SRC_COMMON)
	$(FC) -c $(SRC_COMMON) $(FCFLAGS)

clean: 
	rm -f  *.o  *.mod  *.ex
