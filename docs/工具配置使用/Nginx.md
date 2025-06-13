# Nginx

[Docker Nginx安装使用以及踩坑点总结 - LiangSenCheng小森森 - 博客园](https://www.cnblogs.com/LiangSenCheng/p/17550132.html)

[NGINX 备忘清单 & nginx cheatsheet & Quick Reference](https://quickref.me/zh-CN/docs/nginx.html)

启动
```bash
nginx           # 启动
nginx -s reload # 重启
nginx -s quit   # 平滑关闭nginx
nginx -s stop   # 关闭进程
nginx -V        # 查看nginx的安装状态
sudo nginx -t   # 检查nginx.conf语法
```

>[!note]
> nginx默认端口为80

使用`whereis nginx`查看nginx的目录位置

```shell
whereis nginx
nginx: /usr/sbin/nginx /usr/lib/nginx /etc/nginx /usr/share/nginx
```


全局变量
```nginx
$host	# 请求主机头字段，否则为服务器名称
```


简单代理
```nginx
location / {
  proxy_pass http://127.0.0.1:3000;
  proxy_redirect      off;
  proxy_set_header    Host $host;
}
```

