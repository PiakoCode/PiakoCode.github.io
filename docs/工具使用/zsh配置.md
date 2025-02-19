```shellrc
##### zsh 配置文件 #####  
  
# 脚本路径  
export PATH=$PATH:/home/piako/Codes/MyScript  
  
##### exa alias #####  
  
# 查看当前目录下的文件  
alias ls='eza --icons --git'  
alias l='eza --icons --git'  
alias ll='eza --long --icons --git'  
  
# 查看当前目录下的文件(树状)  
alias lt='eza -T --level=2 --icons --git --git-ignore'  
  
# 查看当前目录下的所有文件  
alias la='eza -a --icons --git'  
  
# 查看当前目录下的所有文件(长格式)  
alias lla='eza -a -l --icons --git'  
  
# 查看当前目录下的文件(长格式)  
alias lsf='eza -l --icons --git'  
  
# 查看当前目录下的文件夹  
alias lsd='eza -l --icons --git --only-dirs'  
  
##### exa alias #####  
  
  
  
# nvm setting  
# Set up Node Version Manager  
source /usr/share/nvm/init-nvm.sh  
  
# yazi 配置 提供了在退出 Yazi 时更改当前工作目录的功能  
function y() {  
   local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd  
   yazi "$@" --cwd-file="$tmp"  
   if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then  
       builtin cd -- "$cwd"  
   fi  
   rm -f -- "$tmp"  
}  
  
alias yazi=y  
  
# wayland vscode设置  
# alias code='code --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime '  
  
##### fzf设置 #####  
  
# 读取快捷键绑定配置  
source <(fzf --zsh)  
  
# 使用fzf + cd 打开目录  
  
fcd() {  
   local dir  
   dir=$(fd --type d | fzf --reverse --height 50% --preview "eza --tree --color=always --git-ignore {}") && cd "$di  
r" || exit  
  
}  
  
# 使用fzf + code 打开文件夹  
  
fco() {  
   local dir  
   dir=$(fd --type d | fzf --reverse --height 50% --preview "eza --tree --color=always --git-ignore {}") && code "$  
dir"  
}  
  
# 使用fzf + code打开文件  
  
fcf() {  
   local file  
   file=$(fd . -H --type f -E .git | fzf --reverse --preview "[[ $(file --mime {}) =~ binary ]] && echo 'Binary fil  
e' || bat --style=numbers --color=always --line-range :200 {}") && code "$file"  
}  
  
# 定义一个新的 z 函数，封装原 z 函数并输出当前目录路径  
function z() {  
  
   __zoxide_z "$@"  
  
   # 输出当前目录路径  
   pwd  
}  
  
# 在当前位置启动dolphin，并退出终端  
alias dole='dolphin . & disown; exit'  
# 在当前位置启动dolphin  
alias dol='dolphin . & disown'  
  
# xdg-open: 使用默认应用程序打开文件  
alias open='xdg-open'  
  
alias opene='open . ; exit'  
  
# 退出    
alias e='exit'  
  
  
# 配置pyenv  
export PYENV_ROOT="$HOME/.pyenv"  
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"  
eval "$(pyenv init - zsh)"  
  
  
  
  
function cur() {  
   cursor $1 &; disown  
   exit  
}  
  
# 编辑zsh配置文件    
alias ezshrc='cursor ~/.zsh_conf_rc'  
  
# 配置python  
alias py='python'  
  
# 配置ipython  
alias ipy='ipython'  
  
alias coa="conda activate pytorch"  
alias cod="conda deactivate"  
  
alias vi='nvim'  
alias vim='nvim'

```