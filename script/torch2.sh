docker pull ghcr.io/pytorch/pytorch-nightly
docker run --gpus all -it  -v /home/ubuntu/code:/workspace2  ghcr.io/pytorch/pytorch-nightly:latest bash -c 'echo "export DGL_HOME='/workspace2/dgl'">>/root/.bashrc && echo "export DGL_LIBRARY_PATH='/workspace2/dgl/build'" >> /root/.bashrc && echo "export PYTHONPATH='/workspace2/dgl/python'" >> /root/.bashrc && bash'

