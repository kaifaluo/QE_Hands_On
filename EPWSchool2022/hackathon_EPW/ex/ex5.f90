program ex5

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
  USE symm_base, ONLY : s, ft, invs, nsym
  USE gvect, ONLY : ngm_g
  USE rotate, ONLY : gmap_sym
  USE low_lvl, ONLY : fractrasl
  USE elph2, ONLY : ngxxf

  implicit none

  LOGICAL :: needwf = .TRUE.
  integer :: ik, ipw, ib, ir, isym
  INTEGER :: s_scaled(3,3,48), ftau(3,48), gk(3)
  INTEGER, ALLOCATABLE :: gmapsym(:, :), igk(:)
  !! Correspondence G -> S(G)
  real(dp) :: sum
  complex(dp), allocatable :: evcr(:,:), evcrot1(:,:), evcrot2(:,:), evctemp(:,:)
  COMPLEX(KIND = DP), ALLOCATABLE :: eigv(:, :)
  !! $e^{ iGv}$ for 1...nsym (v the fractional translation)


  CALL mp_startup( start_images=.TRUE. )
  prefix = 'si'
  tmp_dir = './4p2k/'
  CALL read_file_new ( needwf )

  isym = 22
  ngxxf = ngm_g
  print *, ngm_g, nsym

    ALLOCATE(gmapsym(ngm_g, nsym))
    gmapsym = 0
    ALLOCATE(eigv(ngm_g, nsym))

    ALLOCATE(igk(ngm_g))

  print *, s(1,1:3,isym)
  print *, s(2,1:3,isym)
  print *, s(3,1:3,isym)
  print *, ft(:,isym)
  gk = 0

  CALL scale_sym_ops (nsym, s, ft, dffts%nr1, dffts%nr2, dffts%nr3, s_scaled, ftau)

  ALLOCATE(evcrot1(npwx,nbnd))
  ALLOCATE(evcrot2(npwx,nbnd))
  ALLOCATE(evctemp(npwx,nbnd))
  ALLOCATE ( evcr(dffts%nnr,nbnd) )

  CALL gmap_sym(nsym, s, ft, gmapsym, eigv)

  DO ik = 1, nks
     CALL read_collected_wfc ( restart_dir(), ik, evc )

     evcr = (0.d0, 0.d0)
     do ib = 1, nbnd
        do ipw = 1, ngk(ik)
           evcr(dffts%nl(igk_k(ipw,ik)),ib) = evc(ipw,ib)
        enddo
        CALL invfft ('Wave', evcr(:,ib), dffts)
     enddo

     CALL rotate_all_psi(ik, evcr, evcrot1, s_scaled(1,1,isym), &
                         ftau(1,isym), gk)

     evctemp = evc
     CALL fractrasl(ngk(ik), igk_k(:,ik), evctemp, eigv(:,isym), (1.d0,0.d0))
     evcr = (0.d0, 0.d0)
     evcrot2 = (0.d0, 0.d0)
     igk(1:ngk(ik)) = gmapsym(igk_k(1:ngk(ik),ik),isym)

     evcr(dffts%nl(igk(1:ngk(ik))),:) = evctemp(1:ngk(ik),:)
   
     evcrot2(1:ngk(ik),:) = evcr(dffts%nl(igk_k(1:ngk(ik),ik)),:)

  enddo

  CALL mp_global_end()

end program ex5
