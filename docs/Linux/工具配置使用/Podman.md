# Podman

## 安装

```shell
sudo pacman -S podman
```

## 镜像

[Podman - ArchWiki](https://wiki.archlinux.org/title/Podman#Registries)

先配置镜像仓库

```conf
# /etc/containers/registries.conf.d/10-unqualified-search-registries.conf

unqualified-search-registries = ["docker.io"]

```

```shell
podman pull debian:latest
```


## 容器

创建容器

```shell
sudo podman run --name dede debian:latest 
```

运行容器


```shell
podman start dede
podman exec --interactive --tty dede bash
```

> 运行不要使用 `sudo`
