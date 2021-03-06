subroutine set_Variables_Bound(myrank,ispec_is_elastic,ispec_is_acoustic,nspec)
  use SEMtoTele_par
  implicit none

  integer ::myrank,nspec
  logical, dimension(nspec) :: ispec_is_acoustic,ispec_is_elastic

  integer ::i,j,k,iele_Bound,iglob,ispec_bound
  integer ::middle_igll,middle_jgll,middle_kgll
  double precision:: temp
  real(kind=CUSTOM_REAL) ::temp1
  print *,'myrank=',myrank
  Nele_Bound=nxLow+nxHigh+nyLow+nyHigh+nrdown+nrtop
!  Nele_Bound=nrdown
!  call sync_all()
  allocate(Bound_Info(Nele_Bound))
  if(LOW_RESOLUTION) then
    npoints_bound=Nele_Bound
  else
    npoints_bound=Nele_Bound*NGLLX*NGLLZ
  end if


   

!  allocate(disp_bound(NSTEP_BETWEEN_OUTPUTBOUND,NDIM,npoints_Bound))
!  allocate(traction_bound(NSTEP_BETWEEN_OUTPUTBOUND,NDIM,npoints_Bound))
  allocate(normal_vect_bound(NDIM,npoints_bound))
  allocate(id_depth_bound(npoints_bound))
  allocate(id_dist_bound(npoints_bound))

!  call sync_all()
  print *,'SUCCESS',myrank
!  call sync_all()
!  call ViaRepresent_default()
!  call sync_all()
  print *,'SUCCESS1',myrank
!  call sync_all()
  iele_Bound=0
  if(mod(NGLLX,2).eq.0) then
     middle_igll=NGLLX/2
  else
     middle_igll=(NGLLX-1)/2+1
  end if
  if(mod(NGLLY,2).eq.0) then
     middle_jgll=NGLLY/2
  else
     middle_jgll=(NGLLY-1)/2+1
  end if
  if(mod(NGLLZ,2).eq.0) then
     middle_kgll=NGLLZ/2
  else 
     middle_kgll=(NGLLZ-1)/2+1
  end if

!the left boundary
  do i=1,nxLow
     iele_Bound=iele_Bound+1
     ispec_bound=element_xLow(i)
     Bound_Info(iele_Bound)%ispec_bound=ispec_bound
     Bound_Info(iele_Bound)%iregion    =element_xLowReg(i)
     Bound_Info(iele_Bound)%face_type =1
     Bound_Info(iele_Bound)%istart=1;Bound_Info(iele_Bound)%iend=1
     if(.not.LOW_RESOLUTION) then
        Bound_Info(iele_Bound)%jstart=1;Bound_Info(iele_Bound)%jend=NGLLY
        Bound_Info(iele_Bound)%kstart=1;Bound_Info(iele_Bound)%kend=NGLLZ
     else 
        Bound_Info(iele_Bound)%jstart=middle_jgll;Bound_Info(iele_Bound)%jend=middle_jgll
        Bound_Info(iele_Bound)%kstart=middle_kgll;Bound_Info(iele_Bound)%kend=middle_kgll
     end if
     if(ispec_is_elastic(ispec_bound)) then
        Bound_Info(iele_Bound)%is_elastic=.TRUE.
        Nele_BoundElas=Nele_BoundElas+1
     else
        Bound_Info(iele_Bound)%is_elastic=.FALSE.
        Nele_BoundAcous=Nele_BoundAcous+1
     end if
  end do


!the right boundary
  do i=1,nxHigh
     iele_Bound=iele_Bound+1
     ispec_bound=element_xHigh(i)
     Bound_Info(iele_Bound)%ispec_bound=ispec_bound
     Bound_Info(iele_Bound)%iregion    =element_xHighReg(i)
     Bound_Info(iele_Bound)%face_type =2
     Bound_Info(iele_Bound)%istart=NGLLX;Bound_Info(iele_Bound)%iend=NGLLX
     if(.not.LOW_RESOLUTION) then
       Bound_Info(iele_Bound)%jstart=1;Bound_Info(iele_Bound)%jend=NGLLY
       Bound_Info(iele_Bound)%kstart=1;Bound_Info(iele_Bound)%kend=NGLLZ
     else
       Bound_Info(iele_Bound)%jstart=middle_jgll;Bound_Info(iele_Bound)%jend=middle_jgll
       Bound_Info(iele_Bound)%kstart=middle_kgll;Bound_Info(iele_Bound)%kend=middle_kgll
     end if
     if(ispec_is_elastic(ispec_bound)) then
        Bound_Info(iele_Bound)%is_elastic=.TRUE.
        Nele_BoundElas=Nele_BoundElas+1
     else
        Bound_Info(iele_Bound)%is_elastic=.FALSE.
        Nele_BoundAcous=Nele_BoundAcous+1
     end if
  end do

