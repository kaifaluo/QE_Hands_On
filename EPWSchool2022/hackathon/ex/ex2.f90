program ex2

  use kinds, only : DP
  USE mp_global, ONLY : mp_startup, mp_global_end
  USE io_files, ONLY : tmp_dir, prefix
  USE wavefunctions, ONLY : evc
  USE pw_restart_new, ONLY : read_collected_wfc
  USE klist, ONLY : nks, ngk, igk_k
  USE io_files, ONLY : restart_dir
  USE wvfct, ONLY : nbnd
  USE fft_base, ONLY : dffts
  USE noncollin_module, ONLY : npol
  USE fft_interfaces, ONLY : invfft

  implicit none

  LOGICAL :: needwf = .TRUE.
  integer :: ik, ipw, ib, ir
  real(dp) :: sum
  complex(dp), allocatable :: evcr(:,:)


  CALL mp_startup( start_images=.TRUE. )
  prefix = 'si'
  tmp_dir = './4p2k/'
  CALL read_file_new ( needwf )

  ALLOCATE ( evcr(dffts%nnr,npol) )
  DO ik = 1, nks
     CALL read_collected_wfc ( restart_dir(), ik, evc )
     do ib = 1, nbnd

!!!!!!!!!!!!!!!!!! The part below is wrong!
        do ipw = 1, ngk(ik)
           sum = evc(ipw, ib) * evc(ipw,ib)
        enddo
!!!!!!!!!!!!!!!!!!

        write(6, '("(G-space) ik=", i5, ", ib=", i5, ": norm=",f12.6)') ik, ib, sum

        evcr = (0.d0, 0.d0)
        do ipw = 1, ngk(ik)
           evcr(dffts%nl(igk_k(ipw,ik)),1) = evc(ipw,ib)
        enddo
        CALL invfft ('Wave', evcr(:,1), dffts)

!!!!!!!!!!!!!!!!!! The part below is wrong!
        do ir = 1, dffts%nnr
           sum = evcr(ir,1) * evcr(ir,1) * 1/dffts%nnr ! dr = 1/dffts%nnr
        enddo
!!!!!!!!!!!!!!!!!!

        write(6, '("(r-space) ik=", i5, ", ib=", i5, ": norm=",f12.6)') ik, ib, sum
     enddo
     write(6,*)
  enddo

  CALL mp_global_end()

end program ex2
