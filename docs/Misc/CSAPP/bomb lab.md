*bomb lab*



disassemble 反汇编

![[Picture/Pasted image 20230710185144.png]]

![[Picture/Pasted image 20230710185155.png]]



![[Picture/capture-2023-02-25-10-38-18.jpg]]


在x86汇编中，以下是常见的条件跳转指令的含义：

1. `je`：代表"等于"。它用于在前一个比较指令的结果为相等时跳转执行指定的代码。

2. `jbe`：代表"以下或等于"。它用于在前一个无符号比较指令的结果为无符号数小于等于时跳转执行指定的代码。

3. `jle`：代表"小于等于"。它用于在前一个有符号比较指令的结果为有符号数小于等于时跳转执行指定的代码。

4. `jne`：代表"不等于"。它用于在前一个比较指令的结果为不相等时跳转执行指定的代码。



phase_1

使用x/s查看0x402400的值

```
Border relations with Canada have never been better.
```

phase_2

- "push %rbp"：将寄存器%rbp的内容压入栈顶。%rbp是基址指针寄存器，通常用于保存函数的基址。
- "push %rbx"：将寄存器%rbx的内容压入栈顶。%rbx是通用寄存器，可以用于存储临时数据或作为指针。
- "sub $0x28,%rsp": 指令将栈指针`%rsp`向低地址方向移动28个字节，为局部变量和其他临时数据分配空间。这里使用负值表示向下扩展栈空间。

综合起来，这段代码的作用是保存调用函数前的寄存器状态，并为局部变量分配一些栈内存空间。在函数执行完毕后，通过相应的指令可以恢复寄存器的值，并释放之前分配的栈空间。

```c
Dump of assembler code for function phase_2:
   0x0000000000400efc <+0>:     push   %rbp
   0x0000000000400efd <+1>:     push   %rbx
   0x0000000000400efe <+2>:     sub    $0x28,%rsp
   0x0000000000400f02 <+6>:     mov    %rsp,%rsi
   0x0000000000400f05 <+9>:     callq  0x40145c <read_six_numbers>
   0x0000000000400f0a <+14>:    cmpl   $0x1,(%rsp)
   0x0000000000400f0e <+18>:    je     0x400f30 <phase_2+52>
   0x0000000000400f10 <+20>:    callq  0x40143a <explode_bomb>
   0x0000000000400f15 <+25>:    jmp    0x400f30 <phase_2+52>
   0x0000000000400f17 <+27>:    mov    -0x4(%rbx),%eax
   0x0000000000400f1a <+30>:    add    %eax,%eax
   0x0000000000400f1c <+32>:    cmp    %eax,(%rbx)
   0x0000000000400f1e <+34>:    je     0x400f25 <phase_2+41>
   0x0000000000400f20 <+36>:    callq  0x40143a <explode_bomb>
   0x0000000000400f25 <+41>:    add    $0x4,%rbx
   0x0000000000400f29 <+45>:    cmp    %rbp,%rbx
   0x0000000000400f2c <+48>:    jne    0x400f17 <phase_2+27>
   0x0000000000400f2e <+50>:    jmp    0x400f3c <phase_2+64>
   0x0000000000400f30 <+52>:    lea    0x4(%rsp),%rbx
   0x0000000000400f35 <+57>:    lea    0x18(%rsp),%rbp
   0x0000000000400f3a <+62>:    jmp    0x400f17 <phase_2+27>
   0x0000000000400f3c <+64>:    add    $0x28,%rsp
   0x0000000000400f40 <+68>:    pop    %rbx
   0x0000000000400f41 <+69>:    pop    %rbp
   0x0000000000400f42 <+70>:    retq   
End of assembler dump.
```