!the forward boundary
  do i=1,nyLow
     iele_Bound=iele_Bound+1
     ispec_bound=element_yLow(i)
     Bound_Info(iele_Bound)%ispec_bound=ispec_bound
     Bound_Info(iele_Bound)%iregion    =element_yLowReg(i)
     Bound_Info(iele_Bound)%face_type =3
     Bound_Info(iele_Bound)%jstart=1;Bound_Info(iele_Bound)%jend=1
     if(.not.LOW_RESOLUTION) then
        Bound_Info(iele_Bound)%istart=1;Bound_Info(iele_Bound)%iend=NGLLX
        Bound_Info(iele_Bound)%kstart=1;Bound_Info(iele_Bound)%kend=NGLLZ
     else
        Bound_Info(iele_Bound)%istart=middle_igll;Bound_Info(iele_Bound)%iend=middle_igll
        Bound_Info(iele_Bound)%kstart=middle_kgll;Bound_Info(iele_Bound)%kend=middle_kgll
     end if
     if(ispec_is_elastic(ispec_bound)) then
        Bound_Info(iele_Bound)%is_elastic=.TRUE.
        Nele_BoundElas=Nele_BoundElas+1
     else
        Bound_Info(iele_Bound)%is_elastic=.FALSE.
        Nele_BoundAcous=Nele_BoundAcous+1
     end if
  end do

!the back boundary
  do i=1,nyHigh
     iele_Bound=iele_Bound+1
     ispec_bound=element_yHigh(i)
     Bound_Info(iele_Bound)%ispec_bound=ispec_bound
     Bound_Info(iele_Bound)%iregion    =element_yHighReg(i)
     Bound_Info(iele_Bound)%face_type =4
     Bound_Info(iele_Bound)%jstart=NGLLY;Bound_Info(iele_Bound)%jend=NGLLY
     if(.not.LOW_RESOLUTION) then
        Bound_Info(iele_Bound)%istart=1;Bound_Info(iele_Bound)%iend=NGLLX
        Bound_Info(iele_Bound)%kstart=1;Bound_Info(iele_Bound)%kend=NGLLZ
     else
        Bound_Info(iele_Bound)%istart=middle_igll;Bound_Info(iele_Bound)%iend=middle_igll
        Bound_Info(iele_Bound)%kstart=middle_kgll;Bound_Info(iele_Bound)%kend=middle_kgll
     end if
     if(ispec_is_elastic(ispec_bound)) then
        Bound_Info(iele_Bound)%is_elastic=.TRUE.
        Nele_BoundElas=Nele_BoundElas+1
     else
        Bound_Info(iele_Bound)%is_elastic=.FALSE.
        Nele_BoundAcous=Nele_BoundAcous+1
     end if
  end do

!the bottom boundary
  do i=1,nrdown
     iele_Bound=iele_Bound+1
     ispec_bound=element_rdown(i)
     Bound_Info(iele_Bound)%ispec_bound=ispec_bound
     Bound_Info(iele_Bound)%iregion    =element_rdownReg(i)
     Bound_Info(iele_Bound)%face_type =5
     Bound_Info(iele_Bound)%kstart=1;Bound_Info(iele_Bound)%kend=1
     if(.not.LOW_RESOLUTION) then
        Bound_Info(iele_Bound)%istart=1;Bound_Info(iele_Bound)%iend=NGLLX
        Bound_Info(iele_Bound)%jstart=1;Bound_Info(iele_Bound)%jend=NGLLY
     else
        Bound_Info(iele_Bound)%istart=middle_igll;Bound_Info(iele_Bound)%iend=middle_igll
        Bound_Info(iele_Bound)%jstart=middle_jgll;Bound_Info(iele_Bound)%jend=middle_jgll
     end if
     if(ispec_is_elastic(ispec_bound)) then
        Bound_Info(iele_Bound)%is_elastic=.TRUE.
        Nele_BoundElas=Nele_BoundElas+1
     else
        Bound_Info(iele_Bound)%is_elastic=.FALSE.
        Nele_BoundAcous=Nele_BoundAcous+1
     end if
  end do
