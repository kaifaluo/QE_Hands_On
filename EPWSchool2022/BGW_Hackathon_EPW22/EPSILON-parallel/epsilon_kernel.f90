       PROGRAM sigma_kernel
       USE peinfo_module
       ! USE format_type
       USE timing
       IMPLICIT NONE
       ! constants
       DOUBLE COMPLEX, PARAMETER :: ZERO = (0.0D+00, 0.0D+00)
       ! input parameters
       INTEGER, PARAMETER :: Nparam = 8
       INTEGER :: nspin, nval, ntotal_bands, nmtx, nproc_pool, Nprow, &
                  Npcol, Nrep
       INTEGER :: temp_param(Nparam)
       ! actual parameters for the calculation
       INTEGER :: ncol_local, nrow_local, ntband_dist, NUMROC
       DOUBLE COMPLEX, ALLOCATABLE :: gmer(:,:), gmec(:,:)
       DOUBLE COMPLEX, ALLOCATABLE :: gmetempr(:,:), gmetempc(:,:), chilocal(:,:)
       ! DOUBLE COMPLEX, ALLOCATABLE :: mat_left(:,:,:), mat_right(:,:,:)
       ! DOUBLE COMPLEX, ALLOCATABLE :: aqsntemp(:,:), aqsmtemp(:,:)
       ! local variables
       INTEGER, ALLOCATABLE :: seed(:)
       INTEGER :: iii, jjj, kkk, seed_size, my_seed, ipe, ipe_inx, itime
       INTEGER :: ispin, ii, jj
       DOUBLE PRECISION, ALLOCATABLE :: temp1(:,:,:)
       DOUBLE PRECISION :: t1, t2, mem_wfn, mem_eps, mem_buf
       ! Non-blocking cyclic
       integer :: ipe_real
       integer :: isend_static, irec_static
       integer :: actual_send, actual_rec
       integer :: nsend_row, nsend_col, nrec_row, nrec_col
       integer :: req_send, tag_send, req_rec, tag_rec
       integer :: stat(MPI_STATUS_SIZE)
       DOUBLE COMPLEX, allocatable :: buf_send(:,:,:), buf_rec(:,:,:), &
                                      buf_temp(:,:,:)
       integer :: loop_itype
       logical :: has_been_sent
       logical :: dealloc_buf
       !
       INTEGER :: resultlen
       INTEGER, ALLOCATABLE :: node_id(:)
       CHARACTER (len=8) :: my_name
       CHARACTER (len=5) :: my_name_num
       INTEGER :: pe_bsize
       !
       double precision, allocatable :: t_zgemm_tot(:,:)
       double precision :: t_loop_local_1, t_loop_local_2
       logical :: simulate_load_imbalance
       integer :: kkk_unbal


       ! initialize MPI
       CALL peinfo_init()

       ! initialize timings
       CALL time_init()

       CALL MPI_Barrier(MPI_COMM_WORLD, mpierr)
       CALL CPU_TIME(t1)
       CALL time_start(1)

       dealloc_buf = .FALSE.
       simulate_load_imbalance = .TRUE.

       IF(peinf%inode==0) THEN
         WRITE(*,*) 'Parallel Setups'
         WRITE(*,*) 'Number of MPI tasks:', peinf%npes
         WRITE(*,*) 'Number of OMP threads:', peinf%nthreads
         WRITE(*,*) 'Mepos:', peinf%inode
       END IF

       ! READ INPUT
       IF(peinf%inode==0) THEN
         !XXX nspin, nval, ntotal_bands, nmtx, nproc_pool, Nprow, Npcol, Nrep
         READ(*,*) nspin
         READ(*,*) nval
         READ(*,*) ntotal_bands
         READ(*,*) nmtx
         READ(*,*) nproc_pool
         READ(*,*) Nprow
         READ(*,*) Npcol
         READ(*,*) Nrep
         temp_param(1) = nspin
         temp_param(2) = nval
         temp_param(3) = ntotal_bands
         temp_param(4) = nmtx
         temp_param(5) = nproc_pool
         temp_param(6) = Nprow
         temp_param(7) = Npcol
         temp_param(8) = Nrep
       END IF

       CALL MPI_BCAST(temp_param, Nparam, MPI_INTEGER, 0, peinf%mpi_comm, mpierr)

       nspin         =  temp_param(1)
       nval          =  temp_param(2)
       ntotal_bands  =  temp_param(3)
       nmtx          =  temp_param(4)
       nproc_pool    =  temp_param(5)
       Nprow         =  temp_param(6)
       Npcol         =  temp_param(7)
       Nrep          =  temp_param(8)

       IF(peinf%inode==0) THEN
         WRITE(*,*)
         WRITE(*,*) 'Number of spin: ',          nspin
         WRITE(*,*) 'Total Number of valence: ', nval
         WRITE(*,*) 'Total Number of bands: ',   ntotal_bands
         WRITE(*,*) 'Size of Epsilon Matrix:',   nmtx
         WRITE(*,*) 'Number of MPI tasks Simulated:', nproc_pool 
         WRITE(*,*) 'Number of row proc:', Nprow
         WRITE(*,*) 'Number of col proc:', Npcol
         WRITE(*,*) 'Number of Repetitions: ', nrep
       END IF

       if(Nprow * Npcol /= nproc_pool) STOP "PROC Layout do not match!"

       !XXX ! compute with scalapack
       !XXX ngpown = NUMROC(ncouls, 32, peinf%inode, 0, nproc_pool)
       !XXX WRITE(*,*) ngpown

       ! calculate actual parameters 
       ! number of column of epsilon hold by the actual proc
       nrow_local = (nmtx-1) / nprow + 1
       ncol_local = (nmtx-1) / npcol + 1
       ! number of bands hold by actual proc 
       ntband_dist = ((ntotal_bands-nval) * nval - 1 ) / nproc_pool + 1

       IF(peinf%inode==0) THEN
         WRITE(*,*) 'Number of Distrib Nval*Ncond:',  ntband_dist 
         WRITE(*,*) 'SQRT of Distrib Nval*Ncond:', INT(SQRT(DBLE(ntband_dist)))
         WRITE(*,*) 'Number of Distrb Col:', nrow_local
         WRITE(*,*) 'Number of Distrb Col:', ncol_local
         WRITE(*,*) 'Size send/recv buffers:', &
                   DBLE(nrow_local)*DBLE(ncol_local)*16.0D+00 / 1024.0D+00, 'Kb'
         WRITE(*,*)
       END IF

       ! initialize random
       CALL RANDOM_SEED(size = seed_size)
       ALLOCATE(seed(seed_size))
       my_seed = 10
       seed = my_seed + 37 * (/ (iii - 1, iii = 1, seed_size) /)
       CALL RANDOM_SEED(PUT = seed)
       DEALLOCATE(seed)

        ! start calculation
        ALLOCATE(gmer (nrow_local, ntband_dist))
        ALLOCATE(gmec (ntband_dist, ncol_local))

        ! fill in with random number 
        ! Here we have probably to play with OMP memory affinity
        DO jjj = 1, ntband_dist
          DO iii = 1, nrow_local
            gmer(iii,jjj) = ZERO
          END DO
        END DO
        DO jjj = 1, ncol_local
          DO iii = 1, ntband_dist 
            gmec(iii,jjj) = ZERO
          END DO
        END DO
        ! 
        ALLOCATE(temp1(2,MAX(nrow_local,ntband_dist),MAX(ntband_dist,ncol_local)))
        CALL RANDOM_NUMBER(temp1)
        !$OMP PARALLEL DO collapse(2)
        DO jjj = 1, ntband_dist
          DO iii = 1, nrow_local
            gmer(iii,jjj) = CMPLX(temp1(1,iii,jjj),temp1(2,iii,jjj))
          END DO
        END DO 
        CALL RANDOM_NUMBER(temp1)
        !$OMP PARALLEL DO collapse(2)
        DO jjj = 1, ncol_local
          DO iii = 1, ntband_dist
            gmec(iii,jjj) = CMPLX(temp1(1,iii,jjj),temp1(2,iii,jjj))
          END DO
        END DO
        DEALLOCATE(temp1)

        mem_buf =  DBLE(nspin) * DBLE(ncol_local) * DBLE(nrow_local) * &
                   16.0D+00 /1024D+00/1024D+00

        IF(peinf%inode==0) THEN
          ! WRITE(*,*) 'Size of communication buffer:', mem_buf,'Mb'
          ! WRITE(*,*) 'Memory for execution:', mem_eps + 4.0*mem_wfn + mem_buf
          WRITE(*,*) 
        END IF

        CALL CPU_TIME(t_loop_local_1)
        do loop_itype = 1, 3

        ! initialize
        isend_static = MOD(peinf%inode + 1 + peinf%npes, peinf%npes)
        irec_static = MOD(peinf%inode - 1 + peinf%npes, peinf%npes)
        ! allocate my size for the first send
        nsend_row = nrow_local
        nsend_col = ncol_local
        nrec_row  = nrow_local
        nrec_col  = ncol_local
        ALLOCATE(buf_send (nsend_row, nsend_col, nspin))
        do ispin = 1 , nspin
          !$OMP PARALLEL DO collapse(2)
          do ii = 1, nsend_col
            do jj = 1, nsend_row
              buf_send(jj,ii,ispin) = ZERO
            enddo
          enddo
        end do

        IF ( .NOT. dealloc_buf ) THEN
          ALLOCATE(buf_rec ( nsend_row, nsend_col, nspin ))
          do ispin = 1 , nspin
            !$OMP PARALLEL DO collapse(2)
            do ii = 1, nsend_col
              do jj = 1, nsend_row
                buf_rec(jj,ii,ispin) = ZERO
              enddo
            enddo
          end do

          ALLOCATE(chilocal (nrec_row, nrec_col))
          !$OMP PARALLEL DO collapse(2)
          do ii = 1, nrec_col
            do jj = 1, nrec_row
              chilocal(jj,ii)=ZERO
            enddo
          enddo

          ALLOCATE(buf_temp (nrec_row, nrec_col, nspin))
          do ispin = 1 , nspin
            !$OMP PARALLEL DO collapse(2)
            do ii = 1, nrec_col
              do jj = 1, nrec_row
                buf_temp(jj,ii,ispin) = ZERO
              enddo
            enddo
          end do

          ALLOCATE(gmetempr (nrec_row, ntband_dist))
          ALLOCATE(gmetempc (ntband_dist, nrec_col))
          !$OMP PARALLEL DO collapse(2)
          DO jjj = 1, ntband_dist
            DO iii = 1, nrow_local
              gmetempr(iii,jjj) = ZERO
            END DO
          END DO
          !$OMP PARALLEL DO collapse(2)
          DO jjj = 1, ncol_local
            DO iii = 1, ntband_dist
              gmetempc(iii,jjj) = ZERO
            END DO
          END DO

        END IF

        !XXX CALL MPI_Barrier(MPI_COMM_WORLD, mpierr)
        !XXX do ii = 0, peinf%npes - 1
        !XXX   IF( ii == peinf%inode ) THEN
        !XXX     WRITE(6,*) peinf%inode, irec_static, isend_static
        !XXX     FLUSH(6)
        !XXX   END IF
        !XXX   CALL MPI_Barrier(MPI_COMM_WORLD, mpierr)
        !XXX end do
        !XXX CALL MPI_Barrier(MPI_COMM_WORLD, mpierr)

        if( loop_itype == 3 .OR. loop_itype == 2 ) then
          do ispin = 1 , nspin
          !$OMP PARALLEL DO collapse(2)
            do ii = 1, nsend_col
              do jj = 1, nsend_row
                buf_send(jj,ii,ispin) = &
                  CMPLX(1D0/dble(ii),1D0/dble(jj))*DBLE(peinf%inode)/DBLE(ispin)
              enddo
            enddo
          end do
        end if

        IF( loop_itype == 1 ) THEN
          IF(peinf%inode==0) THEN
            WRITE(*,*) 'Start loop over Nrep/proc'
          END IF
        ELSE
          IF(peinf%inode==0) THEN
            IF( loop_itype == 2) THEN
              WRITE(*,*) 'Only Communication Loop'
            ELSE
              WRITE(*,*) 'Communication SENDRECV'
            END IF
          END IF
        END IF

        DO ipe = 1, Nrep

          if( loop_itype == 2 ) then
            nrec_row = nrow_local  ! scal%nprd(actual_rec+1)
            nrec_col = ncol_local  ! scal%npcd(actual_rec+1)
            ! allocate reciving buffer
            IF( dealloc_buf ) ALLOCATE(buf_rec (nrec_row, nrec_col, nspin))
            do ispin = 1 , nspin
              !$OMP PARALLEL DO collapse(2)
              do ii = 1, nrec_col
                do jj = 1, nrec_row
                  buf_rec(jj,ii,ispin) = ZERO
                enddo
              enddo
            end do
            !
            call time_start(7) ! total comm
            call time_start(8) ! post
          CALL MPI_Irecv(buf_rec, nrec_row*nrec_col*nspin,MPI_DOUBLE_COMPLEX,irec_static,&
                         tag_rec, MPI_COMM_WORLD, req_rec, mpierr)
          CALL MPI_Isend(buf_send, nsend_row*nsend_col*nspin,MPI_DOUBLE_COMPLEX,isend_static,&
                         tag_send, MPI_COMM_WORLD, req_send, mpierr)
            call time_stop(7)  ! post
            call time_stop(8)  ! total
            !
            call time_start(7) ! total comm
            call time_start(9) ! wait
          CALL MPI_Wait(req_rec,stat,mpierr)
            call time_stop(7)
            call time_stop(9)
            !
            call time_start(7) ! total comm
            call time_start(9) ! wait
          CALL MPI_Wait(req_send,stat,mpierr)
            call time_stop(7)
            call time_stop(9)
            !
            buf_send = buf_rec
            IF( dealloc_buf ) DEALLOCATE(buf_rec)
            !
            CYCLE
            !
          end if

          if( loop_itype == 3 ) then
            nrec_row = nrow_local  ! scal%nprd(actual_rec+1)
            nrec_col = ncol_local  ! scal%npcd(actual_rec+1)
            ! allocate reciving buffer
            IF( dealloc_buf ) ALLOCATE(buf_rec (nrec_row, nrec_col, nspin))
            do ispin = 1 , nspin
              !$OMP PARALLEL DO collapse(2)
              do ii = 1, nrec_col
                do jj = 1, nrec_row
                  buf_rec(jj,ii,ispin) = ZERO
                enddo
              enddo
            end do
            ! send and recv
            tag_rec = 1
            tag_send = 1
            call time_start(10)
            CALL MPI_Sendrecv(buf_send, nrec_row*nrec_col*nspin, &
                              MPI_DOUBLE_COMPLEX, isend_static, tag_send, &
                              buf_rec, nrec_row*nrec_col*nspin, &
                              MPI_DOUBLE_COMPLEX, irec_static, tag_rec, &
                              MPI_COMM_WORLD, stat, mpierr)
            call time_stop(10)

            buf_send = buf_rec
            IF( dealloc_buf ) DEALLOCATE(buf_rec)
            !
            CYCLE
            !
          end if

          ! initialize
          actual_send = MOD(peinf%inode + ipe + peinf%npes, peinf%npes)
          actual_rec  = MOD(peinf%inode - ipe + peinf%npes, peinf%npes)
          nrec_row = nrow_local  ! scal%nprd(actual_rec+1)
          nrec_col = ncol_local  ! scal%npcd(actual_rec+1)
          ! allocate reciving buffer
          call time_start(12)
          IF( dealloc_buf )  ALLOCATE(buf_rec (nrec_row, nrec_col, nspin))
          call time_stop(12)
          call time_start(13)
          do ispin = 1 , nspin
            !$OMP PARALLEL DO collapse(2)
            do ii = 1, nrec_col
              do jj = 1, nrec_row
                buf_rec(jj,ii,ispin) = ZERO
              enddo
            enddo
          end do
          call time_stop(13)
          ! post
          tag_rec = 1
          tag_send = 1
          req_rec = MPI_REQUEST_NULL
          req_send = MPI_REQUEST_NULL
          IF( loop_itype == 1 ) THEN
            call time_start(4) ! total comm
            call time_start(5) ! post
          ELSE
            call time_start(7) ! total comm
            call time_start(8) ! post
          END IF
          CALL MPI_Irecv(buf_rec, nrec_row*nrec_col*nspin,MPI_DOUBLE_COMPLEX,irec_static,&
                         tag_rec, MPI_COMM_WORLD, req_rec, mpierr)
          CALL MPI_Isend(buf_send, nsend_row*nsend_col*nspin,MPI_DOUBLE_COMPLEX,isend_static,&
                         tag_send, MPI_COMM_WORLD, req_send, mpierr)
          IF( loop_itype == 1 ) THEN
            call time_stop(5)  ! post
            call time_stop(4)  ! total
          ELSE
            call time_stop(7)  ! post
            call time_stop(8)  ! total
          END IF
          ! test
          !XXX IF( loop_itype == 1 ) THEN
          !XXX   call time_start(4)
          !XXX   CALL time_start(11)
          !XXX   has_been_sent = .false.
          !XXX   CALL MPI_TEST(req_send, has_been_sent, stat, mpierr)
          !XXX   CALL time_stop(11)
          !XXX   call time_stop(4)
          !XXX   IF(peinf%inode == 0) THEN
          !XXX     WRITE(*,*) has_been_sent
          !XXX   END IF
          !XXX END IF
          ! allocate stuff
          call time_start(12)
          IF( dealloc_buf ) ALLOCATE(chilocal (nrec_row, nrec_col))
          call time_stop(12)

          call time_start(13)
