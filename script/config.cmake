set(USE_CUDA ON)
set(USE_NCCL OFF)
set(BUILD_CPP_TEST OFF)

#---------------------------------------------
# Misc.
#---------------------------------------------
# Whether to build cpp unittest executables.
# set(BUILD_CPP_TEST OFF)

# Whether to enable OpenMP.
set(USE_OPENMP ON)

# Whether to enable Intel's avx optimized kernel.
set(USE_AVX ON)

# Whether to build PyTorch plugins.
set(BUILD_TORCH ON)
set(BUILD_SPARSE ON)

# Whether to enable CUDA kernels compiled with TVM.
set(USE_TVM OFF)

# Whether to enable fp16 to support mixed precision training.
set(USE_FP16 ON)
