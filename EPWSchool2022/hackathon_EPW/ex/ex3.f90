program ex3

  use kinds, only : DP
  USE mp_global, ONLY : mp_startup, mp_global_end
  USE io_files, ONLY : tmp_dir, prefix
  USE wavefunctions, ONLY : evc
  USE pw_restart_new, ONLY : read_collected_wfc
  USE klist, ONLY : nks, ngk, igk_k
  USE io_files, ONLY : restart_dir
  USE wvfct, ONLY : nbnd, npwx
  USE fft_base, ONLY : dffts
  USE noncollin_module, ONLY : npol
  USE fft_interfaces, ONLY : invfft
  USE gvect, ONLY : ig_l2g
  USE mp_pools, only : intra_pool_comm

  implicit none

  LOGICAL :: needwf = .TRUE.
  integer :: ik, ikq, ipw, ib1, ib2, ir, npwg
  INTEGER,  ALLOCATABLE :: igk_l2g(:,:)
  real(dp) :: sum
  complex(dp), allocatable :: evck(:,:), evckq(:,:), evcrk(:,:), evcrkq(:,:), evctemp(:,:)


  CALL mp_startup( start_images=.TRUE. )
  prefix = 'si'
  tmp_dir = './4p2k/'
  CALL read_file_new ( needwf )

  allocate ( evctemp(npwx * npol, nbnd) )
  ALLOCATE ( evcrk(dffts%nnr,npol) )
  ALLOCATE ( evcrkq(dffts%nnr,npol) )
  ALLOCATE ( igk_l2g(npwx,2) )
  igk_l2g = 0

  ik = 1
  ikq = 2

  print *, ngk(ik), ngk(ikq)

  do ipw = 1, ngk(ik)
     write(6,'(a,i5,2x,", ",a,i5)') '(ik) ipw=', ipw, 'igk_k(ipw,ik)=', igk_k(ipw,ik)
     igk_l2g(ipw,ik) = ig_l2g(igk_k(ipw,ik))
  enddo

  do ipw = 1, ngk(ikq)
     write(6,'(a,i5,2x,", ",a,i5)') '(ikq) ipw=', ipw, 'igk_k(ipw,ikq)=', igk_k(ipw,ikq)
     igk_l2g(ipw,ikq) = ig_l2g(igk_k(ipw,ikq))
  enddo
  npwg = MAXVAL( igk_l2g )

  print *, npwg

  allocate ( evck(npwg * npol, nbnd) )
  allocate ( evckq(npwg * npol, nbnd) )
  evck = (0.d0, 0.d0)
  evckq = (0.d0, 0.d0)

  CALL read_collected_wfc ( restart_dir(), ik, evc )
  CALL read_collected_wfc ( restart_dir(), ikq, evctemp )

  do ib1 = 1, nbnd
!!!!!!!!!!!!!!!!!! The part below is wrong!
     do ipw = 1, ngk(ikq)
        !!evckq(ipw,ib1) = evctemp(ipw,ib1)
        evckq(igk_k(ipw,ikq),ib1) = evctemp(ipw,ib1)
     enddo
!!!!!!!!!!!!!!!!!!
     evcrkq = (0.d0, 0.d0)
     do ipw = 1, ngk(ikq)
        evcrkq(dffts%nl(igk_k(ipw,ikq)),1) = evctemp(ipw,ib1)
     enddo
     CALL invfft ('Wave', evcrkq(:,1), dffts)

     do ib2 = 1, nbnd
!!!!!!!!!!!!!!!!!! The part below is wrong!
        do ipw = 1, ngk(ik)
           !!evck(ipw,ib2) = evc(ipw,ib2)
           evck(igk_k(ipw,ik),ib2) = evc(ipw,ib2)
        enddo
!!!!!!!!!!!!!!!!!!
        evcrk = (0.d0, 0.d0)
        do ipw = 1, ngk(ik)
           evcrk(dffts%nl(igk_k(ipw,ik)),1) = evc(ipw,ib2)
        enddo
        CALL invfft ('Wave', evcrk(:,1), dffts)

        sum = 0.d0
        do ipw = 1, npwg
           sum = sum + conjg(evckq(ipw, ib1)) * evck(ipw,ib2)
        enddo

        write(6, '("(G-space) ikq=", i5, ", ik=", i5, ", ib1=", i5, ", ib2=", i5, ": norm=",f12.6)') &
              ik, ikq, ib1, ib2, sum

        sum = 0.d0
        do ir = 1, dffts%nnr
           sum = sum + conjg(evcrkq(ir,1)) * evcrk(ir,1) * 1/dffts%nnr
        enddo
        write(6, '("(r-space) ikq=", i5, ", ik=", i5, ", ib1=", i5, ", ib2=", i5, ": norm=",f12.6)') &
              ik, ikq, ib1, ib2, sum

     enddo
     write(6,*)
  enddo

  CALL mp_global_end()

end program ex3
