/*
 !=====================================================================
 !
 !               S p e c f e m 3 D  V e r s i o n  3 . 0
 !               ---------------------------------------
 !
 !     Main historical authors: Dimitri Komatitsch and Jeroen Tromp
 !                        Princeton University, USA
 !                and CNRS / University of Marseille, France
 !                 (there are currently many more authors!)
 ! (c) Princeton University and CNRS / University of Marseille, July 2012
 !
 ! This program is free software; you can redistribute it and/or modify
 ! it under the terms of the GNU General Public License as published by
 ! the Free Software Foundation; either version 2 of the License, or
 ! (at your option) any later version.
 !
 ! This program is distributed in the hope that it will be useful,
 ! but WITHOUT ANY WARRANTY; without even the implied warranty of
 ! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ! GNU General Public License for more details.
 !
 ! You should have received a copy of the GNU General Public License along
 ! with this program; if not, write to the Free Software Foundation, Inc.,
 ! 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 !
 !=====================================================================
 */

#include "mesh_constants_cuda.h"

/* ----------------------------------------------------------------------------------------------- */

#ifdef USE_TEXTURES_FIELDS
realw_texture d_potential_tex;
realw_texture d_potential_dot_dot_tex;
//backward/reconstructed
realw_texture d_b_potential_tex;
realw_texture d_b_potential_dot_dot_tex;

//note: texture variables are implicitly static, and cannot be passed as arguments to cuda kernels;
//      thus, 1) we thus use if-statements (FORWARD_OR_ADJOINT) to determine from which texture to fetch from
//            2) we use templates
//      since if-statements are a bit slower as the variable is only known at runtime, we use option 2)

// templates definitions
template<int FORWARD_OR_ADJOINT> __device__ float texfetch_potential(int x);
template<int FORWARD_OR_ADJOINT> __device__ float texfetch_potential_dot_dot(int x);

// templates for texture fetching
// FORWARD_OR_ADJOINT == 1 <- forward arrays
template<> __device__ float texfetch_potential<1>(int x) { return tex1Dfetch(d_potential_tex, x); }
template<> __device__ float texfetch_potential_dot_dot<1>(int x) { return tex1Dfetch(d_potential_dot_dot_tex, x); }
// FORWARD_OR_ADJOINT == 3 <- backward/reconstructed arrays
template<> __device__ float texfetch_potential<3>(int x) { return tex1Dfetch(d_b_potential_tex, x); }
template<> __device__ float texfetch_potential_dot_dot<3>(int x) { return tex1Dfetch(d_b_potential_dot_dot_tex, x); }

#endif

#ifdef USE_TEXTURES_CONSTANTS
extern realw_texture d_hprime_xx_tex;
#endif


// note on performance optimizations:
//
//   instead of providing spezialized kernel routines (without mesh coloring, without gravity, etc.),
//   we only provide one "general" kernel to handle all cases. this reduces code redundancy and improves code readability.
//   as tradeoff, we take a little performance hit of around ~ 3%
//
//   performance tests done:
//   - registers: we were trying to reduce the number of registers, as this is the main limiter for the
//                occupancy of the kernel. however, there is only little difference in register pressure for one "general" kernel
//                or multiple "spezialized" kernels. reducing registers is mainly achieved through the launch_bonds() directive.
//   - branching: we were trying to reduce code branches, such as the if-active check in earlier code versions.
//                reducing the branching helps the compiler to better optimize the executable.
//   - memory accesses: the global memory accesses are avoiding texture reads for coalescent arrays, as this is
//                still faster. thus we were using no __ldg() loads or __restricted__ pointer usage,
//                as those implicitly lead the compiler to use texture reads.
//   - arithmetic intensity: ratio of floating-point operations vs. memory accesses is still low for our kernels.
//                tests with using a loop over elements to re-use the constant arrays (like hprime, wgllwgll,..) and thus
//                increasing the arithmetic intensity failed because the number of registers increased as well.
//                this increased register pressure reduced the occupancy and slowed down the kernel performance.
//   - hiding memory latency: to minimize waiting times to retrieve a memory value from global memory, we put
//                some more calculations into the same code block before calling syncthreads(). this should help the
//                compiler to move independent calculations to wherever it can overlap it with memory access operations.
//                note, especially the if (gravity )-block locations are very sensitive
//                for optimal register usage and compiler optimizations
//

/* ----------------------------------------------------------------------------------------------- */

// KERNEL 2 - acoustic compute forces kernel

/* ----------------------------------------------------------------------------------------------- */

