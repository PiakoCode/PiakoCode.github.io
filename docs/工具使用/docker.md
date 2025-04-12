# docker 使用

## 基本使用

将docker添加到用户组
```shell
# sudo
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp - docker
```

搜索镜像
```
docker search [keyword]
```



创建一个容器，并可以使用bash交互
```shell
docker run -it <image> bash
```

列出容器
```shell
# 列出目前正在运行的docker容器
docker ps

# 列出所有 docker 容器（包括停止的容器）
docker ps -a
```



列出所有的镜像
```shell
docker image ls 
```

运行镜像, 创建容器，端口映射到80
```shell
docker run -p 80:8080 <image>
```

创建一个容器并后台运行
```shell
docker run -d [image]
```


获取并查看容器的日志
```shell
docker logs -f <container>
```

本地目录挂载到docker容器目录
```shell
docker run -v /本地文件夹路径:/容器内目标路径 <image>
```

指定容器内命令的工作目录
```
docker run -w /app myimage 命令
```

> `-w`选项仅影响容器内部的命令。它不会改变容器本身的工作目录。


docker run

-i 获取STDIN
-t 给予容器一个tty

重启容器
```shell
docker restart <container> 
```


修改docker默认使用的shell(需要容器正在运行)，退出后容器不会停止运行
```shell
docker exec -it <container> /bin/bash
```

```shell
docker exec -it <container> /bin/bash -c "apt update" # 打开容器，并执行'apt update',随后退出
docker exec -it <container> /bin/bash -c "apt update; bash" # 打开容器，并执行'apt update',随后不会退出
```

连接容器（退出后，容器便会停止运行）
```shell
docker attach <container>
```

Ubuntu docker开发环境快速配置

```shell
sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list ; #配置ustc镜像源 \
apt update;\
apt upgrade -y;\
apt install -y curl sudo ssh vim fish neofetch tree make git gcc gdb build-essential htop wget python3 tmux;

```

修改默认shell
```shell
chsh -s $(which fish)
```


debian **仅docker容器**

参见： [Debian - USTC Mirror Help](https://mirrors.ustc.edu.cn/help/debian.html#__tabbed_1_2)

```shell
sudo sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources
```

非docker容器

```shell
sudo sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
```


## Dockerfile


Dockerfile示例

> 构建Ubuntu镜像

```
# Set the base image 
FROM ubuntu:latest

RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list

# Update the repository sources list
RUN apt update

# Upgrade any pre-installed packages
RUN apt upgrade -y

# Install necessary packages
RUN apt install -y curl sudo ssh vim fish neofetch tree make git gcc gdb build-essential htop wget python3 tmux
```



```shell
docker build --tag <image-name>:<image-version> -f /path/to/Dockefile .
```