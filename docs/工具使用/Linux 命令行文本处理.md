# Linux 命令行文本处理

Linux 命令行提供了丰富的文本处理工具，适用于日志分析、数据提取、格式转换等场景。以下是常用工具及示例：

---

### **1. 基础工具**
#### **`cat`**  
查看/合并文件内容  
```bash
cat file.txt            # 查看文件
cat file1.txt file2.txt > merged.txt  # 合并文件
```

#### **`grep`**  
按模式搜索文本  
```bash
grep "error" log.txt          # 搜索包含 "error" 的行
grep -i "warning" log.txt     # 忽略大小写
grep -v "success" log.txt     # 反向匹配（排除含 "success" 的行）
grep -E "error|warning" log   # 正则匹配（等价于 egrep）
```

#### **`sed`**  
流编辑器，用于替换、删除、插入文本  
```bash
sed 's/old/new/g' file.txt      # 全局替换 old 为 new（仅输出到终端）
sed -i 's/old/new/g' file.txt   # 直接修改原文件
sed '2d' file.txt               # 删除第2行
sed '/pattern/d' file.txt       # 删除匹配的行
sed -n '3,5p' file.txt          # 打印3-5行
```

#### **awk**  
处理结构化文本（如按列操作）  
```bash
awk '{print $1, $3}' file.txt        # 打印第1列和第3列
awk -F':' '{print $1}' /etc/passwd   # 以冒号分隔，打印第1列
awk '$3 > 100 {print $0}' data.txt   # 筛选第3列大于100的行
awk '{sum += $1} END {print sum}' data.txt  # 计算第1列总和
```

---

### **2. 进阶工具**
#### **`cut`**  
按列切割文本  
```bash
cut -d',' -f1,3 data.csv   # 以逗号分隔，取第1和3列
cut -c1-5 file.txt         # 取每行前5个字符
```

#### **`sort`**  
排序  
```bash
sort file.txt              # 默认按字典序排序
sort -n file.txt           # 按数值大小排序
sort -r file.txt           # 逆序排序
sort -k2,2n data.txt       # 按第2列数值排序
```

#### **`uniq`**  
去重或统计重复行（需先排序）  
```bash
sort file.txt | uniq       # 去重
sort file.txt | uniq -c    # 统计每行出现次数
uniq -d file.txt           # 仅显示重复行
```

#### **`wc`**  
统计行数、单词数、字符数  
```bash
wc -l file.txt    # 统计行数
wc -w file.txt    # 统计单词数
wc -c file.txt    # 统计字节数
```

#### **`tr`**  
字符替换/删除  
```bash
echo "hello" | tr 'a-z' 'A-Z'   # 转为大写（HELLO）
tr -d '\r' < file.txt           # 删除回车符（\r）
```

---

### **3. 组合使用示例**
#### **提取日志中的错误信息并统计**  
```bash
grep "ERROR" app.log | cut -d' ' -f3 | sort | uniq -c | sort -nr
```
1. 过滤含 "ERROR" 的行  
2. 提取第3列（假设错误类型在第3列）  
3. 排序  
4. 统计每种错误出现次数  
5. 按次数逆序排序

#### **批量重命名文件**  
```bash
ls *.txt | sed 's/\(.*\).txt/mv & \1.md/' | sh
```
1. 列出所有 `.txt` 文件  
2. 生成 `mv old.txt old.md` 命令  
3. 通过管道执行

#### **统计访问量最高的IP**  
```bash
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -10
```
1. 提取第1列（IP地址）  
2. 排序  
3. 统计IP出现次数  
4. 按次数逆序排序  
5. 显示前10条

---

### **4. 其他工具**
- **`head`/`tail`**: 查看文件头部/尾部  
  ```bash
  head -n10 file.txt    # 查看前10行
  tail -f log.txt       # 实时跟踪日志
  ```
- **`paste`**: 合并文件列  
  ```bash
  paste file1.txt file2.txt > combined.txt
  ```
- **`join`**: 按列合并两个文件（类似SQL JOIN）  
- **`xargs`**: 将输入转换为命令行参数  
  ```bash
  find . -name "*.log" | xargs rm   # 删除所有.log文件
  ```

---

### **5. 正则表达式**
- `^`: 行首  
- `$`: 行尾  
- `.`: 任意字符  
- `*`: 0次或多次重复  
- `+`: 1次或多次重复（需用 `-E` 启用扩展正则）  
- `[0-9]`: 数字  
- `(pattern)`: 分组（sed中用 `\1` 引用）  
