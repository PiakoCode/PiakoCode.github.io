# Tmux

新建会话
```shell
tmux new -s <name>
```

退出会话
```shell
tmux detach
ctrl + b -> d
```

列出所有会话
 ```shell
 tmux ls
```

左右分屏
```shell
ctrl + b -> %
```

上下分屏
```shell
ctrl + b -> "
```

关闭当前分屏
```shell
ctrl + b -> x
```

设定鼠标滚动支持：
```shell
tmux set mouse on
```


切换会话
```shell
ctrl + b -> 方向键
```


## 配置文件

`~/.tmux.conf`

开启鼠标
```text
set-option -g mouse on
```

让tmux在当前目录分屏
```text
bind-key c new-window -c "#{pane_current_path}"
bind-key % split-window -h -c "#{pane_current_path}"
bind-key '"' split-window -c "#{pane_current_path}"
```

https://zhuanlan.zhihu.com/p/345577995

```shell
echo "set-option -g mouse on
bind-key c new-window -c \"#{pane_current_path}\"
bind-key % split-window -h -c \"#{pane_current_path}\"
bind-key '\"' split-window -c \"#{pane_current_path}\"
" > .tmux.conf
```


`.tmux.conf`

```text
# 设置前缀键为 Ctrl + a
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# 面板导航快捷键（Vim 风格方向键）
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# 支持鼠标点击
set-option -g mouse on

# 在当前目录分屏
bind-key c new-window -c "#{pane_current_path}"
bind-key % split-window -h -c "#{pane_current_path}"
bind-key '"' split-window -c "#{pane_current_path}"

# 启用真彩色支持（确保终端支持 24-bit 颜色）
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

# 启用状态栏
set-option -g status on

# 自动调整窗格大小
setw -g aggressive-resize on

set -wg monitor-activity on # 非当前窗口有内容更新时在状态栏通知
set -g message-style "bg=#202529, fg=#91A8BA" # 指定消息通知的前景、后景色

# 设置渐变效果的状态栏背景颜色
set-option -g status-bg '#2E3440'   # 背景色
set-option -g status-fg '#D8DEE9'   # 文字颜色


# 设置状态栏内容
set -g status-left "#[fg=#81A1C1][#S] "
set -g status-right "#[fg=#88C0D0]%A %H:%M | #[fg=#A3BE8C]%Y-%m-%d "
# 窗口状态
set -g window-status-format "#[fg=white] #I #W "
set -g window-status-current-format "#[fg=white] [#I] #W "

```