template<int FORWARD_OR_ADJOINT> __global__ void
#ifdef USE_LAUNCH_BOUNDS
// adds compiler specification
__launch_bounds__(NGLL3_PADDED,LAUNCH_MIN_BLOCKS_ACOUSTIC)
#endif
Kernel_2_acoustic_impl(const int nb_blocks_to_compute,
                       const int* d_ibool,
                       const int* d_phase_ispec_inner_acoustic,
                       const int num_phase_ispec_acoustic,
                       const int d_iphase,
                       realw_const_p d_potential_acoustic,
                       realw_p d_potential_dot_dot_acoustic,
                       realw* d_xix,realw* d_xiy,realw* d_xiz,
                       realw* d_etax,realw* d_etay,realw* d_etaz,
                       realw* d_gammax,realw* d_gammay,realw* d_gammaz,
                       realw_const_p d_hprime_xx,
                       realw_const_p hprimewgll_xx,
                       realw_const_p wgllwgll_xy,realw_const_p wgllwgll_xz,realw_const_p wgllwgll_yz,
                       realw* d_rhostore,
                       const int use_mesh_coloring_gpu,
                       const int gravity,
                       realw_const_p minus_g,
                       realw* d_kappastore,
                       realw_const_p wgll_cube){

  // block-id == number of local element id in phase_ispec array
  int bx = blockIdx.y*gridDim.x+blockIdx.x;

  // thread-id == GLL node id
  // note: use only NGLL^3 = 125 active threads, plus 3 inactive/ghost threads,
  //       because we used memory padding from NGLL^3 = 125 to 128 to get coalescent memory accesses;
  //       to avoid execution branching and the need of registers to store an active state variable,
  //       the thread ids are put in valid range
  int tx = threadIdx.x;

  int I,J,K;
  int iglob,offset;
  int working_element;

  realw temp1l,temp2l,temp3l;
  realw xixl,xiyl,xizl,etaxl,etayl,etazl,gammaxl,gammayl,gammazl;
  realw jacobianl;

  realw dpotentialdxl,dpotentialdyl,dpotentialdzl;
  realw fac1,fac2,fac3;
  realw rho_invl,kappa_invl;

  realw sum_terms;
  realw gravity_term;

  __shared__ realw s_dummy_loc[NGLL3];

  __shared__ realw s_temp1[NGLL3];
  __shared__ realw s_temp2[NGLL3];
  __shared__ realw s_temp3[NGLL3];

  __shared__ realw sh_hprime_xx[NGLL2];
  __shared__ realw sh_hprimewgll_xx[NGLL2];

// arithmetic intensity: ratio of number-of-arithmetic-operations / number-of-bytes-accessed-on-DRAM
//
// hand-counts on floating-point operations: counts addition/subtraction/multiplication/division
//                                           no counts for operations on indices in for-loops (compiler will likely unrool loops)
//
//                                           counts accesses to global memory, but no shared memory or register loads/stores
//                                           float has 4 bytes

// counts: for simulations without gravity, without mesh_coloring
//         counts floating-point operations (FLOP) per thread
//         counts global memory accesses in bytes (BYTES) per block
// 2 FLOP
//
// 0 BYTES

  // checks if anything to do
  if (bx >= nb_blocks_to_compute) return;

  // limits thread ids to range [0,125-1]
  if (tx >= NGLL3) tx = NGLL3-1;

// counts:
// + 1 FLOP
//
// + 0 BYTE

  // spectral-element id
#ifdef USE_MESH_COLORING_GPU
  working_element = bx;
#else
  //mesh coloring
  if (use_mesh_coloring_gpu ){
    working_element = bx;
  }else{
    // iphase-1 and working_element-1 for Fortran->C array conventions
    working_element = d_phase_ispec_inner_acoustic[bx + num_phase_ispec_acoustic*(d_iphase-1)]-1;
  }
#endif

  // local padded index
  offset = working_element*NGLL3_PADDED + tx;

  // global index
  iglob = d_ibool[offset] - 1;

// counts:
// + 7 FLOP
//
// + 2 float * 128 threads = 1024 BYTE

  // loads potential values into shared memory
  if (threadIdx.x < NGLL3) {
#ifdef USE_TEXTURES_FIELDS
    s_dummy_loc[tx] = texfetch_potential<FORWARD_OR_ADJOINT>(iglob);
#else
    // changing iglob indexing to match fortran row changes fast style
    s_dummy_loc[tx] = d_potential_acoustic[iglob];
#endif
  }

// counts:
// + 0 FLOP
//
// + 1 float * 125 threads = 500 BYTE

  // gravity
  if (gravity ){
    kappa_invl = 1.f / d_kappastore[working_element*NGLL3 + tx];
  }

  // local index
  K = (tx/NGLL2);
  J = ((tx-K*NGLL2)/NGLLX);
  I = (tx-K*NGLL2-J*NGLLX);

// counts:
// + 8 FLOP
//
// + 0 BYTES

  // note: loads mesh values here to give compiler possibility to overlap memory fetches with some computations;
  //       arguments defined as realw* instead of const realw* __restrict__ to avoid that the compiler
  //       loads all memory by texture loads (arrays accesses are coalescent, thus no need for texture reads)
  //
  // calculates laplacian
  xixl = d_xix[offset];
  xiyl = d_xiy[offset];
  xizl = d_xiz[offset];
  etaxl = d_etax[offset];
  etayl = d_etay[offset];
  etazl = d_etaz[offset];
  gammaxl = d_gammax[offset];
  gammayl = d_gammay[offset];
  gammazl = d_gammaz[offset];

  jacobianl = 1.f / (xixl*(etayl*gammazl-etazl*gammayl)
                    -xiyl*(etaxl*gammazl-etazl*gammaxl)
                    +xizl*(etaxl*gammayl-etayl*gammaxl));

  // density (reciproc)
  rho_invl = 1.f / d_rhostore[offset];

// counts:
// + 16 FLOP
//
// + 10 float * 128 threads = 5120 BYTE

  // loads hprime into shared memory
  if (tx < NGLL2) {
#ifdef USE_TEXTURES_CONSTANTS
    sh_hprime_xx[tx] = tex1Dfetch(d_hprime_xx_tex,tx);
#else
    sh_hprime_xx[tx] = d_hprime_xx[tx];
#endif
    // loads hprimewgll into shared memory
    sh_hprimewgll_xx[tx] = hprimewgll_xx[tx];
  }

// counts:
// + 0 FLOP
//
// + 2 * 1 float * 25 threads = 200 BYTE

  // synchronize all the threads (one thread for each of the NGLL grid points of the
  // current spectral element) because we need the whole element to be ready in order
  // to be able to compute the matrix products along cut planes of the 3D element below
  __syncthreads();

  // computes first matrix product
  temp1l = 0.f;
  temp2l = 0.f;
  temp3l = 0.f;

  for (int l=0;l<NGLLX;l++) {
    //assumes that hprime_xx = hprime_yy = hprime_zz
    // 1. cut-plane along xi-direction
    temp1l += s_dummy_loc[K*NGLL2+J*NGLLX+l] * sh_hprime_xx[l*NGLLX+I];
    // 2. cut-plane along eta-direction
    temp2l += s_dummy_loc[K*NGLL2+l*NGLLX+I] * sh_hprime_xx[l*NGLLX+J];
    // 3. cut-plane along gamma-direction
    temp3l += s_dummy_loc[l*NGLL2+J*NGLLX+I] * sh_hprime_xx[l*NGLLX+K];
  }

// counts:
// + NGLLX * 3 * 8 FLOP = 120 FLOP
//
// + 0 BYTE

  // compute derivatives of ux, uy and uz with respect to x, y and z
  // derivatives of potential
  dpotentialdxl = xixl*temp1l + etaxl*temp2l + gammaxl*temp3l;
  dpotentialdyl = xiyl*temp1l + etayl*temp2l + gammayl*temp3l;
  dpotentialdzl = xizl*temp1l + etazl*temp2l + gammazl*temp3l;

// counts:
// + 3 * 5 FLOP = 15 FLOP
//
// + 0 BYTE

  // form the dot product with the test vector
  if (threadIdx.x < NGLL3) {
    s_temp1[tx] = jacobianl * rho_invl * (dpotentialdxl*xixl + dpotentialdyl*xiyl + dpotentialdzl*xizl);
    s_temp2[tx] = jacobianl * rho_invl * (dpotentialdxl*etaxl + dpotentialdyl*etayl + dpotentialdzl*etazl);
    s_temp3[tx] = jacobianl * rho_invl * (dpotentialdxl*gammaxl + dpotentialdyl*gammayl + dpotentialdzl*gammazl);
  }

  // pre-computes gravity sum term
  if (gravity ){
    // uses potential definition: s = grad(chi)
    //
    // gravity term: 1/kappa grad(chi) * g
    // assumes that g only acts in (negative) z-direction
    gravity_term = minus_g[iglob] * kappa_invl * jacobianl * wgll_cube[tx] * dpotentialdzl;
  }

// counts:
// + 3 * 7 FLOP = 21 FLOP
//
// + 0 BYTE

  // synchronize all the threads (one thread for each of the NGLL grid points of the
  // current spectral element) because we need the whole element to be ready in order
  // to be able to compute the matrix products along cut planes of the 3D element below
  __syncthreads();

  // computes second matrix product
  temp1l = 0.f;
  temp2l = 0.f;
  temp3l = 0.f;

  for (int l=0;l<NGLLX;l++) {
    //assumes hprimewgll_xx = hprimewgll_yy = hprimewgll_zz
    // 1. cut-plane along xi-direction
    temp1l += s_temp1[K*NGLL2+J*NGLLX+l] * sh_hprimewgll_xx[I*NGLLX+l];
    // 2. cut-plane along eta-direction
    temp2l += s_temp2[K*NGLL2+l*NGLLX+I] * sh_hprimewgll_xx[J*NGLLX+l];
    // 3. cut-plane along gamma-direction
    temp3l += s_temp3[l*NGLL2+J*NGLLX+I] * sh_hprimewgll_xx[K*NGLLX+l];
  }

// counts:
// + NGLLX * 3 * 8 FLOP = 120 FLOP
//
// + 0 BYTE

  // summed terms with added gll weights
  fac1 = wgllwgll_yz[K*NGLLX+J];
  fac2 = wgllwgll_xz[K*NGLLX+I];
  fac3 = wgllwgll_xy[J*NGLLX+I];

  sum_terms = -(fac1*temp1l + fac2*temp2l + fac3*temp3l);

  // adds gravity contribution
  if (gravity) sum_terms += gravity_term;

// counts:
// + 3 * 2 FLOP + 6 FLOP = 12 FLOP
//
// + 3 float * 128 threads = 1536 BYTE

  // assembles potential array
  if (threadIdx.x < NGLL3) {
#ifdef USE_MESH_COLORING_GPU
  // no atomic operation needed, colors don't share global points between elements
#ifdef USE_TEXTURES_FIELDS
    d_potential_dot_dot_acoustic[iglob] = texfetch_potential_dot_dot<FORWARD_OR_ADJOINT>(iglob) + sum_terms;
#else
    d_potential_dot_dot_acoustic[iglob] += sum_terms;
#endif // USE_TEXTURES_FIELDS
#else  // MESH_COLORING
    //mesh coloring
    if (use_mesh_coloring_gpu ){
      // no atomic operation needed, colors don't share global points between elements
#ifdef USE_TEXTURES_FIELDS
      d_potential_dot_dot_acoustic[iglob] = texfetch_potential_dot_dot<FORWARD_OR_ADJOINT>(iglob) + sum_terms;
#else
      d_potential_dot_dot_acoustic[iglob] += sum_terms;
#endif // USE_TEXTURES_FIELDS
    }else{
      atomicAdd(&d_potential_dot_dot_acoustic[iglob],sum_terms);
    }
#endif // MESH_COLORING
  }

// counts:
// + 1 FLOP
//
// + 1 float * 125 threads = 500 BYTE

// -----------------
// total of: 323 FLOP per thread
//           ~ 128 * 323 = 41344 FLOP per block
//
//           8880 BYTE DRAM accesses per block
//
//           -> arithmetic intensity: 41344 FLOP / 8880 BYTES ~ 4.66 FLOP/BYTE (hand-count)
//
// -----------------
//
// nvprof: nvprof --metrics flops_sp ./xspecfem3D
//         -> 322631424 FLOPS (Single) floating-point operations for 20736 elements
//         -> 15559 FLOP per block
//
//         -> arithmetic intensity: ~ 15559 / 8880 flop/byte = 1.75 flop/byte
//
// roofline model: Tesla K20x
// ---------------------------
//   for a Kepler K20x card, the peak single-precision performance is about 3.95 TFlop/s.
//   global memory access has a bandwidth of ~ 250 GB/s.
//   thus there should be about 16 flop to hide a single byte memory access (3950./250. ~ 15.8 flop/byte = arithmetic intensity).
//
//   memory bandwidth: 250 GB/s
//   single-precision peak performance: 3.95 TFlop/s -> corner arithmetic intensity = 3950 / 250 ~ 15.8 flop/byte
//
//   note:
//     using dense matrix-matrix multiplication (SGEMM) leads to "practical" peak performance of around 2.9 TFlops.
//     (http://www.nvidia.com/docs/IO/122874/K20-and-K20X-application-performance-technical-brief.pdf)
//
//   acoustic kernel has an arithmetic intensity of: hand-counts   ~ 4.66 flop/byte
//                                                   nvprof-counts ~ 1.75 flop/byte
//
//   -> we can only achieve about: (hand-counts)   29% of the peak performance
//                                 (nvprof-counts) 11% of the peak performance
//
//                              i.e.               11% x theoretical peak performance ~ 440 GFlop/s.
//                                                 11% x "pratical"  peak performance ~ 320 GFlop/s.
//
//   CUDA_TIMING: we achieve about 224 GFlop/s (1 mpi process, 20736 elements)
//                -> that is about 8% of the "practical" peak. (or 70% of the theoretical arithmetic intensity)
//
//                this might be due to the first compute code block (before first syncthreads), where
//                the partial arithmetic intensity is lower than for the total routine.
//
// roofline model: Tesla K20c (Kepler architecture: http://www.nvidia.com/content/tesla/pdf/Tesla-KSeries-Overview-LR.pdf)
// ---------------------------
//   memory bandwidth: 208 GB/s
//   single-precision peak performance: 3.52 TFlop/s -> corner arithmetic intensity = 3520 / 208 ~ 16.9 flop/byte
//
//   we can only achieve about: (hand-counts)   27% of the peak performance -> 970.6 GFlop/s
//                              (nvprof-counts) 10% of the peak performance -> 364.5 GFlop/s - measured: 229.631 GFlop/s
//
// roofline model: nVidia GT 650m  http://www.gpuzoo.com/GPU-NVIDIA/GeForce_GT_650M_DDR3.html
// ---------------------------
//   memory bandwidth: 28.8 GB/s
//   single-precision peak performance: 625.6 GFlop/s -> corner arithmetic intensity = 625.6 / 28.8 ~ 21.7 flop/byte
//
//   we can only achieve about: (hand-counts)   21% of the peak performance -> 132.6 GFlop/s
//                              (nvprof-counts)  8% of the peak performance ->  50.5 GFlop/s - measured: 52.1907 GFlop/s
//
//
//
// better performance ideas and improvements are welcome :)

}

