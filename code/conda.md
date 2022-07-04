# conda/pip常用命令收集整理

## conda

``` bash
### 虚拟环境配置
conda create -n test python=3.8
conda activate
conda deactivate
conda remove -n test --all #删除环境

conda env export > env.yml #导出环境
conda env create -f env.yml #基于yaml文件创建环境
conda env list #所有的虚拟环境
```

## pip
``` bash
pip install python==3.8
pip list
pip install --upgrade SomePackage #升级
pip uninstall SomePackage #卸载
```