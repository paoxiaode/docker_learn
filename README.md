# docker常用命令收集整理

## 启动容器

```bash
docker run  -i -t debian /bin/bash
docker run  -h CONTAINER -i -t debian /bin/bash #指定hostname
```

## 针对docker的操作

```bash
docker inspect #详细信息
docker diff    #查看文件改动
docker logs    #查看执行过的命令