/* ----------------------------------------------------------------------------------------------- */

/*

// kernel useful for optimization: stripped-down version
//                                 acoustic kernel without gravity and without mesh coloring

template<int FORWARD_OR_ADJOINT> __global__ void
#ifdef USE_LAUNCH_BOUNDS
// adds compiler specification
__launch_bounds__(NGLL3_PADDED,LAUNCH_MIN_BLOCKS_ACOUSTIC)
#endif
Kernel_2_acoustic_perf_impl(const int nb_blocks_to_compute,
                       const int* d_ibool,
                       const int* d_phase_ispec_inner_acoustic,
                       const int num_phase_ispec_acoustic,
                       const int d_iphase,
                       realw_const_p d_potential_acoustic,
                       realw_p d_potential_dot_dot_acoustic,
                       realw* d_xix,realw* d_xiy,realw* d_xiz,
                       realw* d_etax,realw* d_etay,realw* d_etaz,
                       realw* d_gammax,realw* d_gammay,realw* d_gammaz,
                       realw_const_p d_hprime_xx,
                       realw_const_p hprimewgll_xx,
                       realw_const_p wgllwgll_xy,realw_const_p wgllwgll_xz,realw_const_p wgllwgll_yz,
                       realw* d_rhostore,
                       const int use_mesh_coloring_gpu,
                       const int gravity,
                       realw_const_p minus_g,
                       realw* d_kappastore,
                       realw_const_p wgll_cube){

// note: this routine is using only 12 active blocks instead of full occupancy (16 active blocks)
//       due to small register spilling which slows down performance
//       timing: ~ 1.41 ms (Kepler: Tesla K20c)

  // block-id == number of local element id in phase_ispec array
  int bx = blockIdx.y*gridDim.x+blockIdx.x;

  // thread-id == GLL node id
  // note: use only NGLL^3 = 125 active threads, plus 3 inactive/ghost threads,
  //       because we used memory padding from NGLL^3 = 125 to 128 to get coalescent memory accesses;
  //       to avoid execution branching and the need of registers to store an active state variable,
  //       the thread ids are put in valid range
  int tx = threadIdx.x;

  int I,J,K;
  int iglob,offset;
  int working_element;

  realw temp1l,temp2l,temp3l;
  realw xixl,xiyl,xizl,etaxl,etayl,etazl,gammaxl,gammayl,gammazl,jacobianl;

  realw dpotentialdxl,dpotentialdyl,dpotentialdzl;
  realw fac1,fac2,fac3;
  realw rho_invl;

  realw sum_terms;

  __shared__ realw s_dummy_loc[NGLL3];

  __shared__ realw s_temp1[NGLL3];
  __shared__ realw s_temp2[NGLL3];
  __shared__ realw s_temp3[NGLL3];

  __shared__ realw sh_hprime_xx[NGLL2];
  __shared__ realw sh_hprimewgll_xx[NGLL2];

  // checks if anything to do
  if (bx >= nb_blocks_to_compute) return;

  // limits thread ids to range [0,125-1]
  if (tx >= NGLL3) tx = NGLL3 - 1;

  // spectral-element id
  // iphase-1 and working_element-1 for Fortran->C array conventions
  working_element = d_phase_ispec_inner_acoustic[bx + num_phase_ispec_acoustic*(d_iphase-1)] - 1;

  // local padded index
  offset = working_element*NGLL3_PADDED + tx;

  // global index
  iglob = d_ibool[offset] - 1;

  // loads potential values into shared memory
  if (threadIdx.x < NGLL3) {
    // loads potentials
#ifdef USE_TEXTURES_FIELDS
    s_dummy_loc[tx] = texfetch_potential<FORWARD_OR_ADJOINT>(iglob);
#else
    // changing iglob indexing to match fortran row changes fast style
    s_dummy_loc[tx] = d_potential_acoustic[iglob];
#endif
  }

  // local index
  K = (tx/NGLL2);
  J = ((tx-K*NGLL2)/NGLLX);
  I = (tx-K*NGLL2-J*NGLLX);

  // loads mesh values here to give compiler possibility to overlap memory fetches with some computations
  // note: arguments defined as realw* instead of const realw* __restrict__ to avoid that the compiler
  //       loads all memory by texture loads
  //       we only use the first loads explicitly by texture loads, all subsequent without. this should lead/trick
  //       the compiler to use global memory loads for all the subsequent accesses.
  //
  // calculates laplacian
  //xixl = get_global_cr( &d_xix[offset] ); // first array with texture load
  xixl = d_xix[offset];
  xiyl = d_xiy[offset]; // all subsequent without to avoid over-use of texture for coalescent access
  xizl = d_xiz[offset];
  etaxl = d_etax[offset];
  etayl = d_etay[offset];
  etazl = d_etaz[offset];
  gammaxl = d_gammax[offset];
  gammayl = d_gammay[offset];
  gammazl = d_gammaz[offset];

  jacobianl = 1.f / (xixl*(etayl*gammazl-etazl*gammayl)
                    -xiyl*(etaxl*gammazl-etazl*gammaxl)
                    +xizl*(etaxl*gammayl-etayl*gammaxl));

  // density (reciproc)
  rho_invl = 1.f / d_rhostore[offset];

  // loads hprime into shared memory
  if (tx < NGLL2) {
#ifdef USE_TEXTURES_CONSTANTS
    sh_hprime_xx[tx] = tex1Dfetch(d_hprime_xx_tex,tx);
#else
    sh_hprime_xx[tx] = d_hprime_xx[tx];
#endif
    // loads hprimewgll into shared memory
    sh_hprimewgll_xx[tx] = hprimewgll_xx[tx];
  }

  // synchronize all the threads (one thread for each of the NGLL grid points of the
  // current spectral element) because we need the whole element to be ready in order
  // to be able to compute the matrix products along cut planes of the 3D element below
  __syncthreads();

  // computes first matrix product
  temp1l = 0.f;
  temp2l = 0.f;
  temp3l = 0.f;

  for (int l=0;l<NGLLX;l++) {
    //assumes that hprime_xx = hprime_yy = hprime_zz
    // 1. cut-plane along xi-direction
    temp1l += s_dummy_loc[K*NGLL2+J*NGLLX+l] * sh_hprime_xx[l*NGLLX+I];
    // 2. cut-plane along eta-direction
    temp2l += s_dummy_loc[K*NGLL2+l*NGLLX+I] * sh_hprime_xx[l*NGLLX+J];
    // 3. cut-plane along gamma-direction
    temp3l += s_dummy_loc[l*NGLL2+J*NGLLX+I] * sh_hprime_xx[l*NGLLX+K];
  }

  // compute derivatives of ux, uy and uz with respect to x, y and z
  // derivatives of potential
  dpotentialdxl = xixl*temp1l + etaxl*temp2l + gammaxl*temp3l;
  dpotentialdyl = xiyl*temp1l + etayl*temp2l + gammayl*temp3l;
  dpotentialdzl = xizl*temp1l + etazl*temp2l + gammazl*temp3l;

  // form the dot product with the test vector
  if (threadIdx.x < NGLL3) {
    s_temp1[tx] = jacobianl * rho_invl * (dpotentialdxl*xixl + dpotentialdyl*xiyl + dpotentialdzl*xizl);
    s_temp2[tx] = jacobianl * rho_invl * (dpotentialdxl*etaxl + dpotentialdyl*etayl + dpotentialdzl*etazl);
    s_temp3[tx] = jacobianl * rho_invl * (dpotentialdxl*gammaxl + dpotentialdyl*gammayl + dpotentialdzl*gammazl);
  }

  // synchronize all the threads (one thread for each of the NGLL grid points of the
  // current spectral element) because we need the whole element to be ready in order
  // to be able to compute the matrix products along cut planes of the 3D element below
  __syncthreads();

  // computes second matrix product
  temp1l = 0.f;
  temp2l = 0.f;
  temp3l = 0.f;

  for (int l=0;l<NGLLX;l++) {
    //assumes hprimewgll_xx = hprimewgll_yy = hprimewgll_zz
    // 1. cut-plane along xi-direction
    temp1l += s_temp1[K*NGLL2+J*NGLLX+l] * sh_hprimewgll_xx[I*NGLLX+l];
    // 2. cut-plane along eta-direction
    temp2l += s_temp2[K*NGLL2+l*NGLLX+I] * sh_hprimewgll_xx[J*NGLLX+l];
    // 3. cut-plane along gamma-direction
    temp3l += s_temp3[l*NGLL2+J*NGLLX+I] * sh_hprimewgll_xx[K*NGLLX+l];
  }

  // summed terms with added gll weights
  fac1 = wgllwgll_yz[K*NGLLX+J];
  fac2 = wgllwgll_xz[K*NGLLX+I];
  fac3 = wgllwgll_xy[J*NGLLX+I];

  sum_terms = -(fac1*temp1l + fac2*temp2l + fac3*temp3l);

  // assembles potential array
  if (threadIdx.x < NGLL3) {
      atomicAdd(&d_potential_dot_dot_acoustic[iglob],sum_terms);
  }
}

*/


