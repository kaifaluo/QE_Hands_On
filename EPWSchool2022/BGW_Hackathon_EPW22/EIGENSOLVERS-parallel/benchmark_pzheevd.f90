module helper
  implicit none

  contains

    elemental subroutine convert_to_int(str, i, stat)

      character(len=*), intent(in) :: str
      integer, intent(out) :: i, stat

      read(str, *, iostat=stat) i

    end subroutine convert_to_int

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

end module helper

program pzheevd_test
   use mpi
   use helper
   use check

   implicit none
!  modify for specific problem

   integer, parameter :: MY_NPROW      = 2
   integer, parameter :: MY_NPCOL      = 2
   integer, parameter :: MY_N          = 1024
   integer, parameter :: MY_NB         = 256
   integer, parameter :: MY_IL         = 1             ! lower bound for eigenval num
   integer, parameter :: MY_IU         = 1024          ! upper bound for eigenval num

   integer, parameter :: ELS_TO_PRINT  = 5             ! arbitrary els to print out
 

   integer   :: info = 0
   character :: jobz = 'V'
   character :: uplo = 'L'
   integer   :: ln = MY_N
   integer   :: lnbrow = MY_NB
   integer   :: lnbcol
   integer   :: m, nz
   integer   :: err
 
   integer   :: il = MY_IL, iu = MY_IU
 
   real(kind=8) :: dummyL, dummyU
   real(kind=8) :: t1, t2
  
   integer :: lnprow = MY_NPROW
   integer :: lnpcol = MY_NPCOL

   integer :: myrow, mycol
   integer :: ia=1, ja=1, iz=1, jz=1

   integer :: desca(9)
  
   integer :: ctxt_sys
   integer :: moneI = -1, zeroI = 0, oneI = 1
   integer :: rank, size, i
   integer :: llda

   character(len=9) :: procOrder = "Row-major"
   character(len=10), dimension(4) :: argc

!  ADDED DEFINITIONS
   integer :: ml, nl
   integer :: iseed(4)
   integer :: numEle

   complex(kind=8), allocatable :: a_ref(:,:), z(:,:)
   complex(kind=8), allocatable :: a_sym(:,:)
   real(kind=8), allocatable :: w(:)
   complex(kind=8), allocatable ::  work(:)
   real(kind=8), allocatable :: rwork(:)
   integer,      allocatable :: iwork(:)
   real(kind=8) :: temp(2), rtemp(2)   ! I THINK THIS COULD ONLY BE rtemp(1)
   integer :: liwork, lwork, lrwork
   integer :: my_rank, j, ierror

!  .. External Functions ..
   integer, external ::   numroc

   integer :: read_unit
   logical :: read_mat


  ! Initialize MPI and BLACS
  call MPI_INIT(err)
  call MPI_COMM_RANK(MPI_COMM_WORLD, rank, err)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, size, err)

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
     WRITE(*,*) "Matrix Size =", ln
     WRITE(*,*) "nprow =", lnprow
     WRITE(*,*) "npcol =", lnpcol
     WRITE(*,*) "Block Size =", lnbrow
  end if

  if (lnpcol*lnprow /= size) then
    stop 'nprow * npcol Not Equal to the number of MPI tasks'
  end if

   call blacs_get(moneI, zeroI, ctxt_sys)
   call blacs_gridinit(ctxt_sys, procOrder, lnprow, lnpcol)
   call blacs_gridinfo(ctxt_sys, lnprow, lnpcol, myrow, mycol)
  
  if (myrow .eq. -1) then
     print *, "Failed to properly initialize MPI and/or BLACS!"
     call MPI_FINALIZE(err)
     stop
  end if

  ! Allocate my matrices now
   ml = numroc(ln, lnbrow, myrow, zeroI, lnprow)
   nl = numroc(ln, lnbrow, mycol, zeroI, lnpcol)
   llda = ml

   call descinit(desca, ln, ln, lnbrow, lnbrow, zeroI, zeroI, ctxt_sys, llda, info)
  
   allocate( a_ref(ml,nl) )
   allocate( a_sym(ml,nl) )
   allocate( z(ml,nl) )
   allocate( w(ln) )

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

!  write(6,*) iseed, numEle
   call zlarnv(oneI, iseed, numEle, a_ref)
   call transpose_matrix("L", ln, a_ref, a_sym, desca)
   ! call zlarnv(oneI, iseed, numEle, z)      ! might not be necessary

  end if

   a_ref = a_sym

! do i=1, ml
!    do j=1, ml
!       write(6,*) "rank=", rank, "a_ref(",i,j,")=", a_ref(i,j)
!    end do
! end do

   t1 = MPI_WTIME()

   call pzheevd(jobz, uplo, ln, a_sym, ia, ja, desca, w, z, iz, jz, desca, temp, moneI, rtemp, moneI, liwork, moneI, info)
   lwork     = temp(1)
   allocate( work(lwork) )
   lrwork    = rtemp(1)
   allocate( rwork(lrwork) )
   allocate( iwork(liwork) )
   call pzheevd(jobz, uplo, ln, a_sym, ia, ja, desca, w, z, iz, jz, desca, work, lwork, rwork, lrwork, iwork, liwork, info)
   if (info /= 0) then
      write(6,*) "PZHEEVD returned non-zero info val of ", info
   end if

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

   call MPI_Comm_rank(MPI_COMM_WORLD, my_rank, ierror)
   call blacs_gridexit(ctxt_sys)
   call blacs_exit(zeroI)

   ! only serial
   !XXX a_ref = MATMUL( TRANSPOSE(CONJG(z)), MATMUL(a_ref, z) )
   !XXX do i = 1, ln 
   !XXX   do j = i, ln
   !XXX     write(1000,*) i, j, a_ref(i,j), a_ref(j,i)
   !XXX   end do
   !XXX end do

   if (rank == 0) then
      print *, "PZHEEVD time: ", t2 - t1
   end if

   deallocate( a_sym )
   deallocate( a_ref, z, w )
   deallocate( work, rwork, iwork )

end program pzheevd_test

