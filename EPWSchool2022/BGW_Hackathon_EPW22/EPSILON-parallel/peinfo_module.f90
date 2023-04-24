  MODULE peinfo_module
  USE mpi
  USE omp_lib
  
  IMPLICIT NONE

  PUBLIC :: peinfo, peinfo_init, peinfo_finalize

  TYPE :: peinfo
    INTEGER :: mpi_comm
    INTEGER :: npes = 1
    INTEGER :: inode = 0
    INTEGER :: nthreads = 1
  END TYPE peinfo

  TYPE(peinfo), SAVE, PUBLIC :: peinf
  INTEGER, PUBLIC :: mpistatus(MPI_STATUS_SIZE)
  INTEGER, PUBLIC :: mpierr


  CONTAINS

  subroutine peinfo_init()

    call MPI_Init(mpierr)
    if(mpierr .ne. MPI_SUCCESS) then
      write(*,*) 'ERROR: MPI initialization failed!'
      stop 999
    endif
    peinf%mpi_comm = MPI_COMM_WORLD
    call MPI_Comm_rank(MPI_COMM_WORLD, peinf%inode, mpierr)
    call MPI_Comm_size(MPI_COMM_WORLD, peinf%npes, mpierr)

!$OMP PARALLEL
    peinf%nthreads = OMP_GET_NUM_THREADS()
!$OMP END PARALLEL

  end subroutine peinfo_init

  subroutine peinfo_finalize()

    call MPI_Finalize(mpierr)
    if(mpierr .ne. MPI_SUCCESS) then
      write(*,*) 'ERROR: MPI finalized failed!'
      stop 999
    endif

  end subroutine

  END MODULE
