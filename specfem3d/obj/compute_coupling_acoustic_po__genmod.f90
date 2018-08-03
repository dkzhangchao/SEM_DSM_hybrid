        !COMPILER-GENERATED INTERFACE MODULE: Fri Aug  3 10:43:42 2018
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE COMPUTE_COUPLING_ACOUSTIC_PO__genmod
          INTERFACE 
            SUBROUTINE COMPUTE_COUPLING_ACOUSTIC_PO(NSPEC_AB,NGLOB_AB,  &
     &IBOOL,DISPLS_POROELASTIC,DISPLW_POROELASTIC,                      &
     &POTENTIAL_DOT_DOT_ACOUSTIC,NUM_COUPLING_AC_PO_FACES,              &
     &COUPLING_AC_PO_ISPEC,COUPLING_AC_PO_IJK,COUPLING_AC_PO_NORMAL,    &
     &COUPLING_AC_PO_JACOBIAN2DW,IPHASE)
              INTEGER(KIND=4) :: NUM_COUPLING_AC_PO_FACES
              INTEGER(KIND=4) :: NGLOB_AB
              INTEGER(KIND=4) :: NSPEC_AB
              INTEGER(KIND=4) :: IBOOL(5,5,5,NSPEC_AB)
              REAL(KIND=8) :: DISPLS_POROELASTIC(3,NGLOB_AB)
              REAL(KIND=8) :: DISPLW_POROELASTIC(3,NGLOB_AB)
              REAL(KIND=8) :: POTENTIAL_DOT_DOT_ACOUSTIC(NGLOB_AB)
              INTEGER(KIND=4) :: COUPLING_AC_PO_ISPEC(                  &
     &NUM_COUPLING_AC_PO_FACES)
              INTEGER(KIND=4) :: COUPLING_AC_PO_IJK(3,25,               &
     &NUM_COUPLING_AC_PO_FACES)
              REAL(KIND=8) :: COUPLING_AC_PO_NORMAL(3,25,               &
     &NUM_COUPLING_AC_PO_FACES)
              REAL(KIND=8) :: COUPLING_AC_PO_JACOBIAN2DW(25,            &
     &NUM_COUPLING_AC_PO_FACES)
              INTEGER(KIND=4) :: IPHASE
            END SUBROUTINE COMPUTE_COUPLING_ACOUSTIC_PO
          END INTERFACE 
        END MODULE COMPUTE_COUPLING_ACOUSTIC_PO__genmod
