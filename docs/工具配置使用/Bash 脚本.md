# Bash 脚本

#linux 

```bash
#!/bin/bash

# 这是一个注释，用于说明脚本的目的或特定部分的功能

# 定义变量
name="World"

# 输出文本
echo "Hello, $name!"

# 执行命令
echo "当前目录："
pwd

# 使用条件语句
if [ -d "/path/to/directory" ]; then
    echo "目录存在"
else
    echo "目录不存在"
fi

# 使用循环
for i in {1..5}; do
    echo "循环次数：$i"
done

# 定义和使用函数
hello() {
    echo "Hello, $1!"
}

hello "John"
```

将以上代码保存为一个以`.sh`为后缀的文件（例如`script.sh`）

```shell
chmod +x srcipt.sh
```