```c
(gdb) disas read_six_numbers 
Dump of assembler code for function read_six_numbers:
   0x000000000040145c <+0>:     sub    $0x18,%rsp
   0x0000000000401460 <+4>:     mov    %rsi,%rdx
   0x0000000000401463 <+7>:     lea    0x4(%rsi),%rcx
   0x0000000000401467 <+11>:    lea    0x14(%rsi),%rax
   0x000000000040146b <+15>:    mov    %rax,0x8(%rsp)
   0x0000000000401470 <+20>:    lea    0x10(%rsi),%rax
   0x0000000000401474 <+24>:    mov    %rax,(%rsp)
   0x0000000000401478 <+28>:    lea    0xc(%rsi),%r9
   0x000000000040147c <+32>:    lea    0x8(%rsi),%r8
   0x0000000000401480 <+36>:    mov    $0x4025c3,%esi
   0x0000000000401485 <+41>:    mov    $0x0,%eax
   0x000000000040148a <+46>:    callq  0x400bf0 <__isoc99_sscanf@plt>
   0x000000000040148f <+51>:    cmp    $0x5,%eax
   0x0000000000401492 <+54>:    jg     0x401499 <read_six_numbers+61>
   0x0000000000401494 <+56>:    callq  0x40143a <explode_bomb>
   0x0000000000401499 <+61>:    add    $0x18,%rsp
   0x000000000040149d <+65>:    retq   
End of assembler dump.
```

在反汇编中添加断点：
```c
b *func+14
```
func 为函数名
+14为汇编指令偏移量


查看寄存器rsp位置后n个字节的数据
```c
x /nxb $rsp
```

```c
   0x0000000000400f17 <+27>:    mov    -0x4(%rbx),%eax // eax = rbx[i-1]
   0x0000000000400f1a <+30>:    add    %eax,%eax // eax += eax
=> 0x0000000000400f1c <+32>:    cmp    %eax,(%rbx) // eax == rbx[i]
   0x0000000000400f1e <+34>:    je     0x400f25 <phase_2+41> // 循环
   0x0000000000400f20 <+36>:    callq  0x40143a <explode_bomb> // Bomb!!!
```

根据这一段：输入的后一个数字需要是前一个数字的两倍。共6个数字。


answer
```
1 2 4 8 16 32
```

phase_3

输入两个数字：第一个数为小于等于7的数，第二个数根据第一个数决定

```c
   0x0000000000400f43 <+0>:     sub    $0x18,%rsp
   0x0000000000400f47 <+4>:     lea    0xc(%rsp),%rcx
   0x0000000000400f4c <+9>:     lea    0x8(%rsp),%rdx
   0x0000000000400f51 <+14>:    mov    $0x4025cf,%esi
   0x0000000000400f56 <+19>:    mov    $0x0,%eax
   0x0000000000400f5b <+24>:    callq  0x400bf0 <__isoc99_sscanf@plt>
   0x0000000000400f60 <+29>:    cmp    $0x1,%eax
   0x0000000000400f63 <+32>:    jg     0x400f6a <phase_3+39>
   0x0000000000400f65 <+34>:    callq  0x40143a <explode_bomb>
   x <= 7
   0x0000000000400f6a <+39>:    cmpl   $0x7,0x8(%rsp)
   0x0000000000400f6f <+44>:    ja     0x400fad <phase_3+106>
   0x0000000000400f71 <+46>:    mov    0x8(%rsp),%eax
   switch
   0x0000000000400f75 <+50>:    jmpq   *0x402470(,%rax,8)
   x = 0
   0x0000000000400f7c <+57>:    mov    $0xcf,%eax
   0x0000000000400f81 <+62>:    jmp    0x400fbe <phase_3+123>
   x = 2
   0x0000000000400f83 <+64>:    mov    $0x2c3,%eax // 0x2c3 == 707
   0x0000000000400f88 <+69>:    jmp    0x400fbe <phase_3+123>
   x = 3
   0x0000000000400f8a <+71>:    mov    $0x100,%eax
   0x0000000000400f8f <+76>:    jmp    0x400fbe <phase_3+123>
   x = 4
   0x0000000000400f91 <+78>:    mov    $0x185,%eax
   0x0000000000400f96 <+83>:    jmp    0x400fbe <phase_3+123>
   x = 5
   0x0000000000400f98 <+85>:    mov    $0xce,%eax
   0x0000000000400f9d <+90>:    jmp    0x400fbe <phase_3+123>
   x = 6
   0x0000000000400f9f <+92>:    mov    $0x2aa,%eax
   0x0000000000400fa4 <+97>:    jmp    0x400fbe <phase_3+123>
   x = 7
   0x0000000000400fa6 <+99>:    mov    $0x147,%eax
   0x0000000000400fab <+104>:   jmp    0x400fbe <phase_3+123>
   0x0000000000400fad <+106>:   callq  0x40143a <explode_bomb>
   0x0000000000400fb2 <+111>:   mov    $0x0,%eax
   0x0000000000400fb7 <+116>:   jmp    0x400fbe <phase_3+123>
   x = 1
   0x0000000000400fb9 <+118>:   mov    $0x137,%eax // 0x137 == 311
   0x0000000000400fbe <+123>:   cmp    0xc(%rsp),%eax
=> 0x0000000000400fc2 <+127>:   je     0x400fc9 <phase_3+134>
   0x0000000000400fc4 <+129>:   callq  0x40143a <explode_bomb>
   0x0000000000400fc9 <+134>:   add    $0x18,%rsp
   0x0000000000400fcd <+138>:   retq   
```



