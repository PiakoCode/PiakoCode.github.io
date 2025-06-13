## mysql安装到服务器

### 服务器下载mysql

````shell
# 通过Ubuntu源仓库来安装mysql
sudo apt update
sudo apt install mysql-server

# 安装mysql完成，mysql服务将会自动启动，验证mysql服务器正在运行，
sudo systemctl status mysql

# mysql的启动
systemctl start mysql 

#mysql的停止
systemctl stop mysql
````

### 为mysql添加和配置用户权限



```shell
# 当安装好mysql后，直接mysql会登录不上，不知道用户名和密码，其实安装mysql数据库时自动为你设置自动设置账号密码，放在/etc/mysql/debian.cnf文件中

sudo cat /etc/mysql/debian.cnf
其中的user和password字段就是设置mysql的账号和密码

# 使用mysql -u 用户名 -p 回车 输入密码访问进入数据
mysql -u 用户名 -p  回车
密码

# 为mysql创建用户并设置密码并授予权限
create USER 'root'@'%' IDENTIFIED BY '新的密码' #创建用户
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```



### mysql配置远程链接

```shell
# 设置当前数据库可以远程访问并开发相应权限

#默认情况下，mysql账号不允许远程登录，只能在localhost登录

# mysql的配置文件通常在： /etc/mysql/my.cnf 或在/etc/mysql/mysql.conf.d/mysqld.cnf

# 在mysql的用户表user中将host字段的值改为%,%表示任何客户端机器上都能以该用户登录到mysql服务器，并授予该用户所有权限
update user set host = '%' where user = 'root' 

GRANT ALL  PRIVILEGES ON *.* TO '用户名'@'%'IDENTIFIED BY '密码' WITH GRANT OPTION;    
# 查看防火墙状态
# 服务器设置安全组之后，服务器端口无法访问，要远程链接需要在服务器上开发相应的端口，允许数据库服务的端口可以通过

firewall-cmd --list-ports #查看开放的端口列表

# 开放 自己的端口
firewall-cmd --zone=public --add-port=自己想开放的端口/tcp --permanent

# 关闭自己的端口
firewall-cmd --zone=public --remove-port=自己想开放的端口/tcp --permanent

# 重启防火墙
systemctl restart firewalld.service

# 再次确认 自己的端口 是否开放
firewall-cmd --list-ports


# 查看3306端口状态
netstat -an | grep 3306
--如果发现被绑定ip地址配置文件则修改配置文件并重启启动数据库

#修改配置文件，在/etc/mysql/mysql.conf.d文件下的mysqld.cnf中找到bind-address那一行注释掉

#重启mysql
sudo systemctl restart mysql


# 直接使用dataGrip测试链接
```





	## 服务器安装redis

```shell
1.安装redis
apt-get install redis-server
2.查看安装状态
service redis-server status
```

## redis远程链接

```shell
# redis 的配置文件一般在/etc/redis/redis.conf

#打开redis配置文件
vi /etc/redis/redis.conf

#将bind 127.0.0.1注释

#将protected-mode改为no
protected-mode no

#添加密码
requirepass 123456

#重启redis服务器
systemctl restart redis-server

#设置redis开机自启动
systemctl enable redis-server.service

# 重启redis
sudo systemctl restart redis-server


# 关闭自己的端口
firewall-cmd --zone=public --add-port=自己想开放的端口/tcp --permanent

# 重启防火墙
systemctl restart firewalld.service

# 再次确认 自己的端口 是否开放
firewall-cmd --list-ports



```