/* ----------------------------------------------------------------------------------------------- */

void Kernel_2_acoustic(int nb_blocks_to_compute, Mesh* mp, int d_iphase,
                       int* d_ibool,
                       realw* d_xix,realw* d_xiy,realw* d_xiz,
                       realw* d_etax,realw* d_etay,realw* d_etaz,
                       realw* d_gammax,realw* d_gammay,realw* d_gammaz,
                       realw* d_rhostore,
                       realw* d_kappastore){

#ifdef ENABLE_VERY_SLOW_ERROR_CHECKING
  exit_on_cuda_error("before acoustic kernel Kernel 2");
#endif

  // if the grid can handle the number of blocks, we let it be 1D
  // grid_2_x = nb_elem_color;
  // nb_elem_color is just how many blocks we are computing now
  int blocksize = NGLL3_PADDED;

  int num_blocks_x, num_blocks_y;
  get_blocks_xy(nb_blocks_to_compute,&num_blocks_x,&num_blocks_y);

  dim3 grid(num_blocks_x,num_blocks_y);
  dim3 threads(blocksize,1,1);

  // Cuda timing
  cudaEvent_t start, stop;
  if (CUDA_TIMING ){
    start_timing_cuda(&start,&stop);
  }

  // forward wavefields -> FORWARD_OR_ADJOINT == 1
  Kernel_2_acoustic_impl<1><<<grid,threads,0,mp->compute_stream>>>(nb_blocks_to_compute,
                                                                    d_ibool,
                                                                    mp->d_phase_ispec_inner_acoustic,
                                                                    mp->num_phase_ispec_acoustic,
                                                                    d_iphase,
                                                                    mp->d_potential_acoustic, mp->d_potential_dot_dot_acoustic,
                                                                    d_xix, d_xiy, d_xiz,
                                                                    d_etax, d_etay, d_etaz,
                                                                    d_gammax, d_gammay, d_gammaz,
                                                                    mp->d_hprime_xx,
                                                                    mp->d_hprimewgll_xx,
                                                                    mp->d_wgllwgll_xy, mp->d_wgllwgll_xz, mp->d_wgllwgll_yz,
                                                                    d_rhostore,
                                                                    mp->use_mesh_coloring_gpu,
                                                                    mp->gravity,
                                                                    mp->d_minus_g,
                                                                    d_kappastore,
                                                                    mp->d_wgll_cube);

  if (mp->simulation_type == 3) {
    // backward/reconstructed wavefields -> FORWARD_OR_ADJOINT == 3
    Kernel_2_acoustic_impl<3><<<grid,threads,0,mp->compute_stream>>>(nb_blocks_to_compute,
                                                                      d_ibool,
                                                                      mp->d_phase_ispec_inner_acoustic,
                                                                      mp->num_phase_ispec_acoustic,
                                                                      d_iphase,
                                                                      mp->d_b_potential_acoustic, mp->d_b_potential_dot_dot_acoustic,
                                                                      d_xix, d_xiy, d_xiz,
                                                                      d_etax, d_etay, d_etaz,
                                                                      d_gammax, d_gammay, d_gammaz,
                                                                      mp->d_hprime_xx,
                                                                      mp->d_hprimewgll_xx,
                                                                      mp->d_wgllwgll_xy, mp->d_wgllwgll_xz, mp->d_wgllwgll_yz,
                                                                      d_rhostore,
                                                                      mp->use_mesh_coloring_gpu,
                                                                      mp->gravity,
                                                                      mp->d_minus_g,
                                                                      d_kappastore,
                                                                      mp->d_wgll_cube);
  }

  // Cuda timing
  if (CUDA_TIMING ){
    realw flops,time;
    stop_timing_cuda(&start,&stop,"Kernel_2_acoustic_impl",&time);
    // time in seconds
    time = time / 1000.;
    // performance
    if (! mp->gravity) {
      if (! mp->use_mesh_coloring_gpu ){
        // see with: nvprof --metrics flops_sp ./xspecfem3D
        //           -> using 322631424 FLOPS (Single) floating-point operations for 20736 elements
        //              = 15559 FLOPS per block
        flops = 15559 * nb_blocks_to_compute;
      }else{
        // coloring
        flops = 15559 * nb_blocks_to_compute;
      }
    }else{
      // gravity
      flops = 15559 * nb_blocks_to_compute;
    }
    printf("  performance: %f GFlop/s\n", flops/time * 1.e-9);
  }

#ifdef ENABLE_VERY_SLOW_ERROR_CHECKING
  exit_on_cuda_error("kernel Kernel_2");
#endif
}

