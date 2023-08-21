# CUDA

doc:

[CUDA C++ Programming Guide (nvidia.com)](https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html?highlight=__shfl_xor_sync#warp-shuffle-functions)

[NVIDIA CUDA Compiler Driver NVCC](https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#)

[cuSPARSE (nvidia.com)](https://docs.nvidia.com/cuda/cusparse/index.html#)

[Matching CUDA arch and CUDA gencode for various NVIDIA architectures](https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/)


sample:

https://github.com/NVIDIA/cuda-samples

https://github.com/NVIDIA/CUDALibrarySamples

tutorial

[Course on CUDA Programming (ox.ac.uk)](https://people.maths.ox.ac.uk/gilesm/cuda/index_Oden22.html)

[Using CUDA Warp-Level Primitives | NVIDIA Technical Blog](https://developer.nvidia.com/blog/using-cuda-warp-level-primitives/)

[Accelerating Matrix Multiplication with Block Sparse Format and NVIDIA Tensor Cores | NVIDIA Technical Blog](https://developer.nvidia.com/blog/accelerating-matrix-multiplication-with-block-sparse-format-and-nvidia-tensor-cores/)

[Cooperative Groups: Flexible CUDA Thread Programming | NVIDIA Technical Blog](https://developer.nvidia.com/blog/cooperative-groups/)


## error check

``` CUDA
#define CHECK_LAST_CUDA_ERROR() checkLast(__FILE__, __LINE__)
void checkLast(const char* const file, const int line)
{
    cudaError_t err = cudaDeviceSynchronize();
    if (err != cudaSuccess)
    {
        std::cerr << "CUDA Runtime Error at: " << file << ":" << line
                  << std::endl;
        std::cerr << cudaGetErrorString(err) << std::endl;
        // We don't exit when we encounter CUDA errors in this example.
        // std::exit(EXIT_FAILURE);
    }
}

__global__ void kernel1(int a)
{
    float IDsum = a + 1;
    // printf("Thread %d %d final value = %f\n", threadIdx.x, threadIdx.y, IDsum);
}

int main()
{
    // cudaFuncSetAttribute(kernel, cudaFuncAttributeMaxDynamicSharedMemorySize, 65536);
    kernel1<<<dim3(512, 1,1), dim3(32, 1,1)>>>(1);
    CHECK_LAST_CUDA_ERROR();
    return 0;
}
```
