# epoll

## **一、为什么需要epoll？**
在传统的高并发服务器中，使用`select`或`poll`存在明显缺陷：
1. **效率低**：每次调用需遍历所有监听的fd（文件描述符），时间复杂度O(n)。
2. **连接数限制**：`select`默认支持1024个fd，`poll`无限制但性能随fd数量增长下降。
3. **重复拷贝**：每次调用需将fd集合从用户态复制到内核态。

**epoll的设计目标**：  
- 解决`select/poll`的性能问题，支持数十万并发连接。
- 采用“事件驱动”模式，仅关注活跃的fd。

---

## **二、epoll的核心概念**
### **1. 三个关键函数**
epoll的操作围绕三个系统调用展开：

| 函数            | 作用                                                                 |
|-----------------|----------------------------------------------------------------------|
| `epoll_create`  | 创建一个epoll实例，返回一个文件描述符（epoll句柄）。                |
| `epoll_ctl`     | 向epoll实例中注册、修改或删除需要监听的fd及其事件类型。             |
| `epoll_wait`    | 等待事件发生，返回就绪的事件列表。                                  |

### **2. 事件类型**
每个fd可监听多种事件类型，常用事件：

| 事件类型       | 描述                                                         |
|----------------|-------------------------------------------------------------|
| `EPOLLIN`      | 数据可读（如客户端发送了数据）                               |
| `EPOLLOUT`     | 数据可写（如发送缓冲区未满）                                 |
| `EPOLLERR`     | fd发生错误                                                   |
| `EPOLLHUP`     | 对端关闭连接（如客户端断开）                                 |
| `EPOLLET`      | 设置为边沿触发（Edge-Triggered）模式（默认是水平触发LT模式） |

---

## **三、epoll的工作流程**
### **1. 创建epoll实例**
```c
int epoll_fd = epoll_create1(0);  // 参数0表示使用默认行为
```
- 成功返回一个epoll文件描述符，失败返回-1。
- `epoll_create1`是更现代的版本，替代了老旧的`epoll_create`。

### **2. 注册监听事件**
使用`epoll_ctl`向epoll实例注册fd：
```c
struct epoll_event event;
event.events = EPOLLIN | EPOLLET;  // 监听可读事件 + 边沿触发模式
event.data.fd = sock_fd;           // 关联的fd（可携带额外数据）

epoll_ctl(epoll_fd, EPOLL_CTL_ADD, sock_fd, &event);
```
- `EPOLL_CTL_ADD`：添加一个fd到epoll监听列表。
- `EPOLL_CTL_MOD`：修改已注册的fd的事件类型。
- `EPOLL_CTL_DEL`：从epoll监听列表中删除一个fd。

### **3. 等待事件就绪**
```c
#define MAX_EVENTS 64
struct epoll_event events[MAX_EVENTS];

int n = epoll_wait(epoll_fd, events, MAX_EVENTS, -1);  // -1表示无限等待
for (int i = 0; i < n; i++) {
    if (events[i].events & EPOLLIN) {
        int fd = events[i].data.fd;
        // 处理可读事件（如接收数据）
    }
}
```
- `epoll_wait`返回就绪的事件数量，并将事件填充到`events`数组中。
- 参数`timeout`：-1表示阻塞等待，0表示立即返回，>0表示超时时间（毫秒）。

---

## **四、epoll的两种模式**
### **1. 水平触发（LT，Level-Triggered）**
- **默认模式**：只要fd处于就绪状态（如缓冲区有数据未读完），`epoll_wait`会持续通知。
- **特点**：  
  - 编程简单，适合新手。
  - 可能重复触发事件（需确保处理完所有数据）。

### **2. 边沿触发（ET，Edge-Triggered）**
- **需显式设置**：通过`EPOLLET`标志启用。
- **触发条件**：仅在fd状态变化时通知一次（如从无数据到有数据）。
- **特点**：  
  - 性能更高，减少事件触发次数。
  - **必须一次性处理完所有数据**，否则会丢失后续事件。
  - 需将fd设置为非阻塞模式，并循环读取直到`EAGAIN`错误。

#### **ET模式关键代码**
```c
// 设置非阻塞模式
fcntl(fd, F_SETFL, fcntl(fd, F_GETFL) | O_NONBLOCK);

// 注册ET模式
struct epoll_event event;
event.events = EPOLLIN | EPOLLET;
epoll_ctl(epoll_fd, EPOLL_CTL_ADD, fd, &event);

// 处理数据时必须循环读取
while (true) {
    ssize_t bytes = read(fd, buf, sizeof(buf));
    if (bytes == -1) {
        if (errno == EAGAIN || errno == EWOULDBLOCK) break;  // 数据已读完
        else handle_error();
    } else if (bytes == 0) {
        close(fd);  // 对端关闭连接
        break;
    }
    // 处理数据...
}
```

---

## **五、epoll的高效原理**
### **1. 内核数据结构**
- **红黑树**：存储所有需要监听的fd，快速查找、插入、删除（时间复杂度O(log n)）。
- **就绪链表**：当某个fd就绪时，内核将其添加到就绪链表，无需遍历所有fd。

