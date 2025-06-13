# epoll

#linux #CPP 


```cpp
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/epoll.h>
#include <fcntl.h>

#define MAX_EVENTS 10

void fatal_error(const char* str) {
    perror(str);
    exit(EXIT_FAILURE);
}

int main() {
    struct epoll_event event, events[MAX_EVENTS];
    int epoll_fd, nfds;
    char buf[256];

    // 创建一个新的epoll实例
    epoll_fd = epoll_create1(0);
    if (epoll_fd == -1) {
        fatal_error("epoll_create1");
    }

    event.events = EPOLLIN; // 设置关注的事件为可读
    event.data.fd = STDIN_FILENO; // 设置要关注的文件描述符为标准输入

    // 将标准输入添加到epoll的关注列表中
    if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, STDIN_FILENO, &event) == -1) {
        fatal_error("epoll_ctl: add");
    }

    // 等待事件产生
    nfds = epoll_wait(epoll_fd, events, MAX_EVENTS, -1);
    if (nfds == -1) {
        fatal_error("epoll_wait");
    }

    //处理所有产生的事件
    for (int n = 0; n < nfds; ++n) {
        if (events[n].data.fd == STDIN_FILENO) {
            memset(buf, 0, sizeof(buf));
            int res = read(STDIN_FILENO, buf, sizeof(buf));
            if (res == -1)
                fatal_error("read");
            printf("Read: %s\n", buf);
        }
    }

    // 关闭epoll
    close(epoll_fd);

    return 0;
}
```

```
$> ./a.out
asdf
Read: adsf
$>  
```



**水平触发和边缘触发**

水平触发（Level-triggered，LT）和边缘触发（Edge-triggered，ET）是IO多路复用技术中用来描述事件触发方式的两个术语，具体说来：

1. **水平触发（Level-triggered）**：这是大多数人理解的模式，只要*条件满足*（比如可读/可写），它就会触发一次。例如我们把一堆文件描述符交给epoll去监控可读事件，如果某个文件描述符变得可读，那么epoll_wait就会返回这个文件描述符，表示它已经可以开始读取数据了。如果我们读取了一部分数据，还有一部分数据留在了内核的接收缓冲区，不再读取剩余的数据，那么下一次再调用epoll_wait，这个文件描述符还会立刻返回，因为仍然满足可读条件（接收缓冲区中仍然有未读数据）。所以，只要有未处理的事件（这里是该文件描述符有未读取的数据），每一次epoll_wait都会返回这个事件。这就是所谓的“水平触发”。
    
2. **边缘触发（Edge-triggered）**：边缘触发模式下，当*状态发生变更*的时候，epoll_wait会返回文件描述符。例如在数据到达的时候触发一个读事件，我们可以尽可能多的读取数据，但是只有再次有新数据到来时才会再次触发。比如我们把一堆文件描述符交给epoll去监控，并要求以边缘触发模式返回。当某个文件描述符变得可读的时候，epoll_wait返回该文件描述符。我们只读取了部分数据，留下了一部分在内核的接收缓冲区，再次调用epoll_wait，这次它将不会返回那个文件描述符了，即使该文件描述符还有未读取的数据。因为从epoll的角度看，它的状态并没有发生变化（它一直是可读的）。只有在有新的数据到来的时候，epoll_wait才会返回该文件描述符。然而，边缘触发虽然效率较高，但是编码难度也就较大。
    

总结下来，水平触发和边缘触发最大的区别是，水平触发关注的是状态，而边缘触发关注的是状态的改变。在实际使用中的区别是，使用水平触发时，如果不完全处理该IO事件（比如读取全部待读取的数据），那么下次epoll_wait依然会返回该事件；而使用边缘触发时，必须保证一次性处理完该IO事件，否则后续的epoll_wait将不再返回该事件。


## io_uring

