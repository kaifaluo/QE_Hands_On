# module load arpack impi phdf5 cuda
#
FC = mpiifort
LINK = ${FC}

MKLPATH = $(MKLROOT)/lib/intel64
BLASLIB = -Wl,--start-group \
          $(MKLPATH)/libmkl_intel_lp64.a \
          $(MKLPATH)/libmkl_intel_thread.a \
          $(MKLPATH)/libmkl_core.a \
          $(MKLPATH)/libmkl_blacs_intelmpi_lp64.a \
          -Wl,--end-group -liomp5 -lpthread -lm -ldl
SCALAPACKLIB = $(MKLPATH)/libmkl_scalapack_lp64.a

ELPALIB = /work2/06868/giustino/EP-SCHOOL/BGW/Hackathon/ELPA/lib/libelpa_openmp.a -lstdc++
ELPAINCLUDE = /work2/06868/giustino/EP-SCHOOL/BGW/Hackathon/ELPA/modules/

ELPALIB_GPU =  
ELPAINCLUDE_GPU = 
CUDALIB=-L$(TACC_CUDA_DIR)/lib64/  -lcufft -lcublas  -lcudart  -lcuda
# CUDALIB=-L$(TACC_CUDA_DIR)/lib64/libcudart_static.a \
#         -L$(TACC_CUDA_DIR)/lib64/libcufft_static.a \
#         -L$(TACC_CUDA_DIR)/lib64/libcublas_static.a \
#         -L$(TACC_CUDA_DIR)/lib64/libcublasLt_static.a
#          -lcudart  -lcuda

PRIMME_LIB = 
PRIMME_INC = 

MAGMA_LIB = 
MAGMA_INC = 

FCFLAGS = -O3 -fp-model source -xCORE-AVX512 -free -qopenmp -ip -no-ipo
LINKFLAGS = -O3 -fp-model source -xCORE-AVX512 -free -qopenmp -ip -no-ipo

NVCC=nvcc 
NVCC_FLAGS= -O3 -use_fast_math

