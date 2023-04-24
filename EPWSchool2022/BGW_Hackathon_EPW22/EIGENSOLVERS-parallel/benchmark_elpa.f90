module helper
  
   implicit none
  
  contains

    subroutine transpose_matrix(uplo, ln, a_ref, a_sym, desca)
      
      
      character, intent(in)  :: uplo
      integer, intent(in) :: ln
      complex(kind=8), intent(in) :: a_ref(:,:)
      complex(kind=8), intent(out) :: a_sym(:,:)
      integer, intent(in) :: desca(:)
      
      complex(kind=8) :: alpha, beta
      
      logical :: lsame
      
      alpha = (1.0, 0.0)
      beta = (0.0, 0.0)
      
      call pztranc(ln, ln, alpha, a_ref, 1, 1, desca, beta, a_sym, 1, 1, desca)
      
      a_sym = (a_ref + a_sym)*0.5D+00

      ! if (lsame(uplo, "L")) then
      !    call pztrmr2d("L", "N", ln, ln, a_ref, 1, 1, desca, a_sym, 1, 1, desca, desca(2))
      ! else 
      !    call pztrmr2d("U", "N", ln, ln, a_ref, 1, 1, desca, a_sym, 1, 1, desca, desca(2))
      ! end if
      

    end subroutine transpose_matrix

    elemental subroutine convert_to_int(str, i, stat)
      
      character(len=*), intent(in) :: str
      integer, intent(out) :: i, stat

      read(str, *, iostat=stat) i
      
    end subroutine convert_to_int

end module helper

program benchmark_elpa

  ! USING THE NEW ELPA API
  use elpa
  ! use elpa_driver
  use helper
  use omp_lib
  use check

  implicit none

  include 'mpif.h'
  
  integer :: ctxt_sys
  integer :: rank, size, i, j
  integer :: ln, lnprow, lnpcol, lnbrow, lnbcol
  integer :: llda, ml, nl, lsize, numEle
  integer :: myrow, mycol, info, err
  real(kind=8) :: t1, t2

  class(elpa_t), pointer :: e

  integer, allocatable :: desca(:)
  complex(kind=8), allocatable :: a_ref(:,:), a_sym(:,:), z(:,:)
  real(kind=8), allocatable :: w(:)
  integer, dimension(4) :: iseed
  character(len=10), dimension(4) :: argc

  integer numroc ! , mpi_comm_rows, mpi_comm_cols
  integer nthreads
  integer method

  integer, parameter :: ELS_TO_PRINT  = 5             ! arbitrary els to print out

  integer :: read_unit
  logical :: read_mat

  ! Initialize MPI and BLACS
  call mpi_init(err)
  call mpi_comm_rank(MPI_COMM_WORLD, rank, err)
  call mpi_comm_size(MPI_COMM_WORLD, size, err)

  
  !$OMP PARALLEL
  nthreads = OMP_GET_NUM_THREADS()
  !$OMP END PARALLEL

  do i = 1, 4
     call get_command_argument(i, argc(i))
  end do

  call convert_to_int(argc(1), ln, err) 
  call convert_to_int(argc(2), lnprow, err)
  call convert_to_int(argc(3), lnpcol, err)
  call convert_to_int(argc(4), lnbrow, err)
  lnbcol = lnbrow

  read_unit = -1
  read_mat=.false.
  if ( ln <= 0 ) then
    read_unit = abs(ln)
    read(read_unit) ln
    rewind(read_unit)
    read_mat=.true.
  end if

  if (rank == 0) then
     WRITE(*,*) "MPI Tasks:", size
     WRITE(*,*) "OpenMP threads:", nthreads
     WRITE(*,*) "Matrix Size =", ln
     WRITE(*,*) "nprow =", lnprow
     WRITE(*,*) "npcol =", lnpcol
     WRITE(*,*) "Block Size =", lnbrow
  end if

  if (lnpcol*lnprow /= size) then
    stop 'nprow * npcol Not Equal to the number of MPI tasks'
  end if


  call blacs_get(0, 0, ctxt_sys)
  call blacs_gridinit(ctxt_sys, "C", lnprow, lnpcol)
  call blacs_gridinfo(ctxt_sys, lnprow, lnpcol, myrow, mycol)

  if (myrow .eq. -1) then
     print *, "Failed to properly initialize MPI and/or BLACS!"
     call MPI_FINALIZE(err)
     stop
  end if

  ! no longer necessary with new API
  !XXX ! Explicitly get and set the row and column communicators, as the API seems to be
  !XXX ! failing to initialize them as they should
  !XXX err = elpa_get_communicators(MPI_COMM_WORLD, myrow, mycol, mpi_comm_rows, mpi_comm_cols)

  ! Allocate my matrices now
  ml = numroc(ln, lnbrow, myrow, 0, lnprow)
  nl = numroc(ln, lnbcol, mycol, 0, lnpcol)
  llda = ml

  allocate(a_ref(ml,nl))
  allocate(a_sym(ml,nl))
  allocate(z(ml,nl))
  allocate(w(ln))
  allocate(desca(9))

  ! Create my blacs descriptor for transposing the matrix
  call descinit(desca, ln, ln, lnbrow, lnbcol, 0, 0, ctxt_sys, llda, info)  

  if ( read_mat ) then

    t1 = MPI_WTIME()
    if ( rank == 0 ) write(*,*)
    if ( rank == 0 ) write(*,*) 'Start Reading Matrix'

    a_ref = (0.0D+00,0.0D+00)
    call read_matrix(read_unit, ln, a_ref, lnbrow, lnbcol, lnprow, lnpcol, myrow, mycol)

    t2 = MPI_WTIME()
    if ( rank == 0 ) write(*,*) 'Reading done in:', t2-t1

    call transpose_matrix("L", ln, a_ref, a_sym, desca)

    ! do i = 1, nl
    !   do j = i, nl
    !     write(1000,*) a_sym(i,j) - CONJG(a_sym(j,i))
    !   end do
    ! end do

  else

    iseed(1) = myrow
    iseed(2) = mycol
    iseed(3) = mycol + myrow*lnpcol
    iseed(4) = 1

    
    if (iand(iseed(4), 2) == 0) then
       iseed(4) = iseed(4) + 1
    end if

    numEle = ml*nl
