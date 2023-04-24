program ex4

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
  USE fft_interfaces, ONLY : invfft, fwfft
  USE gvect, ONLY : ig_l2g
  USE mp_pools, only : intra_pool_comm

  implicit none

  LOGICAL :: needwf = .TRUE.
  integer :: ik, ikq, ipw, ib1, ib2, ir
  real(dp) :: sum
  real(dp), allocatable :: v(:)
  complex(dp), allocatable :: evck(:,:), evckq(:,:), evcrk(:,:), evcrkq(:,:), &
                              vpsi(:), vpsitemp(:)


  CALL mp_startup( start_images=.TRUE. )
  prefix = 'si'
  tmp_dir = './4p2k/'
  CALL read_file_new ( needwf )

  ALLOCATE ( v(dffts%nnr) )
  call random_number(v)

  ALLOCATE ( vpsi(dffts%nnr) )
  ALLOCATE ( vpsitemp(npwx) )

  allocate ( evckq(npwx * npol, nbnd) )
  ALLOCATE ( evcrk(dffts%nnr,npol) )
  ALLOCATE ( evcrkq(dffts%nnr,npol) )

  ik = 1
  ikq = 2

  print *, ngk(ik), ngk(ikq)

  CALL read_collected_wfc ( restart_dir(), ik, evc )
  CALL read_collected_wfc ( restart_dir(), ikq, evckq )

  do ib1 = 1, nbnd
     evcrkq = (0.d0, 0.d0)
     do ipw = 1, ngk(ikq)
        evcrkq(dffts%nl(igk_k(ipw,ikq)),1) = evckq(ipw,ib1)
     enddo
     CALL invfft ('Wave', evcrkq(:,1), dffts)

     do ib2 = 1, nbnd
        evcrk = (0.d0, 0.d0)
        do ipw = 1, ngk(ik)
           evcrk(dffts%nl(igk_k(ipw,ik)),1) = evc(ipw,ib2)
        enddo
        CALL invfft ('Wave', evcrk(:,1), dffts)

!!!!!!!!!!!!!!!!!! The part below is wrong!
        DO ir = 1, dffts%nnr
           !vpsi(ir) = v(ir)
           vpsi(ir)  = v(ir)*evcrk(ir,1)
        ENDDO
!!!!!!!!!!!!!!!!!! The part below is wrong!

        sum = 0.d0
        do ir = 1, dffts%nnr
           sum = sum + conjg(evcrkq(ir,1)) * vpsi(ir) * 1/dffts%nnr
        enddo
        write(6, '("(r-space) ikq=", i5, ", ik=", i5, ", ib1=", i5, ", ib2=", i5, ": <k+q|v|k>=",f12.6)') &
              ik, ikq, ib1, ib2, sum

        CALL fwfft ('Wave', vpsi, dffts)
        vpsitemp = 0.d0
        DO ipw = 1, ngk(ikq)
           vpsitemp(ipw) = vpsitemp(ipw) + vpsi(dffts%nl(igk_k(ipw,ikq)))
        ENDDO

        sum = 0.d0
        do ipw = 1, ngk(ikq)
           sum = sum + conjg(evckq(ipw, ib1)) * vpsitemp(ipw)
        enddo
        write(6, '("(G-space) ikq=", i5, ", ik=", i5, ", ib1=", i5, ", ib2=", i5, ": <k+q|v|k>=",f12.6)') &
              ik, ikq, ib1, ib2, sum

     enddo
     write(6,*)
  enddo

  CALL mp_global_end()

end program ex4
