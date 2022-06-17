# docker常用命令收集整理

## 启动/停止容器

```bash
docker run  -i -t debian /bin/bash
docker run  -h CONTAINER -i -t debian /bin/bash #指定hostname
docker run --name myredis -d redis  #-d 后台执行，执行image名称
# --rm 删除之前的image --it 交互启动
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
```

## 创建镜像（image）
```bash
docker build -t test/cowsay-dockerfile . #需要在dockerfile目录下，-t指定名称
```