# git常用命令整理
<img src="../img/1352126739_7909.jpg" >
<center>
<img src="../img/fork.jpg">
<br>
<div style="color: #999; padding: 2px;color:orange; border-bottom: 1px solid #d9d9d9;display: inline-block;color: #999;">
Fork 流程示意图</div>
</center>

``` bash
# 常用指令
git clone # 拉取代码
git branch # -a 查询所有分支 -d 删除分支
git status # 显示所有文件的状态（tracked, staged)
git diff 分支名 # 两个分支的区别
git diff # 比较工作区和暂存区文件区别，不包含新添加untracked的文件
git checkout # 切换/新建分支
git push -u origin master # 推送代码
ssh-keygen -t rsa -f ~/.ssh/gitlab-rsa # 生成新的ssh key
git remote set-url origin https://git-repo/new-repository.git

# 推送代码
git add .
git commit -m "commit"
git push orgin master

# 拉取远程分支
git branch -a 
git checkout -b 本地分支名 origin/远程分支名

# 撤回上一次commit
git reset HEAD^

# 撤回多次之前的commit
git reflog # 查询HEAD
git reset [HEAD] # 回退

# 拉取最新的代码
# pull 自动合并
git pull
# fetch+merge 手动合并
git remote -v # 查看远程仓库
git fetch origin master:temp # 从远程的origin仓库的master分支下载到本地并新建一个temp分支
git diff temp # 查看temp分支与本地原有分支的不同
git merge temp # 合并
git branch -d temp # 删除分支
```