!the top boundary
  do i=1,nrtop
     iele_Bound=iele_Bound+1
     ispec_bound=element_rtop(i)
     Bound_Info(iele_Bound)%ispec_bound=ispec_bound
     Bound_Info(iele_Bound)%iregion    =element_rtopReg(i)
     Bound_Info(iele_Bound)%face_type =6
     Bound_Info(iele_Bound)%kstart=NGLLZ;Bound_Info(iele_Bound)%kend=NGLLZ
     if(.not.LOW_RESOLUTION) then
        Bound_Info(iele_Bound)%istart=1;Bound_Info(iele_Bound)%iend=NGLLX
        Bound_Info(iele_Bound)%jstart=1;Bound_Info(iele_Bound)%jend=NGLLY
     else
        Bound_Info(iele_Bound)%istart=middle_igll;Bound_Info(iele_Bound)%iend=middle_igll
        Bound_Info(iele_Bound)%jstart=middle_jgll;Bound_Info(iele_Bound)%jend=middle_jgll
     end if
     if(ispec_is_elastic(ispec_bound)) then
        Bound_Info(iele_Bound)%is_elastic=.TRUE.
        Nele_BoundElas=Nele_BoundElas+1
     else
        Bound_Info(iele_Bound)%is_elastic=.FALSE.
        Nele_BoundAcous=Nele_BoundAcous+1
     end if
  end do

  if(iele_Bound.ne.Nele_Bound) STOP 'The boundary element copying failed'


  if(LOW_RESOLUTION) then
    npoints_BoundElas=Nele_BoundElas
    npoints_BoundAcous=Nele_BoundAcous
  else
    npoints_BoundElas=Nele_BoundElas*NGLLX*NGLLZ
    npoints_BoundAcous=Nele_BoundAcous*NGLLX*NGLLZ
  end if

  if(mod(npoints_BoundElas,NPOINTS_PER_PACK).eq.0) then
    npackage_Elas=npoints_BoundElas/NPOINTS_PER_PACK
    allocate(npoints_ipack_Elas(npackage_Elas))
    npoints_ipack_Elas(:)=NPOINTS_PER_PACK
  else 
    npackage_Elas=int(npoints_BoundElas/NPOINTS_PER_PACK)+1
    allocate(npoints_ipack_Elas(npackage_Elas))
    npoints_ipack_Elas(1:npackage_Elas-1)=NPOINTS_PER_PACK
    npoints_ipack_Elas(npackage_Elas)=mod(npoints_BoundElas,NPOINTS_PER_PACK)
  end if

  if(mod(npoints_bound,NPOINTS_PER_PACK).eq.0) then
    npackage_elas_acous=npoints_bound/NPOINTS_PER_PACK
    allocate(npoints_ipack_elas_acous(npackage_elas_acous))
    npoints_ipack_elas_acous(:)=NPOINTS_PER_PACK
  else
    npackage_elas_acous=int(npoints_bound/NPOINTS_PER_PACK)+1
    allocate(npoints_ipack_elas_acous(npackage_elas_acous))
    npoints_ipack_elas_acous(1:npackage_elas_acous-1)=NPOINTS_PER_PACK
    npoints_ipack_elas_acous(npackage_elas_acous)=mod(npoints_bound,NPOINTS_PER_PACK)
  end if


  print *,'npackage_Elas',myrank,npackage_Elas
  
  print *,'SUCCESS3',myrank,Nele_Bound
  
  
!  call sync_all()
  print *,'SUCCESS4',myrank
  
!  call sync_all()
end subroutine set_Variables_Bound