!    write(6,*) iseed, numEle

    call zlarnv(1, iseed, numEle, a_ref)
    call transpose_matrix("L", ln, a_ref, a_sym, desca) 

  end if

  a_ref = a_sym

! do i=1, ml
!    do j=1, ml
!       write(6,*) "rank=", rank, "a_ref(",i,j,")=", a_ref(i,j)
!    end do
! end do

  t1 = MPI_WTIME()

  ! Try initializing and allocating elpa
  if (elpa_init(20170403) /= elpa_ok) then
    print *, "ELPA API not supported"
    stop
  end if

  e => elpa_allocate()
  call e%set("na", ln, err)
  call e%set("nev", ln, err)
  call e%set("local_nrows", ml, err)
  call e%set("local_ncols", nl, err)
  call e%set("nblk", lnbrow, err)
  call e%set("mpi_comm_parent", mpi_comm_world, err)
  ! call e%set("mpi_comm_rows", mpi_comm_rows, err)
  ! call e%set("mpi_comm_cols", mpi_comm_cols, err)
  if ( nthreads > 1 ) then
    call e%set("omp_threads", nthreads, err)
  end if
  call e%set("process_row", myrow, err)
  call e%set("process_col", mycol, err)

  ! Setup
  err = e%setup()
  if(err /= 0) then
    write(*,"(2X,A)") "Error: setup"
    call MPI_Abort(mpi_comm_world,0,err)
    stop
  end if

  method = 1
  if(method == 1) then
    call e%set("solver",ELPA_SOLVER_1STAGE,err)
  else 
    call e%set("solver", ELPA_SOLVER_2STAGE, err)
  end if

  !XXX call e%set("complex_kernel", ELPA_2STAGE_COMPLEX_AVX512_BLOCK1, err)
  call e%set("complex_kernel", ELPA_2STAGE_COMPLEX_GENERIC, err)

  call e%eigenvectors(a_sym, w, z, err)
  
  if(err /= 0) then
    write(*,"(2X,A)") "Error: solve"
    call MPI_Abort(mpi_comm_world,0,err)
    stop
  end if

  call elpa_deallocate(e)
  call elpa_uninit()
  nullify(e)
  
  t2 = MPI_WTIME()
  
   if (rank == 0 ) then
      WRITE(6,*)
      do j=1, ELS_TO_PRINT
         write(6,*) "w(", j, ")=", w(j), "z(", j, ")=", z(j,1)
      end do
      WRITE(6,*)
   end if
   if (rank == 0 ) WRITE(6,*) 'Check results'
   call check_results(ln,ln,a_ref,w,z,desca, lnprow, lnpcol, myrow, mycol, rank, MPI_COMM_WORLD)


   ! only serial
   !XXX a_ref = MATMUL( TRANSPOSE(CONJG(z)), MATMUL(a_ref, z) )
   !XXX do i = 1, ln 
   !XXX   do j = i, ln
   !XXX     write(1000,*) i, j, a_ref(i,j), a_ref(j,i)
   !XXX   end do
   !XXX end do

   if (rank == 0) then
      print *, "ELPA time: ", t2 - t1
   end if


  deallocate(a_ref) 
  deallocate(a_sym)
  deallocate(z)
  deallocate(w)
  deallocate(desca)

  ! Finish MPI
  call MPI_FINALIZE(err)

end program benchmark_elpa