/* ----------------------------------------------------------------------------------------------- */

// main compute_forces_acoustic CUDA routine

/* ----------------------------------------------------------------------------------------------- */

extern "C"
void FC_FUNC_(compute_forces_acoustic_cuda,
              COMPUTE_FORCES_ACOUSTIC_CUDA)(long* Mesh_pointer,
                                            int* iphase,
                                            int* nspec_outer_acoustic,
                                            int* nspec_inner_acoustic) {

  TRACE("compute_forces_acoustic_cuda");
  //double start_time = get_time();

  Mesh* mp = (Mesh*)(*Mesh_pointer); // get Mesh from fortran integer wrapper

  int num_elements;

  if (*iphase == 1)
    num_elements = *nspec_outer_acoustic;
  else
    num_elements = *nspec_inner_acoustic;

  if (num_elements == 0) return;

  // mesh coloring
  if (mp->use_mesh_coloring_gpu ){

    // note: array offsets require sorted arrays, such that e.g. ibool starts with elastic elements
    //         and followed by acoustic ones.
    //         acoustic elements also start with outer than inner element ordering

    int nb_colors,nb_blocks_to_compute;
    int istart;
    int offset,offset_nonpadded;

    // sets up color loop
    if (*iphase == 1){
      // outer elements
      nb_colors = mp->num_colors_outer_acoustic;
      istart = 0;

      // array offsets (acoustic elements start after elastic ones)
      offset = mp->nspec_elastic * NGLL3_PADDED;
      offset_nonpadded = mp->nspec_elastic * NGLL3;
    }else{
      // inner element colors (start after outer elements)
      nb_colors = mp->num_colors_outer_acoustic + mp->num_colors_inner_acoustic;
      istart = mp->num_colors_outer_acoustic;

      // array offsets (inner elements start after outer ones)
      offset = ( mp->nspec_elastic + (*nspec_outer_acoustic) ) * NGLL3_PADDED;
      offset_nonpadded = ( mp->nspec_elastic + (*nspec_outer_acoustic) ) * NGLL3;
    }

    // loops over colors
    for(int icolor = istart; icolor < nb_colors; icolor++){

      nb_blocks_to_compute = mp->h_num_elem_colors_acoustic[icolor];

      Kernel_2_acoustic(nb_blocks_to_compute,mp,*iphase,
                         mp->d_ibool + offset,
                         mp->d_xix + offset,mp->d_xiy + offset,mp->d_xiz + offset,
                         mp->d_etax + offset,mp->d_etay + offset,mp->d_etaz + offset,
                         mp->d_gammax + offset,mp->d_gammay + offset,mp->d_gammaz + offset,
                         mp->d_rhostore + offset,
                         mp->d_kappastore + offset_nonpadded);

      // for padded and aligned arrays
      offset += nb_blocks_to_compute * NGLL3_PADDED;
      // for no-aligned arrays
      offset_nonpadded += nb_blocks_to_compute * NGLL3;
    }

  }else{

    // no mesh coloring: uses atomic updates
    Kernel_2_acoustic(num_elements, mp, *iphase,
                      mp->d_ibool,
                      mp->d_xix,mp->d_xiy,mp->d_xiz,
                      mp->d_etax,mp->d_etay,mp->d_etaz,
                      mp->d_gammax,mp->d_gammay,mp->d_gammaz,
                      mp->d_rhostore,
                      mp->d_kappastore);

  }
}



