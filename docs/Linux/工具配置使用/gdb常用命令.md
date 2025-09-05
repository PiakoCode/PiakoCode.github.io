# gdb常用命令


1. **运行程序**：
   - `run`: 启动程序执行，可以带参数，如`run arg1 arg2`。
   - `start`: 启动程序并在main函数处停下来。

2. **断点**：
   - `break` (`b`): 设置断点，可以在某行号上设置断点，如`b 10`，也可以在函数名上设置断点，如`b main`。
   - `delete`: 删除指定断点，如`delete 1`。
   - `disable`: 禁用指定断点，如`disable 1`。
   - `enable`: 启用指定断点，如`enable 1`。
   - `clear`: 清除指定行号上的断点，如`clear 10`。

3. **查看和操作代码执行**：
   - `list` (`l`): 显示当前执行点附近的代码，如`list`或`list 1,10`。
   - `step` (`s`): 逐过程单步执行，进入函数。
   - `next` (`n`): 单步执行，跳过函数。
   - `continue` (`c`): 继续执行直到遇到下一个断点或程序结束。
   - `finish`: 运行直到当前函数返回。

4. **查看和修改变量**：
   - `print` (`p`): 打印变量的值，如`print x`。
   - `display`: 持续打印某个变量的值。
   - `set`: 修改变量的值，如`set x = 10`。

5. **查看栈信息**：
   - `backtrace` (`bt`): 显示当前的调用栈。
   - `frame` (`f`): 切换当前帧，如`frame 2`。

6. **查看内存**：
   - `x`: 查看内存中的内容，如`x/nfu address`，其中n是显示数量，f是显示格式（如x表示十六进制），u是单位大小（如b表示字节）。

7. **查看寄存器**：
   - `info registers` (`i r`): 显示当前的寄存器值。

8. **设置断点条件**：
   - `break if`: 在设置断点时指定条件，如`break 10 if x > 5`。

9. **设置观察点**：
   - `watch`: 监视某个变量，当它的值发生改变时中断程序的执行。

10. **附加调试到正在运行的进程**：
    - `attach`: 附加到正在运行的进程进行调试，如`attach PID`。

11. **分析崩溃信息**：
    - `core`: 分析core dump文件，如`gdb executable core`。

12. **退出GDB**：
    - `quit` (`q`): 退出GDB。






1. `disas`：简写为`d`，用于显示当前执行位置附近的汇编代码。
2. `stepi`：简写为`s`，用于单步执行一条汇编指令。
3. `nexti`：简写为`n`，用于执行下一条汇编指令，但是会跳过函数调用。
4. `finish`：简写为`f`，用于执行完当前函数并停止在调用它的地方。
5. `break *address`：简写为`b *address`，用于在指定地址设置断点。
6. `info registers`：简写为`i r`，用于显示当前所有寄存器的值。
7. `x/nfu address`：简写为`x/nfu addr`，用于显示内存中从指定地址开始的n个单位的内容。
8. `set $register=value`：简写为`set $reg=val`，用于设置某个寄存器的值。
9. `display $register`：简写为`disp $reg`，用于在每次停下来时显示某个寄存器的值。
10. `layout asm`：简写为`layout a`，用于显示汇编代码和寄存器窗口。



x/10i表示以汇编指令的格式打印内存中的内容。其中，x表示以十六进制的格式显示，10表示打印10条指令，i表示以汇编指令的格式显示。

例如，当你使用命令x/10i $pc时，它会打印出当前指令指针所指向的位置的十六进制内容，并将其解析为对应的汇编指令。



gdb常用指令

```bash
b # 打断点 (e.g.     b main | b *0x30)
c # continue

layout split # view src-code & asm-code

ni # 单步执行汇编(不进函数)
si # 单步执行汇编(有函数则进入函数)
n # 单步执行源码
s # 单步执行源码

p # print
p $a0 # 打印a0寄存器的值
p/x 1536 # 以16进制的格式打印1536
i r a0 # info registers a0
x/i 0x630 # 查看0x630地址处的指令
x/g 0x80000000 # 查看0x80000000地址处的值（g表示值的长度有64位）
```


推荐安装`gdb-dashboard`

[GitHub - cyrus-and/gdb-dashboard: Modular visual interface for GDB in Python](https://github.com/cyrus-and/gdb-dashboard)