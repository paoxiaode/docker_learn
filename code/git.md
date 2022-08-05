# git常用命令整理
:label:`工作区、暂存库、版本库`

![Primitive Tensor Function](../img/1352126739_7909.jpg)

:label:`Fork 工作流程`

![Primitive Tensor Function](../img/fork.jpg)


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
```


## 拉取最新的代码
```
# pull 自动合并
git pull
# fetch+merge 手动合并
git remote -v # 查看远程仓库
git fetch origin master:temp # 从远程的origin仓库的master分支下载到本地并新建一个temp分支
git diff temp # 查看temp分支与本地原有分支的不同
git merge temp # 合并
git branch -d temp # 删除分支

```
## git submodule
```
# ref: https://zhuanlan.zhihu.com/p/87053283
# 将一个git repo作为另一个git repo的子目录
#添加submodule
git submodule add <submodule_url> <submodule_path>
# 初始化主项目的子项目
git submodule init
git submodule update
# 删除
git submodule deinit project-sub-1
git rm project-sub-1
```

## fork项目管理

``` bash
# 拉取源项目最新代码
git remote add upstream git@xxxxxxx.git
git pull upstream {remote branch}:{local branch}
```

## pull代码冲突

``` bash
# error
Auto Merge Failed; Fix Conflicts and Then Commit the Result.
# method 1: give up local branch
git reset --hard origin/master
# method 2: metain the local branch
git add .
git commmit -m "commit"
# method 3: give up the pull, back to the last commit
git reset --hard HEAD
```