/* ----------------------------------------------------------------------------------------------- */

/* KERNEL for enforce free surface */

/* ----------------------------------------------------------------------------------------------- */


__global__ void enforce_free_surface_cuda_kernel(
                                       realw_p potential_acoustic,
                                       realw_p potential_dot_acoustic,
                                       realw_p potential_dot_dot_acoustic,
                                       const int num_free_surface_faces,
                                       const int* free_surface_ispec,
                                       const int* free_surface_ijk,
                                       const int* d_ibool,
                                       const int* ispec_is_acoustic) {
  // gets spectral element face id
  int iface = blockIdx.x + gridDim.x*blockIdx.y;

  // for all faces on free surface
  if (iface < num_free_surface_faces ){

    int ispec = free_surface_ispec[iface]-1;

    // checks if element is in acoustic domain
    if (ispec_is_acoustic[ispec] ){

      // gets global point index
      int igll = threadIdx.x + threadIdx.y*blockDim.x;

      int i = free_surface_ijk[INDEX3(NDIM,NGLL2,0,igll,iface)] - 1; // (1,igll,iface)
      int j = free_surface_ijk[INDEX3(NDIM,NGLL2,1,igll,iface)] - 1;
      int k = free_surface_ijk[INDEX3(NDIM,NGLL2,2,igll,iface)] - 1;

      int iglob = d_ibool[INDEX4_PADDED(NGLLX,NGLLX,NGLLX,i,j,k,ispec)] - 1;

      // sets potentials to zero at free surface
      potential_acoustic[iglob] = 0;
      potential_dot_acoustic[iglob] = 0;
      potential_dot_dot_acoustic[iglob] = 0;
    }
  }
}

