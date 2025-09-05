# Systemd

### 自动化脚本

目录位置: `~/.config/systemd/user/`


目录位置: `~/.config/systemd/user/`

### 创建用户级服务单元

用户级服务单元文件用于定义和管理用户级别的后台服务、定时任务等。

**创建服务单元文件示例：**

```bash
mkdir -p ~/.config/systemd/user/
nano ~/.config/systemd/user/myservice.service
```

**服务单元文件内容示例：**

```ini
[Unit]
Description=My Custom User Service
After=network.target

[Service]
Type=simple
ExecStart=/home/username/path/to/your/script.sh
Restart=on-failure
Environment=MY_VARIABLE=some_value

[Install]
WantedBy=default.target
```

### 创建用户级定时器

定时器单元用于按计划执行任务，类似于cron作业。

**创建定时器单元文件示例：**

```bash
nano ~/.config/systemd/user/mytimer.timer
```

**定时器单元文件内容示例：**

```ini
[Unit]
Description=Run my script daily
Requires=myservice.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

**对应的服务单元文件：**

```bash
nano ~/.config/systemd/user/mytimer.service
```

```ini
[Unit]
Description=My Timer Service

[Service]
Type=oneshot
ExecStart=/home/username/path/to/your/task.sh
EnvironmentFile=%h/.config/environment.d/90-my-vars.conf
```

### 常用操作命令

**启用和启动服务：**

```bash
# 重新加载配置
systemctl --user daemon-reload

# 启用服务（开机自启）
systemctl --user enable myservice.service

# 启动服务
systemctl --user start myservice.service

# 启用定时器
systemctl --user enable mytimer.timer
systemctl --user start mytimer.timer
```

**查看服务状态：**

```bash
# 查看服务状态
systemctl --user status myservice.service

# 查看所有用户服务
systemctl --user list-units

# 查看定时器状态
systemctl --user list-timers
```

**日志查看：**

```bash
# 查看服务日志
journalctl --user -u myservice.service

# 实时查看日志
journalctl --user -u myservice.service -f
```

### 环境变量继承

服务可以继承用户环境变量：

```ini
[Service]
EnvironmentFile=%h/.config/environment.d/90-my-vars.conf
ExecStart=/usr/bin/env bash -c 'echo $MY_VARIABLE'
```

### 注意事项

1. **用户会话持久性**：确保用户会话在登录后保持活动状态
2. **路径使用绝对路径**：避免使用~或相对路径
3. **权限管理**：用户级服务以当前用户权限运行
4. **日志管理**：使用journalctl查看用户级服务日志

通过systemd用户级服务，可以实现精细化的用户级别进程管理和自动化任务调度。