answser
```
1 311
```


phase_4

test %eax, %eax" 是一个逻辑运算指令。它用于将寄存器 %eax 的值与自身进行按位逻辑与运算，即将 %eax 的值与自身的每个对应位进行逻辑与操作。

如果 %eax 的值为零，则标志位（flags）寄存器中的零标志位（ZF）会被设置为1，表示相等。

"test %eax, %eax" 指令的作用是检查 %eax 寄存器的值是否为零，并根据结果设置相应的标志位。



```c
   0x0000000000401051 <+69>:    cmpl   $0x0,0xc(%rsp)
   0x0000000000401056 <+74>:    je     0x40105d <phase_4+81>
   0x0000000000401058 <+76>:    callq  0x40143a <explode_bomb>
   0x000000000040105d <+81>:    add    $0x18,%rsp
   0x0000000000401061 <+85>:    retq   
```
可知第二个数为0


func4 是一个递归函数:
```c
Dump of assembler code for function func4:
   0x0000000000400fce <+0>:     sub    $0x8,%rsp
   0x0000000000400fd2 <+4>:     mov    %edx,%eax
   0x0000000000400fd4 <+6>:     sub    %esi,%eax
   0x0000000000400fd6 <+8>:     mov    %eax,%ecx
   0x0000000000400fd8 <+10>:    shr    $0x1f,%ecx
   0x0000000000400fdb <+13>:    add    %ecx,%eax
=> 0x0000000000400fdd <+15>:    sar    %eax
   0x0000000000400fdf <+17>:    lea    (%rax,%rsi,1),%ecx
   0x0000000000400fe2 <+20>:    cmp    %edi,%ecx
   0x0000000000400fe4 <+22>:    jle    0x400ff2 <func4+36>
   0x0000000000400fe6 <+24>:    lea    -0x1(%rcx),%edx
   0x0000000000400fe9 <+27>:    callq  0x400fce <func4>
   0x0000000000400fee <+32>:    add    %eax,%eax
   0x0000000000400ff0 <+34>:    jmp    0x401007 <func4+57>
   0x0000000000400ff2 <+36>:    mov    $0x0,%eax
   0x0000000000400ff7 <+41>:    cmp    %edi,%ecx
   0x0000000000400ff9 <+43>:    jge    0x401007 <func4+57>
   0x0000000000400ffb <+45>:    lea    0x1(%rcx),%esi
   0x0000000000400ffe <+48>:    callq  0x400fce <func4>
   0x0000000000401003 <+53>:    lea    0x1(%rax,%rax,1),%eax
   0x0000000000401007 <+57>:    add    $0x8,%rsp
   0x000000000040100b <+61>:    retq   
```

可将func4用c语言表示
```c
// edx = 0x4. esi = 0 ,edi = num1
int func4(int edx, int esi, int edi) {
  int eax = edx - esi;
  eax = (eax + (eax >> 31)) >> 1; // 5-8行 eax == 7
  int ecx = eax + esi;            // 9行
  if (edi < ecx)
    return 2 * func4(edi, esi, edx - 1); // 14行
  else if (edi > ecx)
    return 2 * func4(edi, esi + 1, edx) + 1; // 21行
  else
    return 0;
}
```
可知edi = num1 = ecx,
ecx = eax + esi
因此num1 = 7

answer
```
7 0
```


phase 5

```c
   0x000000000040107a <+24>:    callq  0x40131b <string_length>
   0x000000000040107f <+29>:    cmp    $0x6,%eax
   0x0000000000401082 <+32>:    je     0x4010d2 <phase_5+112>
   0x0000000000401084 <+34>:    callq  0x40143a <explode_bomb>
```
根据这段可知要求输入长度为6的字符串

```c
movzbl (%rbx,%rax,1),%ecx
```