!$OMP PARALLEL DO collapse(2)
          do ii = 1, nrec_col
            do jj = 1, nrec_row
              chilocal(jj,ii)=ZERO
            enddo
          enddo
          call time_stop(13)

          call time_start(12)
          IF( dealloc_buf ) ALLOCATE(buf_temp (nrec_row, nrec_col, nspin))
          call time_stop(12)

          call time_start(13)
          do ispin = 1 , nspin
!$OMP PARALLEL DO collapse(2)
            do ii = 1, nrec_col
              do jj = 1, nrec_row
                buf_temp(jj,ii,ispin) = ZERO
              enddo
            enddo
          end do
          call time_stop(13)

          call time_start(12)
          IF( dealloc_buf ) THEN
            ALLOCATE(gmetempr (nrec_row, ntband_dist))
            ALLOCATE(gmetempc (ntband_dist, nrec_col))
          END IF
          call time_stop(12)
          ipe_real = actual_rec+1

          ! fill buffer
          call time_start(14)
!$OMP PARALLEL DO collapse(2)
          DO jjj = 1, ntband_dist
            DO iii = 1, nrow_local
              gmetempr(iii,jjj) = gmer(iii,jjj) 
            END DO
          END DO
!$OMP PARALLEL DO collapse(2)
          DO jjj = 1, ncol_local
            DO iii = 1, ntband_dist
              gmetempc(iii,jjj) = gmec(iii,jjj) 
            END DO
          END DO
          call time_stop(14)

          do ispin = 1, nspin
            IF( loop_itype == 1 ) THEN
              ! go with ZGEMM
              call time_start(2)
              ! 
              ! CALL MPI_Barrier(MPI_COMM_WORLD, mpierr)
              ! 
              !XXXXX
              ! Artificially make one task to underperform 10%
              if ( MOD(peinf%inode,2) == 0 .and. simulate_load_imbalance ) then
                kkk_unbal = ntband_dist / (5 * (peinf%inode+1))
                kkk_unbal = MAX(kkk_unbal,1)
                call zgemm('n','n', nrow_local, ncol_local, kkk_unbal, &
                (-1D0,0D0),gmetempr(:,:), nrow_local, gmetempc(:,:), kkk_unbal,&
                (0D0,0D0), chilocal(:,:), nrow_local)
              end if
              !XXXXX
              ! 
              CALL acc_perf_zgemm(0, 0, 0, 0)
              call zgemm('n','n', nrow_local, ncol_local, ntband_dist, &
                (-1D0,0D0),gmetempr(:,:), nrow_local, gmetempc(:,:), ntband_dist,&
                (0D0,0D0), chilocal(:,:), nrow_local)
              CALL acc_perf_zgemm(1, nrow_local, ncol_local, ntband_dist) 
              ! CALL MPI_Barrier(MPI_COMM_WORLD, mpierr)
              ! 
              call time_stop(2)

              IF(peinf%inode == 0) THEN
                IF(ipe == 1 .AND. ispin == 1) THEN
                  WRITE(*,*) "N = ", nrow_local
                  WRITE(*,*) "M = ", ncol_local
                  WRITE(*,*) "K = ", ntband_dist
                END IF
     WRITE(*,*) "Cycle:", ipe, " ZGEMM Time (s):",time_zgemm, &
        " Performance MPI task 0 (GFLOP/s):",&
        flops_zgemm / time_zgemm / 1000D+00 / 1000D+00 / 1000D+00
              END IF
            END IF

            call time_start(14)
