        !COMPILER-GENERATED INTERFACE MODULE: Fri Aug  3 10:42:59 2018
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE CRM_SETUP_INNER_OUTER_ELEMNTS__genmod
          INTERFACE 
            SUBROUTINE CRM_SETUP_INNER_OUTER_ELEMNTS(MYRANK,NSPEC,      &
     &NUM_INTERFACES_EXT_MESH,MAX_INTERFACE_SIZE_EXT_MESH,              &
     &NIBOOL_INTERFACES_EXT_MESH,IBOOL_INTERFACES_EXT_MESH,IBOOL,       &
     &SAVE_MESH_FILES)
              INTEGER(KIND=4) :: MAX_INTERFACE_SIZE_EXT_MESH
              INTEGER(KIND=4) :: NUM_INTERFACES_EXT_MESH
              INTEGER(KIND=4) :: NSPEC
              INTEGER(KIND=4) :: MYRANK
              INTEGER(KIND=4) :: NIBOOL_INTERFACES_EXT_MESH(            &
     &NUM_INTERFACES_EXT_MESH)
              INTEGER(KIND=4) :: IBOOL_INTERFACES_EXT_MESH(5*5*         &
     &MAX_INTERFACE_SIZE_EXT_MESH,NUM_INTERFACES_EXT_MESH)
              INTEGER(KIND=4) :: IBOOL(5,5,5,NSPEC)
              LOGICAL(KIND=4) :: SAVE_MESH_FILES
            END SUBROUTINE CRM_SETUP_INNER_OUTER_ELEMNTS
          END INTERFACE 
        END MODULE CRM_SETUP_INNER_OUTER_ELEMNTS__genmod
