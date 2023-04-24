#

EXE = epsilon_kernel.ex
SRC = peinfo_module.f90  timing.f90  epsilon_kernel.f90

FC = mpif90
LINK = ${FC}
MKLPATH = $(MKLROOT)/lib/intel64
LIB_BLAS = -Wl,--start-group \
          $(MKLPATH)/libmkl_intel_lp64.a \
          $(MKLPATH)/libmkl_intel_thread.a \
          $(MKLPATH)/libmkl_core.a \
          $(MKLPATH)/libmkl_blacs_intelmpi_lp64.a \
          -Wl,--end-group -liomp5 -lpthread -lm -ldl

FCFLAGS   = -O3 -fp-model source -xCORE-AVX512 -free -qopenmp -ip -no-ipo
LINKFLAGS = -O3 -fp-model source -xCORE-AVX512 -free -qopenmp -ip -no-ipo 

OBJ = $(SRC:.f90=.o)

default: epsilon

epsilon: $(OBJ)
	$(FC) $(OBJ) -o $(EXE) $(LINKFLAGS) $(LIB_BLAS)

$(OBJ): $(SRC)
	$(FC) -c $(SRC) $(FCFLAGS)

clean: 
	rm -f  *.o  *.mod  *.ex
