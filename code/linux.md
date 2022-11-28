# Linux常用命令和场景

## Reference :
https://www.runoob.com/linux/linux-command-manual.html


## 场景
软连接更改文件储存位置
``` bash
ln -s 原文件名 链接文件名
ln -s /mnt/data/.vscode-server/ ~/.vscode-server
```

查找文件夹特定名字的文件
``` bash
find /home -name "*.txt" 
```
查找文件夹大小
``` bash
du -h --max-depth=1 # 查看当前文件目录各个文件夹大小
```

后台运行命令并保存输出
``` bash
python test.py 2>&1 > test.log & # 后台运行
nohup python test.py 2>&1 > test.log & # 终端退出后仍然运行
```

查询进程
``` bash
ps -ef | grep php # 查询指定的进程
ps -u root # 显示root进程的用户信息
```