### **2. 工作流程**
1. **注册fd**：通过`epoll_ctl`将fd添加到红黑树，并注册回调函数。
2. **事件触发**：当fd就绪时，内核调用回调函数将其加入就绪链表。
3. **返回就绪事件**：`epoll_wait`只需检查就绪链表是否有数据，无需遍历所有fd。

---

## **六、完整代码示例**
### **基于epoll的简易TCP服务器**
```c
#include <sys/epoll.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>

#define MAX_EVENTS 64
#define PORT 8080

int main() {
    // 1. 创建监听socket
    int listen_fd = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in addr = {
        .sin_family = AF_INET,
        .sin_port = htons(PORT),
        .sin_addr.s_addr = INADDR_ANY
    };
    bind(listen_fd, (struct sockaddr*)&addr, sizeof(addr));
    listen(listen_fd, SOMAXCONN);

    // 2. 创建epoll实例
    int epoll_fd = epoll_create1(0);
    struct epoll_event event;
    event.events = EPOLLIN;
    event.data.fd = listen_fd;
    epoll_ctl(epoll_fd, EPOLL_CTL_ADD, listen_fd, &event);

    // 3. 事件循环
    struct epoll_event events[MAX_EVENTS];
    while (1) {
        int n = epoll_wait(epoll_fd, events, MAX_EVENTS, -1);
        for (int i = 0; i < n; i++) {
            if (events[i].data.fd == listen_fd) {
                // 处理新连接
                int conn_fd = accept(listen_fd, NULL, NULL);
                fcntl(conn_fd, F_SETFL, O_NONBLOCK);  // 非阻塞模式
                event.events = EPOLLIN | EPOLLET;     // ET模式
                event.data.fd = conn_fd;
                epoll_ctl(epoll_fd, EPOLL_CTL_ADD, conn_fd, &event);
            } else {
                // 处理数据
                char buf[1024];
                while (1) {
                    ssize_t bytes = read(events[i].data.fd, buf, sizeof(buf));
                    if (bytes > 0) {
                        // 处理业务逻辑（如回显数据）
                        write(events[i].data.fd, buf, bytes);
                    } else if (bytes == 0 || (bytes == -1 && errno != EAGAIN)) {
                        close(events[i].data.fd);  // 关闭连接
                        break;
                    } else {
                        break;  // EAGAIN，数据已读完
                    }
                }
            }
        }
    }
    return 0;
}
```


最佳实践

1. **ET模式 + 非阻塞I/O**：结合使用以提高性能。
2. **避免在epoll线程中处理耗时操作**：将业务逻辑交给线程池。
3. **合理设置epoll_wait的超时时间**：平衡响应速度和CPU占用。
4. **监控epoll实例的句柄数量**：避免超过`/proc/sys/fs/epoll/max_user_watches`的限制。








完整示例

以下是一个使用 `epoll` 的完整示例，展示了如何实现一个简单的 TCP 服务器：

```c
#include <sys/epoll.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_EVENTS 10

int main() {
    int listen_fd, conn_fd, epoll_fd;
    struct sockaddr_in server_addr;
    struct epoll_event ev, events[MAX_EVENTS];

    // 创建监听套接字
    listen_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (listen_fd == -1) {
        perror("socket");
        exit(EXIT_FAILURE);
    }

    // 绑定地址
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    server_addr.sin_port = htons(8080);
    if (bind(listen_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1) {
        perror("bind");
        close(listen_fd);
        exit(EXIT_FAILURE);
    }

    // 监听
    if (listen(listen_fd, 10) == -1) {
        perror("listen");
        close(listen_fd);
        exit(EXIT_FAILURE);
    }

    // 创建 epoll 实例
    epoll_fd = epoll_create1(0);
    if (epoll_fd == -1) {
        perror("epoll_create1");
        close(listen_fd);
        exit(EXIT_FAILURE);
    }

    // 注册监听套接字
    ev.events = EPOLLIN;
    ev.data.fd = listen_fd;
    if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, listen_fd, &ev) == -1) {
        perror("epoll_ctl");
        close(listen_fd);
        close(epoll_fd);
        exit(EXIT_FAILURE);
    }

    // 事件循环
    while (1) {
        int n = epoll_wait(epoll_fd, events, MAX_EVENTS, -1);
        if (n == -1) {
            perror("epoll_wait");
            break;
        }

        for (int i = 0; i < n; i++) {
            if (events[i].data.fd == listen_fd) {
                // 接受新连接
                conn_fd = accept(listen_fd, NULL, NULL);
                if (conn_fd == -1) {
                    perror("accept");
                    continue;
                }

                // 注册新连接
                ev.events = EPOLLIN | EPOLLET;
                ev.data.fd = conn_fd;
                if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, conn_fd, &ev) == -1) {
                    perror("epoll_ctl");
                    close(conn_fd);
                }
            } else {
                // 处理可读事件
                char buffer[1024];
                ssize_t count = read(events[i].data.fd, buffer, sizeof(buffer));
                if (count == -1) {
                    perror("read");
                } else if (count == 0) {
                    // 对端关闭连接
                    close(events[i].data.fd);
                } else {
                    // 处理数据
                    printf("Received: %s\n", buffer);
                }
            }
        }
    }

    close(listen_fd);
    close(epoll_fd);
    return 0;
}
```