!$OMP PARALLEL DO collapse(2)
            do ii = 1, nrec_col
              do jj = 1, nrec_row
                buf_temp(jj,ii,ispin) = chilocal(jj,ii)
              enddo
            enddo
            call time_stop(14)

          end do ! ispin

          call time_start(12)
          IF( dealloc_buf ) THEN
            DEALLOCATE(chilocal)
            DEALLOCATE(gmetempr)
            DEALLOCATE(gmetempc)
          END IF
          call time_stop(12)

          ! receive mex
          IF( loop_itype == 1 ) THEN
            call time_start(4) ! total comm
            call time_start(6) ! wait
          ELSE
            call time_start(7) ! total comm
            call time_start(9) ! wait
          END IF
          CALL MPI_Wait(req_rec,stat,mpierr)
          IF( loop_itype == 1 ) THEN
            call time_stop(6) 
            call time_stop(4) 
          ELSE
            call time_stop(7) ! total comm
            call time_stop(9) ! wait
          END IF
          ! accumulate contribution into receiving buffer
          ! buf_rec(:,:,:) = buf_rec(:,:,:) + buf_temp
          call time_start(14)
          do ispin = 1 , nspin
!$OMP PARALLEL DO collapse(2)
            do ii = 1, nrec_col
              do jj = 1, nrec_row
                buf_rec(jj,ii,ispin) = buf_rec(jj,ii,ispin) + buf_temp(jj,ii,ispin)
              enddo
            enddo
          end do
          call time_stop(14)

          call time_start(12)
          IF( dealloc_buf ) DEALLOCATE(buf_temp)
          call time_stop(12)

          ! wait for the massage to be sent        
          IF( loop_itype == 1 ) THEN
            call time_start(4) ! total comm
            call time_start(6) ! wait
          ELSE
            call time_start(7) ! total comm
            call time_start(9) ! wait
          END IF 
          CALL MPI_Wait(req_send,stat,mpierr)
          IF( loop_itype == 1 ) THEN
            call time_stop(6)
            call time_stop(4)
          ELSE
            call time_stop(7) ! total comm
            call time_stop(9) ! wait
          END IF

          ! copy the messega to the sending buffer for the next cycle
          call time_start(12)
          IF( dealloc_buf ) THEN
            DEALLOCATE(buf_send)
            ALLOCATE(buf_send (nrec_row, nrec_col, nspin))
          END IF
          call time_stop(12)

          call time_start(14)
          do ispin = 1 , nspin
            !$OMP PARALLEL DO collapse(2)
            do ii = 1, nrec_col
              do jj = 1, nrec_row
                buf_send(jj,ii,ispin) = buf_rec(jj,ii,ispin)
              enddo
            enddo
          end do
          call time_stop(14)

          nsend_row = nrec_row
          nsend_col = nrec_col

          ! deallocate receiving buffer
          call time_start(12)
          IF( dealloc_buf ) DEALLOCATE(buf_rec)
          call time_stop(12)

        END DO ! ipe_inx
 
        ! IF( loop_itype == 1 .AND. ( .not. dealloc_buf )) THEN
        !   !XX DO iii = 0, peinf%npes-1
        !     iii = 0
        !     IF ( iii == peinf%inode ) THEN
        !       WRITE(*,*) 'Rank:', iii, 'Val:', buf_rec(nsend_row/2+1, nsend_col/2+1, 1)
        !     END IF
        !     CALL MPI_Barrier(MPI_COMM_WORLD, mpierr)
        !   !XX END DO
        ! END IF

        DEALLOCATE(buf_send)
        IF ( .NOT. dealloc_buf ) THEN
          DEALLOCATE(buf_rec)
          DEALLOCATE(chilocal)
          DEALLOCATE(buf_temp)
          DEALLOCATE(gmetempr)
          DEALLOCATE(gmetempc)
        END IF

        end do ! loop_type

        CALL CPU_TIME(t_loop_local_2)

        CALL MPI_Barrier(MPI_COMM_WORLD, mpierr)
        CALL time_stop(1)
        CALL CPU_TIME(t2)
 
        t_max = acctim
        t_min = acctim
        t_aver = acctim
 
        CALL MPI_ALLREDUCE(MPI_IN_PLACE,t_max,2*Ntime,&
                           MPI_DOUBLE_PRECISION,MPI_MAX,MPI_COMM_WORLD,mpierr)
        CALL MPI_ALLREDUCE(MPI_IN_PLACE,t_min,2*Ntime,&
                           MPI_DOUBLE_PRECISION,MPI_MIN,MPI_COMM_WORLD,mpierr)
        CALL MPI_ALLREDUCE(MPI_IN_PLACE,t_aver,2*Ntime,&
                           MPI_DOUBLE_PRECISION,MPI_SUM,MPI_COMM_WORLD,mpierr)
        t_aver = t_aver / DBLE(peinf%npes)
 
        allocate(t_zgemm_tot(2,peinf%npes))
        t_zgemm_tot = 0.0D+00
        t_zgemm_tot(1,peinf%inode+1) = acctim(2,2)
        t_zgemm_tot(2,peinf%inode+1) = t_loop_local_2-t_loop_local_1
        CALL MPI_ALLREDUCE(MPI_IN_PLACE,t_zgemm_tot,2*peinf%npes,&
                           MPI_DOUBLE_PRECISION,MPI_SUM,MPI_COMM_WORLD,mpierr)
        if ( peinf%inode == 0 ) then
          open(8,file='timings_zgemm_tot.dat')
           write(8,'(3A)') '# MPI Rank', &
                           ' ZGEMM time (s)', ' Cycle time (s) '
           do iii = 1, peinf%npes
             write(8,'(I10,2F15.3)') iii-1, t_zgemm_tot(1,iii), t_zgemm_tot(2,iii)
           end do
          close(8)
        end if
        deallocate( t_zgemm_tot )

        IF(peinf%inode==0) THEN
          WRITE(*,*) 
          WRITE(*,'(5A12)') &
               "TIME REPORT:", "MIN", "AVERAGE", "MAX", "#CALLs"
          DO iii = 1, Ntime_actual
            itime = order(iii)
            WRITE(*,'(A12,3F12.1,I12)') TRIM(routnam(itime)),&
              t_min(2,itime), t_aver(2,itime), t_max(2,itime), &
              ncount(itime)
          END DO
          !XXX WRITE(*,*)
          !XXX WRITE(*,*) TRIM(routnam(1)), acctim(1,1), acctim(2,1), ncount(1), t2 - t1
        END IF

       CALL peinfo_finalize()

       END PROGRAM 
