   MODULE timing
   IMPLICIT NONE

   PRIVATE 

   INTEGER, PARAMETER :: Ntime = 100
   INTEGER            :: ncount(Ntime)
   DOUBLE PRECISION   :: acctim(2,Ntime), tzero(2,Ntime)
   DOUBLE PRECISION   :: t_max(2,Ntime), t_min(2,Ntime), t_aver(2,Ntime)
   DOUBLE PRECISION, ALLOCATABLE   :: t_all(:,:,:)

   INTEGER, PARAMETER :: Ntime_actual = 14
   INTEGER            :: order(Ntime_actual)
   CHARACTER(len=25) :: routnam(Ntime_actual)

   DOUBLE PRECISION :: flops_zgemm, flops_zgemm_tot
   DOUBLE PRECISION :: time_zgemm, time_zgemm_tot, t0_zgemm
   INTEGER :: Ncall_zgemm

   PUBLIC :: Ntime, ncount, acctim, tzero
   PUBLIC :: Ntime_actual, order, routnam
   PUBLIC :: time_init, time_start, time_stop
   PUBLIC :: acc_perf_zgemm  
   PUBLIC :: flops_zgemm, time_zgemm, t0_zgemm
   PUBLIC :: flops_zgemm_tot, time_zgemm_tot
   PUBLIC :: Ncall_zgemm
   PUBLIC :: t_max, t_min, t_aver, t_all

   CONTAINS 

   SUBROUTINE time_init()
      
     ncount = 0
     acctim = 0.0D+00
     tzero = 0.0D+00

     t_max = 0.0D+00
     t_min = 0.0D+00
     t_aver = 0.0D+00
   
     flops_zgemm = 0.0D+00
     time_zgemm  = 0.0D+00
     t0_zgemm    = 0.0D+00
     Ncall_zgemm = 0
     flops_zgemm_tot = 0.0D+00
     time_zgemm_tot  = 0.0D+00

     routnam(1) = "TOTAL:"
     routnam(2) = "ZGEMM:"
     routnam(3) = "ZGEMM+ALLOC:"
     routnam(4) = "COMM TOTAL:"
     routnam(5) = "COMM POST:"
     routnam(6) = "COMM WAIT:"
     routnam(7) = "TEST COMM TOTAL:"
     routnam(8) = "TEST COMM POST:"
     routnam(9) = "TEST COMM WAIT:"
     routnam(10) = "SEND and RECV:"
     routnam(11) = "COMM TEST:"
     routnam(12) = "ALLOC/DEALLOC:"
     routnam(13) = "ZERO:"
     routnam(14) = "COPY:"

     order=(/ 2, 3, 12, 13, 14, 5, 6, 11, 4, 8, 9, 7, 10, 1 /)

   END SUBROUTINE time_init

   SUBROUTINE acc_perf_zgemm(icalc, N, M, K)
     INTEGER, INTENT(IN) :: icalc, N, M, K

     SELECT CASE(icalc)
       CASE(0) 
         ! initialize
         t0_zgemm = m_walltime()

       CASE(1)
         ! time
         time_zgemm = m_walltime()
         time_zgemm = time_zgemm - t0_zgemm

         ! flops
         flops_zgemm = 8.0D+00
         flops_zgemm = flops_zgemm * DBLE(N) * DBLE(K) * DBLE(M)

         ! accumulate performance
         flops_zgemm_tot = flops_zgemm_tot + flops_zgemm
         time_zgemm_tot = time_zgemm_tot + time_zgemm
         Ncall_zgemm = Ncall_zgemm + 1

     END SELECT

   END SUBROUTINE acc_perf_zgemm

   SUBROUTINE time_start(iroutine)
     INTEGER, INTENT(IN) :: iroutine

     tzero(1,iroutine) = timeget()
     tzero(2,iroutine) = m_walltime()

   END SUBROUTINE time_start

   SUBROUTINE time_stop(iroutine)
     INTEGER, INTENT(IN) :: iroutine
     DOUBLE PRECISION    :: wt1, wt2
     
     wt1 = timeget()
     wt2 = m_walltime()

     acctim(1,iroutine) = acctim(1,iroutine) + wt1 - tzero(1,iroutine)
     acctim(2,iroutine) = acctim(2,iroutine) + wt2 - tzero(2,iroutine)
     ncount(iroutine)   = ncount(iroutine) + 1

   END SUBROUTINE time_stop

   FUNCTION timeget() RESULT (wt)
    DOUBLE PRECISION   :: wt
    INTEGER :: values(8)

    CALL DATE_AND_TIME(VALUES=values)
    wt = ((values(3)*24.0d0+values(5))*60.0d0 &
          +values(6))*60.0d0+values(7)+values(8)*1.0d-3

   END FUNCTION

   FUNCTION m_walltime() RESULT (wt)
     DOUBLE PRECISION   :: wt
     INTEGER            :: count
     INTEGER, SAVE      :: count_max, count_rate, cycles = -1, &
                           last_count

     IF (cycles == -1) THEN ! get parameters of system_clock and initialise
         CALL SYSTEM_CLOCK(count_rate=count_rate,count_max=count_max)
         cycles = 0
         last_count = 0
     ENDIF

     CALL SYSTEM_CLOCK(count=count)

     ! protect against non-standard cases where time might be non-monotonous,
     ! but it is unlikely that the clock cycled (e.g. underlying system clock adjustments)
     ! i.e. if count is smaller than last_count by only a small fraction of count_max,
     ! we use last_count instead
     ! if count is smaller, we assume that the clock cycled.
     IF (count<last_count) THEN
        IF ( last_count-count < count_max / 100 ) THEN
           count=last_count
        ELSE
           cycles=cycles+1
        ENDIF
     ENDIF

     ! keep track of our history
     last_count=count

     wt = ( DBLE(count)+DBLE(cycles)*(1.0D+00+DBLE(count_max)) ) &
          / DBLE(count_rate)

   END FUNCTION m_walltime

   END MODULE
