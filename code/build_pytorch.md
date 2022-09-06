# Build pytorch from source 

Reference: https://khushi-411.github.io/installing-pytorch-from-source/
``` bash
# Change CUDA envs
export CUDA_HOME=/usr/local/cuda-11.6
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64
PATH=${CUDA_HOME}/bin:${PATH}
export PATH

# set envs
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

export PATH=/usr/local/cuda/bin/:$PATH
# Add cudnn lib
cp -r cudnn-linux-x86_64-8.5.0.96_cuda11-archive/include/cudnn* /usr/local/cuda/include
cp -r cudnn-linux-x86_64-8.5.0.96_cuda11-archive/lib/libcudnn* /usr/local/cuda/lib64
cd pytorch
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
python3 setup.py develop
```
