# MongoDB


使用docker下载mongoDB镜像
```shell
docker pull mongo
```

创建mongo容器
```shell
docker run -p 27017:27017 --name mongodb -d mongo
```




> 不要这样创建容器，可能使外部应用无法连接。因为这会使mongod没有在后台运行，被bash替代
> ```shell
>docker run -it --name mongodb  -p 27017:27017 -d mongo /bin/bash
>```