- `movzbl`：这是指令的助记符，表示"move zero-extend byte to long"（将字节零扩展为长字）。它告诉处理器要执行一个将字节零扩展为双字（32位）的操作。
- `(%rbx,%rax,1)`：这是内存操作数的表示方式。在这里，`%rbx`和`%rax`是寄存器，`1`是一个比例因子（scale factor）。该表达式的含义是将`%rbx`和`%rax`的内容相加，并将其作为内存地址来访问。这个指令将从计算得到的内存地址开始读取一个字节的数据。
- `%ecx`：这是目标寄存器，用于存储从内存读取并零扩展的数据。数据将被存储在ECX寄存器中。

因此，这条指令的作用是将从`(%rbx,%rax,1)`地址处读取的字节数据进行零扩展，并将结果存储到ECX寄存器中。



```c
   0x000000000040108b <+41>:    movzbl (%rbx,%rax,1),%ecx
   0x000000000040108f <+45>:    mov    %cl,(%rsp)
   0x0000000000401092 <+48>:    mov    (%rsp),%rdx
   0x0000000000401096 <+52>:    and    $0xf,%edx
   0x0000000000401099 <+55>:    movzbl 0x4024b0(%rdx),%edx
   0x00000000004010a0 <+62>:    mov    %dl,0x10(%rsp,%rax,1)
   0x00000000004010a4 <+66>:    add    $0x1,%rax
   0x00000000004010a8 <+70>:    cmp    $0x6,%rax
   0x00000000004010ac <+74>:    jne    0x40108b <phase_5+41>
```
在x86架构的汇编语言中，`%cl` 是`%ecx` 寄存器的低8位部分。

可分析得到
```c
char *str = "maduiersnfotvbyl";
char *rdi = "123456";
char *rbx = rdi;
  for (int rax = 0; rax < 6; rax++) {
    char ecx = rbx[rax];
    int edx = ecx & 0xf;
    edx = str[edx];
    rsp[16+rax] = edx;
  }
```


```c
   0x00000000004010b3 <+81>:    mov    $0x40245e,%esi
=> 0x00000000004010b8 <+86>:    lea    0x10(%rsp),%rdi
```
与字符串`flyers` 进行比较

可以看到我们需要的字符`flyers`的索引分别为`9 15 14 5 6 7`。这个索引就是我们输入的字符的低4位，那我们只要找到低4位分别是以上数值的字符就可以了。

所以阶段5的（一个）答案为：

```
ionefg
```


phase 6

```c
   0x00000000004010f4 <+0>:     push   %r14
   0x00000000004010f6 <+2>:     push   %r13
   0x00000000004010f8 <+4>:     push   %r12
   0x00000000004010fa <+6>:     push   %rbp
   0x00000000004010fb <+7>:     push   %rbx
   0x00000000004010fc <+8>:     sub    $0x50,%rsp
   0x0000000000401100 <+12>:    mov    %rsp,%r13
   0x0000000000401103 <+15>:    mov    %rsp,%rsi
   0x0000000000401106 <+18>:    callq  0x40145c <read_six_numbers>
```
输入6个数字

```c
(gdb) x /s $rsi
0x603910 <input_strings+400>:   "1 2 3 4 5 6"
```

r13 = rsp
***
r14 = rsp
r12d = 0

```c
   0x0000000000401117 <+35>:    mov    0x0(%r13),%eax // eax == num
   0x000000000040111b <+39>:    sub    $0x1,%eax
   0x000000000040111e <+42>:    cmp    $0x5,%eax
   0x0000000000401121 <+45>:    jbe    0x401128 <phase_6+52>
   0x0000000000401123 <+47>:    callq  0x40143a <explode_bomb>
   0x0000000000401128 <+52>:    add    $0x1,%r12d
```
可知num - 1 <= 5 
即 num <= 6

```c
   0x0000000000401128 <+52>:    add    $0x1,%r12d 
   0x000000000040112c <+56>:    cmp    $0x6,%r12d // $r12d == 1
   0x0000000000401130 <+60>:    je     0x401153 <phase_6+95>
   0x0000000000401132 <+62>:    mov    %r12d,%ebx // $ebx = $r12d = 1
   0x0000000000401135 <+65>:    movslq %ebx,%rax
   0x0000000000401138 <+68>:    mov    (%rsp,%rax,4),%eax//rsp+4 -> $eax==num2
   0x000000000040113b <+71>:    cmp    %eax,0x0(%rbp) // cmp num2, num1
   0x000000000040113e <+74>:    jne    0x401145 <phase_6+81>
   0x0000000000401140 <+76>:    callq  0x40143a <explode_bomb>
```