/* ----------------------------------------------------------------------------------------------- */

extern "C"
void FC_FUNC_(acoustic_enforce_free_surf_cuda,
              ACOUSTIC_ENFORCE_FREE_SURF_CUDA)(long* Mesh_pointer,
                                               int* ABSORB_INSTEAD_OF_FREE_SURFACE) {

TRACE("acoustic_enforce_free_surf_cuda");

  Mesh* mp = (Mesh*)(*Mesh_pointer); //get mesh pointer out of fortran integer container

  // checks if anything to do
  if (*ABSORB_INSTEAD_OF_FREE_SURFACE == 0){

    // does not absorb free surface, thus we enforce the potential to be zero at surface

    // block sizes
    int num_blocks_x, num_blocks_y;
    get_blocks_xy(mp->num_free_surface_faces,&num_blocks_x,&num_blocks_y);

    dim3 grid(num_blocks_x,num_blocks_y,1);
    dim3 threads(NGLL2,1,1);

    // sets potentials to zero at free surface
    enforce_free_surface_cuda_kernel<<<grid,threads,0,mp->compute_stream>>>(mp->d_potential_acoustic,
                                                                             mp->d_potential_dot_acoustic,
                                                                             mp->d_potential_dot_dot_acoustic,
                                                                             mp->num_free_surface_faces,
                                                                             mp->d_free_surface_ispec,
                                                                             mp->d_free_surface_ijk,
                                                                             mp->d_ibool,
                                                                             mp->d_ispec_is_acoustic);
    // for backward/reconstructed potentials
    if (mp->simulation_type == 3) {
      enforce_free_surface_cuda_kernel<<<grid,threads,0,mp->compute_stream>>>(mp->d_b_potential_acoustic,
                                                                               mp->d_b_potential_dot_acoustic,
                                                                               mp->d_b_potential_dot_dot_acoustic,
                                                                               mp->num_free_surface_faces,
                                                                               mp->d_free_surface_ispec,
                                                                               mp->d_free_surface_ijk,
                                                                               mp->d_ibool,
                                                                               mp->d_ispec_is_acoustic);
    }
  }

#ifdef ENABLE_VERY_SLOW_ERROR_CHECKING
  exit_on_cuda_error("enforce_free_surface_cuda");
#endif
}

