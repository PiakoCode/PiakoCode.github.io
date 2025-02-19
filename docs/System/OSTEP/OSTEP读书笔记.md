# OSTEP读书笔记

#操作系统 

进程的三种状态：
- 运行（running）：在运行状态下，进程正在处理器上运行。这意味着它正在执行指令。
- 就绪（ready）：在就绪状态下，进程已准备好运行，但由于某种原因，操作系统选择不在此时运行。
- 阻塞（blocked）：在阻塞状态下，一个进程执行了某种操作，直到发生其他事件时才会准备运行。一个常见的例子是，当进程向磁盘发起 I/O 请求时，它会被阻塞， 因此其他进程可以使用处理器。

![](Picture/Pasted%20image%2020230727195244.png)

MLFQ: 多级反馈队列


虚拟化import part：进程调度、页表、地址转换


![](Picture/Pasted%20image%2020230729172623.png)
Two-level page table structure in [x86](https://en.wikipedia.org/wiki/X86 "X86") architecture (without [PAE](https://en.wikipedia.org/wiki/Physical_Address_Extension "Physical Address Extension") or [PSE](https://en.wikipedia.org/wiki/Page_Size_Extension "Page Size Extension")).