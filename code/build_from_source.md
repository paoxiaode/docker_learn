## Build pytorch from source 

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
## Build DGL from source

``` bash
git clone https://github.com/dmlc/dgl.git
git branch -a
git checkout -b 0.7.x origin/0.7.x
git submodule update --init --recursive
pip3 install torch==1.10.1+cu113 torchvision==0.11.2+cu113 torchaudio==0.10.1+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html

export DGL_HOME=/home/scratch.jiahuil_gpu/GNN/dgl_0.7_baseline
export DGL_LIBRARY_PATH=$DGL_HOME/build
export PYTHONPATH=$PYTHONPATH:$DGL_HOME/python


mkdir build
cd build
cmake .. -DCMAKE_VERBOSE_MAKEFILE=1 -DBUILD_TORCH=ON -DUSE_CUDA=ON -DUSE_NCCL=ON -DCMAKE_BUILD_TYPE=Release
make -j4
```