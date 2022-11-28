# docker常用命令收集整理
  - [docker常用命令收集整理](#docker常用命令收集整理)
  - [启动/停止容器](#启动停止容器)
  - [针对docker的操作](#针对docker的操作)
  - [创建镜像（image）](#创建镜像image)
  - [使用寄存服务](#使用寄存服务)
## 启动/停止容器

```bash
docker run  -i -t debian /bin/bash
docker run  -h CONTAINER -i -t debian /bin/bash #指定hostname
docker run --name myredis -d redis  #-d 后台执行，执行image名称
# --rm 删除之前的image --it 交互启动
# --privileged 给予容器管理员权限
# -v 挂载目录 -v /home/jiahuil/:/workspace/ -v /home/mzhu/:/workspace2/
# --shm-size 8G 指定共享内存大小

docker rm NAME #删除容器
docker rm $(docker ps -aq) #删除所有容器
docker start NAME #重启容器
docker attach NAME #进入容器
```

## 针对docker的操作

```bash
docker ps -a   #查看所有容器
docker inspect #详细信息
docker diff    #查看文件改动
docker logs    #查看执行过的命令

docker images # list all the images
docker rmi image # delete images

docker login -u user -p password
docker logout

docker system df # show docker container space
```

## 创建镜像（image）
```bash
docker build -t test/cowsay-dockerfile . #需要在dockerfile目录下，-t指定名称
```
## 使用寄存服务
```bash
docker login # login docker hub
docker build -t jiahuil/cowsay-dockerfile . #需要在dockerfile目录下，-t指定名称
docker push jiahuil/cowsay-dockerfile 

```