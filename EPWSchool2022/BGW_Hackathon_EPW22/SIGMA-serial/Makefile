#

EXE_GPP = gppKerFort.ex
SRC_GPP = gppKer.f90

FC = mpif90

FCFLAGS = -O3 -fp-model source -xCORE-AVX512 -free -qopenmp -ip -no-ipo
LINKFLAGS = -O3 -fp-model source -xCORE-AVX512 -free -qopenmp -ip -no-ipo

OBJ_GPP = $(SRC_GPP:.f90=.o)

default: gpp

gpp: $(OBJ_GPP)
	$(FC) $(OBJ_GPP) -o $(EXE_GPP) $(LINKFLAGS)

$(OBJ_GPP): $(SRC_GPP)
	$(FC) -c $(SRC_GPP) $(FCFLAGS)

clean: 
	rm -f *.o *.ex