观察可知这段汇编构成了一段循环
```c
   0x0000000000401132 <+62>:    mov    %r12d,%ebx
   0x0000000000401135 <+65>:    movslq %ebx,%rax
   0x0000000000401138 <+68>:    mov    (%rsp,%rax,4),%eax
   0x000000000040113b <+71>:    cmp    %eax,0x0(%rbp)
   0x000000000040113e <+74>:    jne    0x401145 <phase_6+81>
   0x0000000000401140 <+76>:    callq  0x40143a <explode_bomb>
   0x0000000000401145 <+81>:    add    $0x1,%ebx
   0x0000000000401148 <+84>:    cmp    $0x5,%ebx
   0x000000000040114b <+87>:    jle    0x401135 <phase_6+65>
```

```c
r12d
rax = r12d
for (ebx = r12d,ebx<=5;ebx++) {
	rax = ebx;
	eax = rsp[rax];
	if(eax == rsp[0])
		explode_bomb();
}
```
所以后几个数字不能和第r12d个数字相等

```c
   0x000000000040114d <+89>:    add    $0x4,%r13 //num1 --> num2 --> num3 ...
   0x0000000000401151 <+93>:    jmp    0x401114 <phase_6+32>
```

循环6次 r12d 0~5
```c
   0x0000000000401128 <+52>:    add    $0x1,%r12d
   0x000000000040112c <+56>:    cmp    $0x6,%r12d
   0x0000000000401130 <+60>:    je     0x401153 <phase_6+95>
```

所以要求输入的各个数字各不相等
最后使得 num1 = r13 = num6


这里又是一段循环
```c
   0x0000000000401153 <+95>:    lea    0x18(%rsp),%rsi //rsi == $(rsp+24) 
   0x0000000000401158 <+100>:   mov    %r14,%rax // i = 0
   0x000000000040115b <+103>:   mov    $0x7,%ecx
   0x0000000000401160 <+108>:   mov    %ecx,%edx
   0x0000000000401162 <+110>:   sub    (%rax),%edx //edx -= num[i] ==> 7-num[i]
   0x0000000000401164 <+112>:   mov    %edx,(%rax) // num[i] = edx
   0x0000000000401166 <+114>:   add    $0x4,%rax // i++
   0x000000000040116a <+118>:   cmp    %rsi,%rax // i < 7
   0x000000000040116d <+121>:   jne    0x401160 <phase_6+108>
   0x000000000040116f <+123>:   mov    $0x0,%esi
   0x0000000000401174 <+128>:   jmp    0x401197 <phase_6+163>
```

作用：num\[i\] = 7-num\[i\]


```c
   0x0000000000401197 <+163>:   mov    (%rsp,%rsi,1),%ecx // $rsi == 0
   0x000000000040119a <+166>:   cmp    $0x1,%ecx
   0x000000000040119d <+169>:   jle    0x401183 <phase_6+143>
```


```c
   0x0000000000401195 <+161>:   je     0x4011ab <phase_6+183>
   0x0000000000401197 <+163>:   mov    (%rsp,%rsi,1),%ecx
   0x000000000040119a <+166>:   cmp    $0x1,%ecx
   0x000000000040119d <+169>:   jle    0x401183 <phase_6+143>
   0x000000000040119f <+171>:   mov    $0x1,%eax
   0x00000000004011a4 <+176>:   mov    $0x6032d0,%edx
   0x00000000004011a9 <+181>:   jmp    0x401176 <phase_6+130>
```
不知道什么用


```c
   0x00000000004011ab <+183>:   mov    0x20(%rsp),%rbx 
   0x00000000004011b0 <+188>:   lea    0x28(%rsp),%rax
   0x00000000004011b5 <+193>:   lea    0x50(%rsp),%rsi
   0x00000000004011ba <+198>:   mov    %rbx,%rcx
   0x00000000004011bd <+201>:   mov    (%rax),%rdx
   0x00000000004011c0 <+204>:   mov    %rdx,0x8(%rcx)
   0x00000000004011c4 <+208>:   add    $0x8,%rax
   0x00000000004011c8 <+212>:   cmp    %rsi,%rax
   0x00000000004011cb <+215>:   je     0x4011d2 <phase_6+222>
```

原来是链表....

answer:
```
6 2 1 5 4 3
```