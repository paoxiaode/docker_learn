# git常用命令整理
<img src="../img/1352126739_7909.jpg" >

* 拉取代码：git clone
* 更新分支代码：git pull
* 查询分支：git branch
* 显示所有文件的状态（tracked, staged): git status
* 切换/新建分支：git checkout
* 推送代码：git push -u origin master
* 撤回上一次commit：git reset HEAD^
* 回退：git reset [HEAD]
* 查询HEAD: git reflog
* 设置远程地址：git remote set-url origin [url] 
    * url尽量使用ssh连接，不要git连接，可以不用输密码
* 比较工作区和暂存区文件区别：git diff
* 生成新的ssh key: ssh-keygen -t rsa -f ~/.ssh/gitlab-rsa

Reference:
Git 教程 | 菜鸟教程 (runoob.com)