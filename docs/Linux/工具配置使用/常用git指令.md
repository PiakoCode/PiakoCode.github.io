# 常用git指令

```shell
git init					    # 初始化仓库
```

```bash
git add 文件名   				  # 将文件添加到缓存区
git add .
```

```bash
git commit -m "message" 		# 将缓存区的文件添加到本地仓库
```

```bash
git status					    # 查看仓库当前的状态
git status -vv                  # 查看仓库当前的详细状态
```

```bash
git diff						# 缓存区和工作区文件的差异
git diff <文件...>              # 缓存区和工作区<文件...>的差异
```

```bash
git rm    						# 删除本地仓库的文件
```

```bash
git log     					# 查看历史提交记录
```

```bash
ssh-keygen -t rsa -C "github上注册的电子邮箱"              # 生成SSH密钥
```

```bash
git pull      					  # 下载远程代码并合并
git pull [remote_name] [branch_name]
```

```shell
git fetch
```

```bash
git push      				      # 上传文件至远程库
git push [remote_name] [branch_name]
git push origin master            # 上传文件至名为origin的远程库的master分支
```

```bash
git remote add origin [server_url]	  # 添加远程服务器的url或路径，并命名为 "origin"
```

```shell
git checkout <分支名>     # 切换分支
git checkout -b <分支名>  # 切换分支(如果该分支不存在，则创建该分支)
```

```shell
git cherry-pick [commit_hash]
```

暂存

```shell
git commit # 提交
git stash  # 暂存
git pull   # 拉取内容

git stash pop  # 恢复暂存的内容
git stash drop # 删除一个暂存的内容
```


```shell
git stash list # 显示暂存列表
```

设定初始分支名

```shell
git config --global init.defaultBranch <名称>
```

`git clone`指定分支
```shell
git clone -b [branch_name] [git_url]
```

**submodule**

向当前git仓库添加submodule

```shell
git submodule add <url> <path/to/directory>
```

添加后会生成`.gitmodules`文件


下载/更新submodule

```git 
git submodule update --init [submodule names]

git submodule init

git submodule update

git submodule update --init --recursive

git submodule sync
```

clone时同时clone子模组
```shell
git clone --recurse-submodules [remote_url]
```

merge

合并无关的分支

```shell
git merge [branch_name] --allow-unrelated-histories
```

tag

```shell
git tag # 列出本地所有标签
git tag -l
```

```shell
git ls-remote --tag # 列出远程标签
```

创建tag

```shell
git tag [标签名]
git tag v0.1.1
```

切换tag并创建分支(直接checkout会出现分离的头指针)

```shell
git checkout -b [branch_name] [tag_name]
```



## **.gitignore**


   - **忽略单个文件**：指定文件名或相对路径。
     ```
     example.txt
     ```
   - **忽略整个目录**：在目录名称后加 `/`。
     ```
     logs/
     ```
   - **忽略特定扩展名的文件**：使用通配符。
     ```
     *.log
     ```
   - **排除特定文件**：使用 `!` 来取消忽略。
     ```
     !important.log
     ```
   
*重要提示*

- `.gitignore` 文件只能忽略那些还未被 Git 跟踪的文件。如果某个文件已经被 Git 跟踪了，即使添加了 `.gitignore` 规则，它仍然会被跟踪。要忽略已跟踪的文件，需要先从 Git 中移除该文件。

  ```bash
  git rm --cached <file>
  ```


常见的 `.gitignore` 示例：

- 忽略所有的编译文件（比如 C++ 中的可执行文件和中间文件）：
  ```gitignore
  *.o
  *.out
  *.exe
  ```

- 忽略所有的日志文件：
  ```gitignore
  *.log
  ```

- 忽略某个特定文件夹：
  ```gitignore
  temp/
  ```

- 忽略所有的环境配置文件：
  ```gitignore
  .env
  ```



```
# 忽略所有文件，除了.cpp、.txt文件、makefile以及.gitignore

*

!*.cpp
!*.txt
!makefile
!.gitignore
```

```
# Ignore all files
*

# But don't ignore .cpp and .hpp files
!*.cpp
!*.hpp
!*.h
!*.c
!CMakeLists.txt
!README.md


*/*

!.gitignore
!*/

!**/*.cpp
!**/*.hpp
!**/*.h
!**/*.c
!**/CMakeLists.txt
!**/.clang-format

*/build
```



## 相关资料

[高质量的 Git 中文教程，源于国外社区的优秀文章和个人实践](https://github.com/geeeeeeeeek/git-recipes)

[《Pro Git》Git官方书籍(中文)](https://git-scm.com/book/zh/v2)





##  错误解决

OpenSSL SSL_read: Connection was aborted, errno 10054

解决方法参考:  [作者：云梦&&玄龙](https://www.cnblogs.com/fairylyl/p/15059437.html)   或   [作者：Herio](https://blog.51cto.com/u_15326986/3328947)



[解决 ssh: connect to host github.com port 22: Connection timed out](https://segmentfault.com/a/1190000040896781)


---

如果无法正常验证身份, 试试使用*ssh链接*而非https链接



## git commit 规范

[Commit message 和 Change log 编写指南 - 阮一峰的网络日志](https://www.ruanyifeng.com/blog/2016/01/commit_message_change_log.html)

[way/appendixs/wiki/git-commit.md at master · o-w-o/way · GitHub](https://github.com/o-w-o/way/blob/master/appendixs/wiki/git-commit.md)


相关工具：

https://github.com/commitizen/cz-cli