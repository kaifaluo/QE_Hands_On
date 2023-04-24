      module check
        use mpi

        implicit none
  
        private 
   
        public :: check_results, make_it_diag_dominant
        public :: read_matrix

        complex(kind=8), parameter :: zero = (0.0D+00,0.0D+00)
        complex(kind=8), parameter :: one = (1.0D+00,0.0D+00)

        contains 

       subroutine check_results(n_basis,n_states,mat,eval,evec,desc,&
                                nprow, npcol, myprow, mypcol, myid, comm)
        integer :: n_basis,n_states
        complex(kind=8), allocatable :: mat(:,:), evec(:,:)
        double precision, allocatable :: eval(:)
        integer :: desc(9)
        integer :: nprow, npcol, myprow, mypcol
        integer :: myid,comm

        complex(kind=8), allocatable :: tmp(:,:), tmp_evec(:,:)
        complex(kind=8), allocatable :: m_diag(:)
        complex(kind=8) :: aux, aux_1
        double precision :: myerr, err1, err2
        integer :: nrow, ncol, i, ierr
        integer :: irow_local, icol_local, iprow, ipcol

        character(len=256) :: tmp_str

        ! check if check are wanted
        call get_environment_variable("BGW_SKIP_CHECK", tmp_str)
        if (len_trim(tmp_str)>0) then
          if ((tmp_str(1:1)=='t').or.(tmp_str(1:1)=='T').or.(tmp_str(1:1)=='y').or.&
          (tmp_str(1:1)=='Y').or.(tmp_str(1:1)=='1')) then
            if ( myid == 0 ) then 
              write(*,*) &
          "Skipping the check, export BGW_SKIP_CHECK=0 to activate."
              write(*,*)
            end if
            return
          endif
        endif


        nrow = size(evec, 1)
        ncol = size(evec, 2)

        allocate(tmp(nrow,ncol))
        tmp = zero
        aux = zero

        allocate(tmp_evec(nrow,ncol))
        tmp_evec = zero

          ! Check C^H A C - lambda
          call pzgemm("N","N",n_basis,n_states,n_basis,one,mat,1,1,desc,evec,1,1,desc,&
               zero,tmp,1,1,desc)

          call pzgemm("C","N",n_states,n_states,n_basis,one,evec,1,1,desc,&
                      tmp,1,1,desc,zero,tmp_evec,1,1,desc)

          allocate(m_diag(n_states))
          m_diag = zero
          do i =1, n_states
            CALL infog2l(i, i, desc, nprow, npcol, myprow, mypcol, &
                         irow_local, icol_local, iprow, ipcol)
            if ((iprow == myprow) .and. (ipcol == mypcol)) then
              m_diag(i)=tmp_evec(irow_local, icol_local)
            end if
          end do
 
          call MPI_Allreduce(MPI_IN_PLACE, m_diag, n_states, MPI_DOUBLE_COMPLEX,&
                             MPI_SUM, comm, ierr)

          myerr = 0.0D+00
          do i = 1,n_states
             !XX if ( myid == 0) write(*,*) m_diag(i), eval(i), dble(m_diag(i))-eval(i)
             myerr = max(myerr,(dble(m_diag(i))-eval(i)))
          end do

          err1 = myerr
          ! call MPI_Reduce(myerr,err1,1,MPI_REAL8,MPI_MAX,0,comm,ierr)

          ! Check I - C^T C
          tmp = zero

          call pzlaset("U",n_states,n_states,zero,one,tmp,1,1,desc)
          call pzherk("U","C",n_states,n_basis,-one,evec,1,1,desc,one,tmp,1,1,desc)

          myerr = maxval(abs(tmp))

          call MPI_Reduce(myerr,err2,1,MPI_REAL8,MPI_MAX,0,comm,ierr)

          if(myid == 0) then
             write(*,"(2X,A,E10.2)") "| Error (C^H A C - a) :",err1
             write(*,"(2X,A,E10.2)") "| Error (C^H C - I)   :",err2
             if(err1 > 1.0D-9 .or. err2 > 1.0D-11) then
                write(*,"(2X,A)") "Failed!!"
             end if
             write(*,*)
          end if

        end subroutine

        subroutine make_it_diag_dominant(mat, n, desc, scal, nprow, npcol, myprow, mypcol)
          complex(kind=8), allocatable :: mat(:,:)
          real(kind=8) :: scal
          integer :: n, desc(9), nprow, npcol, myprow, mypcol
          integer :: i, irow_local, icol_local, iprow, ipcol

          do i =1, n
            CALL infog2l(i, i, desc, nprow, npcol, myprow, mypcol, &
                         irow_local, icol_local, iprow, ipcol)
            if ((iprow == myprow) .and. (ipcol == mypcol)) then
              mat(irow_local, icol_local) = mat(irow_local, icol_local) * scal
            end if
          end do

        end subroutine make_it_diag_dominant

        subroutine read_matrix(unt, n, mat, b_row, b_col, nprow, npcol, myrow, mycol)
          integer :: unt, n
          complex(kind=8), allocatable :: mat(:,:)
          integer :: b_row, b_col, nprow, npcol, myrow, mycol
          
          integer :: icol_block, icol, icol_start, icol_end
          integer :: irow_block, irow, irow_start, irow_end
          integer :: ic_loc, cc
          integer :: ir_loc
          complex(kind=8), allocatable :: mat_col_block(:,:)
          
          allocate( mat_col_block(n,b_col) )
          mat_col_block = zero

          read(unt)
          ic_loc = 0
          do icol_block = 1, n, b_col*npcol
            icol_start = icol_block
            icol_end   = min(icol_block + b_col * mycol - 1, n)
            do icol = icol_start, icol_end
              read(unt)
            end do
            icol_start = icol_end + 1
            icol_end   = min(icol_start+b_col-1, n)
            cc = 0
            do icol = icol_start, icol_end
              cc = cc + 1
              read(unt) mat_col_block(:,cc)
            end do

            ! now copy the rows
            do cc = 1, icol_end-icol_start+1
              ic_loc = ic_loc + 1 
              ir_loc = 0
              do irow_block = myrow*b_row+1, n, b_row*nprow
                irow_start = irow_block
                irow_end   = min(irow_block+b_row-1,n)
                do irow = irow_start, irow_end
                  ir_loc = ir_loc+1
                  mat(ir_loc,ic_loc) = mat_col_block(irow,cc)
                end do
              end do
            end do

            icol_start = icol_end + 1
            icol_end   = min(icol_block + b_col*npcol - 1, n)
            do icol = icol_start, icol_end
              read(unt)
            end do
          end do

          deallocate( mat_col_block )

        end subroutine read_matrix
 
      end module check
