        !COMPILER-GENERATED INTERFACE MODULE: Fri Aug  3 10:43:28 2018
        ! This source file is for reference only and may not completely
        ! represent the generated interface used by the compiler.
        MODULE ASSEMBLE_MPI_SCALAR_ASYNC_RECV__genmod
          INTERFACE 
            SUBROUTINE ASSEMBLE_MPI_SCALAR_ASYNC_RECV(NPROC,NGLOB_AB,   &
     &ARRAY_VAL,BUFFER_RECV_SCALAR_EXT_MESH,NUM_INTERFACES_EXT_MESH,    &
     &MAX_NIBOOL_INTERFACES_EXT_MESH,NIBOOL_INTERFACES_EXT_MESH,        &
     &IBOOL_INTERFACES_EXT_MESH,REQUEST_SEND_SCALAR_EXT_MESH,           &
     &REQUEST_RECV_SCALAR_EXT_MESH)
              INTEGER(KIND=4) :: MAX_NIBOOL_INTERFACES_EXT_MESH
              INTEGER(KIND=4) :: NUM_INTERFACES_EXT_MESH
              INTEGER(KIND=4) :: NGLOB_AB
              INTEGER(KIND=4) :: NPROC
              REAL(KIND=8) :: ARRAY_VAL(NGLOB_AB)
              REAL(KIND=8) :: BUFFER_RECV_SCALAR_EXT_MESH(              &
     &MAX_NIBOOL_INTERFACES_EXT_MESH,NUM_INTERFACES_EXT_MESH)
              INTEGER(KIND=4) :: NIBOOL_INTERFACES_EXT_MESH(            &
     &NUM_INTERFACES_EXT_MESH)
              INTEGER(KIND=4) :: IBOOL_INTERFACES_EXT_MESH(             &
     &MAX_NIBOOL_INTERFACES_EXT_MESH,NUM_INTERFACES_EXT_MESH)
              INTEGER(KIND=4) :: REQUEST_SEND_SCALAR_EXT_MESH(          &
     &NUM_INTERFACES_EXT_MESH)
              INTEGER(KIND=4) :: REQUEST_RECV_SCALAR_EXT_MESH(          &
     &NUM_INTERFACES_EXT_MESH)
            END SUBROUTINE ASSEMBLE_MPI_SCALAR_ASYNC_RECV
          END INTERFACE 
        END MODULE ASSEMBLE_MPI_SCALAR_ASYNC_RECV__genmod