        !COMPILER-GENERATED INTERFACE MODULE: Fri Aug  3 10:43:26 2018
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE SAVE_ARRAYS_SOLVER_EXT_MESH__genmod
          INTERFACE 
            SUBROUTINE SAVE_ARRAYS_SOLVER_EXT_MESH(NSPEC,NGLOB,         &
     &APPROXIMATE_OCEAN_LOAD,IBOOL,NUM_INTERFACES_EXT_MESH,             &
     &MY_NEIGHBOURS_EXT_MESH,NIBOOL_INTERFACES_EXT_MESH,                &
     &MAX_INTERFACE_SIZE_EXT_MESH,IBOOL_INTERFACES_EXT_MESH,            &
     &SAVE_MESH_FILES,ANISOTROPY)
              INTEGER(KIND=4) :: MAX_INTERFACE_SIZE_EXT_MESH
              INTEGER(KIND=4) :: NUM_INTERFACES_EXT_MESH
              INTEGER(KIND=4) :: NSPEC
              INTEGER(KIND=4) :: NGLOB
              LOGICAL(KIND=4) :: APPROXIMATE_OCEAN_LOAD
              INTEGER(KIND=4) :: IBOOL(5,5,5,NSPEC)
              INTEGER(KIND=4) :: MY_NEIGHBOURS_EXT_MESH(                &
     &NUM_INTERFACES_EXT_MESH)
              INTEGER(KIND=4) :: NIBOOL_INTERFACES_EXT_MESH(            &
     &NUM_INTERFACES_EXT_MESH)
              INTEGER(KIND=4) :: IBOOL_INTERFACES_EXT_MESH(5*5*         &
     &MAX_INTERFACE_SIZE_EXT_MESH,NUM_INTERFACES_EXT_MESH)
              LOGICAL(KIND=4) :: SAVE_MESH_FILES
              LOGICAL(KIND=4) :: ANISOTROPY
            END SUBROUTINE SAVE_ARRAYS_SOLVER_EXT_MESH
          END INTERFACE 
        END MODULE SAVE_ARRAYS_SOLVER_EXT_MESH__genmod
