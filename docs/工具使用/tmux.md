# Tmux

## 基本操作

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



## 复制模式(vim)

### 进入复制模式（Copy Mode）

按下 `Ctrl + b`，然后按 `[` 键，进入复制模式。

### 导航

在复制模式下，可以使用以下 Vim 风格的按键进行导航：

- `h` / `j` / `k` / `l`：左 / 下 / 上 / 右移动
    
- `w` / `b`：跳转到下一个 / 上一个单词的开头
    
- `0` / `$`：跳转到行首 / 行尾
    
- `gg` / `G`：跳转到文本开头 / 结尾
    
- `Ctrl + u` / `Ctrl + d`：向上 / 向下滚动半页
    
- `Ctrl + b` / `Ctrl + f`：向上 / 向下滚动一页
    
- `/` / `?`：向下 / 向上搜索
    
- `n` / `N`：重复上一次搜索，方向相同 / 相反
    

### 选择和复制文本

1. 按下 `Space` 键，开始选择文本。
    
2. 使用导航键移动光标，选中所需文本。
    
3. 按下 `Enter` 键，复制选中的文本并退出复制模式。[DEV Community](https://dev.to/iggredible/the-easy-way-to-copy-text-in-tmux-319g)
    

### 粘贴文本

按下 `Ctrl + b`，然后按 `]` 键，粘贴之前复制的内容。




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



- `前缀 + d`：分离当前会话（会话在后台继续运行）。
- `前缀 + s`：列出所有会话，可切换。
- `前缀 + $`：重命名当前会话。
- `tmux new -s <name>`：新建命名会话（命令行操作）。
- `tmux attach -t <name>`：重新接入指定会话（命令行操作）。

---

- `前缀 + c`：新建窗口。
- `前缀 + ,`：重命名当前窗口。
- `前缀 + &`：关闭当前窗口（需确认）。
- `前缀 + p`：切换到上一个窗口。
- `前缀 + n`：切换到下一个窗口。
- `前缀 + 数字`：快速跳转到指定编号窗口（如 `前缀 + 1`）。
- `前缀 + w`：列出所有窗口，可切换。

---

- `前缀 + %`：垂直分割面板（左右布局）。
- `前缀 + "`：水平分割面板（上下布局）。
- `前缀 + 方向键`：切换焦点到指定方向的面板。
- `前缀 + z`：最大化/恢复当前面板（再按一次恢复）。
- `前缀 + x`：关闭当前面板（需确认）。
- `前缀 + 空格`：切换面板布局（循环切换）。
- `前缀 + Alt+方向键`：调整面板大小（需开启配置支持）。
- `前缀 + {` 或 `}`：向前/向后移动当前面板。

---

- `前缀 + [`：进入复制模式（用方向键浏览，`q` 退出）。
  - 复制模式中：按 `空格` 开始选择，`Enter` 复制选中内容。
  - 粘贴：`前缀 + ]`。
- `前缀 + t`：显示时钟（再按取消）。
- `前缀 + ?`：查看所有快捷键帮助（按 `q` 退出）。
- `前缀 + :`：进入命令行模式（输入 tmux 命令）。


[Tmux 使用教程 - 阮一峰的网络日志](https://www.ruanyifeng.com/blog/2019/10/tmux.html)