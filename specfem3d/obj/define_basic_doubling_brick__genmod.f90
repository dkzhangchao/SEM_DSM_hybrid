        !COMPILER-GENERATED INTERFACE MODULE: Fri Aug  3 10:42:48 2018
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE DEFINE_BASIC_DOUBLING_BRICK__genmod
          INTERFACE 
            SUBROUTINE DEFINE_BASIC_DOUBLING_BRICK(X_SUPERBRICK,        &
     &Y_SUPERBRICK,Z_SUPERBRICK,IBOOL_SUPERBRICK,IBOUN_SB,CASE_NUM)
              REAL(KIND=8) :: X_SUPERBRICK(67)
              REAL(KIND=8) :: Y_SUPERBRICK(67)
              REAL(KIND=8) :: Z_SUPERBRICK(67)
              INTEGER(KIND=4) :: IBOOL_SUPERBRICK(8,32)
              LOGICAL(KIND=4) :: IBOUN_SB(32,6)
              INTEGER(KIND=4) :: CASE_NUM
            END SUBROUTINE DEFINE_BASIC_DOUBLING_BRICK
          END INTERFACE 
        END MODULE DEFINE_BASIC_DOUBLING_BRICK__genmod
