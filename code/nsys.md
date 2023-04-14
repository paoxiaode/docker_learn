# nsight compute 使用

REF:

[nsight-systems UserGuide](https://docs.nvidia.com/nsight-systems/UserGuide/index.html)

[Hands-On Session with NSight Systems and Compute](https://www2.cisl.ucar.edu/events/gpu-series-hands-session-nsight-systems-and-compute)

## 常用指令
``` bash
export PROF_TARGET_PASS="NVPROF"
export PROF_TARGET_SESSION="2"
export PROF_TARGET_RANGE="2"
export PROF_EARLY_EXIT=true
export PYTHONPATH="/workspace2/python_profiler/:$PYTHONPATH"

nsys profile -o output --stats true --force-overwrite true -c cudaProfilerApi --kill none python train.py 

nsys stats --output output_dir  output.nsys-rep
nsys stats -f csv output.sqlite > output.csv
```