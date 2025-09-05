# Make使用

一个简单的Makefile例子：

```makefile
CC=gcc
CFLAGS=-Wall

all: program

program: main.o func1.o func2.o
	$(CC) $(CFLAGS) -o program main.o func1.o func2.o

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

func1.o: func1.c
	$(CC) $(CFLAGS) -c func1.c

func2.o: func2.c
	$(CC) $(CFLAGS) -c func2.c

clean:
	rm -f *.o program
```

这个Makefile指定了一个叫做`program`的可执行文件的构建规则。它由三个源文件`main.c`、`func1.c`和`func2.c`组成。

`CC`和`CFLAGS`是Makefile的变量，分别指定编译器和编译选项。`all`是一个伪目标，用于指定默认的构建目标。

`program`目标依赖于`main.o`、`func1.o`和`func2.o`三个目标。`make`将检查每个目标是否需要重新构建，如果需要，它会运行指定的命令来生成目标文件。最终，`program`目标将通过链接这三个目标文件来生成可执行文件。

`clean`是一个伪目标，用于删除所有生成的目标文件和可执行文件。