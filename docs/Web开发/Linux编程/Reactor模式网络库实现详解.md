# Reactor模式网络库实现详解

author: claude-3.5-sonnet

## 1. 项目概述

  

这是一个基于Reactor模式实现的C++网络库,使用epoll作为事件多路复用机制。该项目主要实现了一个高性能的事件驱动型网络服务器框架。

  

### 1.1 主要特点

  

- 使用epoll进行事件多路复用

- 非阻塞IO

- 基于事件驱动

- 支持TCP连接的管理

- 使用现代C++特性

  

### 1.2 核心组件

  

- EventLoop:事件循环,负责事件分发

- Channel:IO事件分发器

- Acceptor:接受新的TCP连接

- TcpConnection:TCP连接的抽象

- TcpServer:TCP服务器

  

## 2. 核心类详解

  

### 2.0 头文件概览

  

项目的头文件位于include/reactor/目录下,包含了所有类的声明和接口定义。每个头文件都包含了详细的注释,说明了类的功能和用途。

  

#### Acceptor.h

```cpp

// Acceptor类负责接受新的TCP连接

class Acceptor {

public:

using NewConnectionCallback = std::function<void(int sockfd)>;

Acceptor(EventLoop* loop, const char* ip, uint16_t port);

~Acceptor();

void setNewConnectionCallback(const NewConnectionCallback& cb);

void listen();

};

```

  

#### Channel.h

```cpp

// Channel类负责单个文件描述符的事件分发

class Channel {

public:

using EventCallback = std::function<void()>;

Channel(EventLoop* loop, int fd);

void handleEvent();

void enableReading();

void enableWriting();

void disableWriting();

void disableAll();

};

```

  

#### EventLoop.h

```cpp

// EventLoop类是事件循环的核心,负责事件的分发和处理

class EventLoop {

public:

EventLoop();

~EventLoop();

void loop();

void updateChannel(Channel* channel);

void removeChannel(Channel* channel);

void quit();

};

```

  

#### Poller.h

```cpp

// Poller类封装了epoll的操作

class Poller {

public:

Poller();

~Poller();

void updateChannel(Channel* channel);

void removeChannel(Channel* channel);

void poll(std::vector<Channel*>& activeChannels);

};

```

  

#### TcpConnection.h

```cpp

// TcpConnection类负责管理一个TCP连接的生命周期

class TcpConnection : public std::enable_shared_from_this<TcpConnection> {

public:

using TcpConnectionPtr = std::shared_ptr<TcpConnection>;

using MessageCallback = std::function<void(const TcpConnectionPtr&, const std::string&)>;

using ConnectionCallback = std::function<void(const TcpConnectionPtr&)>;

void connectEstablished();

void send(const std::string& message);

void shutdown();

};

```

  

#### TcpServer.h

```cpp

// TcpServer类提供TCP服务器功能

class TcpServer {

public:

TcpServer(EventLoop* loop, const char* ip, uint16_t port);

void start();

void setMessageCallback(const MessageCallback& cb);

void setConnectionCallback(const ConnectionCallback& cb);

};

```

  

### 2.1 EventLoop类

  

EventLoop是整个网络库的核心,它负责:

  

- 创建和管理epoll实例

- 运行事件循环

- 分发IO事件到对应的Channel

  

具体实现:

```cpp

// 构造函数:创建epoll实例

EventLoop::EventLoop()

: running_(false),

epollfd_(::epoll_create1(EPOLL_CLOEXEC)) {

}

  

// 析构函数:关闭epoll文件描述符

EventLoop::~EventLoop() {

::close(epollfd_);

}

  

// 事件循环的主函数

void EventLoop::loop() {

running_ = true;

std::vector<epoll_event> events(16); // 事件数组,初始大小16

while (running_) {

// 等待事件发生

int numEvents = ::epoll_wait(epollfd_, events.data(),

static_cast<int>(events.size()), -1);

if (numEvents > 0) {

// 处理所有活动事件

for (int i = 0; i < numEvents; ++i) {

Channel* channel = static_cast<Channel*>(events[i].data.ptr);

channel->set_revents(events[i].events);

channel->handleEvent();

}

// 如果事件数组满了,扩大一倍

if (static_cast<size_t>(numEvents) == events.size()) {

events.resize(events.size() * 2);

}

}

}

}

  

// 更新Channel的事件状态

void EventLoop::updateChannel(Channel* channel) {

struct epoll_event event;

event.events = channel->events();

event.data.ptr = channel;

if (channels_.find(channel->fd()) == channels_.end()) {

// 新增channel

channels_[channel->fd()] = channel;

::epoll_ctl(epollfd_, EPOLL_CTL_ADD, channel->fd(), &event);

} else {

// 修改已存在的channel

::epoll_ctl(epollfd_, EPOLL_CTL_MOD, channel->fd(), &event);

}

}

  

// 从事件循环中移除Channel

void EventLoop::removeChannel(Channel* channel) {

channels_.erase(channel->fd());

::epoll_ctl(epollfd_, EPOLL_CTL_DEL, channel->fd(), nullptr);

}

```

  

关键点解析:

1. `epoll_create1(EPOLL_CLOEXEC)`:创建epoll实例,CLOEXEC标志确保子进程不会继承

2. `epoll_wait`:等待事件发生,返回活动事件的数量

3. 动态扩容:当事件数组满时,自动扩大容量

4. 事件分发:通过Channel的handleEvent函数处理具体事件

5. Channel管理:通过map维护fd到Channel的映射

  

### 2.2 Channel类

  

Channel是对文件描述符的封装,负责:

  

- 注册感兴趣的IO事件

- 处理IO事件回调

- 管理事件状态

  

具体实现:

```cpp

// 事件类型常量定义

const int Channel::kNoneEvent = 0;

const int Channel::kReadEvent = EPOLLIN | EPOLLPRI;

const int Channel::kWriteEvent = EPOLLOUT;

  

// 构造函数:初始化成员变量

Channel::Channel(EventLoop* loop, int fd)

: loop_(loop),

fd_(fd),

events_(0),

revents_(0) {

}

  

// 处理事件的核心函数

void Channel::handleEvent() {

// 处理错误和挂起事件

if (revents_ & (EPOLLERR | EPOLLHUP)) {

if (errorCallback_) errorCallback_();

}

// 处理读事件

if (revents_ & (EPOLLIN | EPOLLPRI)) {

if (readCallback_) readCallback_();

}

// 处理写事件

if (revents_ & EPOLLOUT) {

if (writeCallback_) writeCallback_();

}

}

  

// 启用读事件监听

void Channel::enableReading() {

events_ |= kReadEvent;

update();

}

  

// 启用写事件监听

void Channel::enableWriting() {

events_ |= kWriteEvent;

update();

}

  

// 禁用写事件监听

void Channel::disableWriting() {

events_ &= ~kWriteEvent;

update();

}

  

// 禁用所有事件监听

void Channel::disableAll() {

events_ = kNoneEvent;

update();

}

  

// 更新Channel在EventLoop中的状态

void Channel::update() {

loop_->updateChannel(this);

}

```

  

关键点解析:

6. **事件类型**:

- kNoneEvent: 无事件

- kReadEvent: 读事件(EPOLLIN)和紧急数据(EPOLLPRI)

- kWriteEvent: 写事件(EPOLLOUT)

  

7. **事件处理**:

- handleEvent根据revents_的值调用相应的回调函数

- 优先处理错误事件

- 分别处理读事件和写事件

  

8. **事件管理**:

- enableReading/enableWriting: 启用事件监听

- disableWriting/disableAll: 禁用事件监听

- update: 通知EventLoop更新事件状态

  

9. **回调机制**:

- 使用std::function存储回调函数

- 事件发生时自动调用对应回调

  

### 2.3 Acceptor类

  

Acceptor负责接受新的TCP连接,主要功能:

  

- 创建监听socket

- 绑定地址和端口

- 接受新连接并回调通知

  

具体实现:

```cpp

// 构造函数:创建并初始化监听socket

Acceptor::Acceptor(EventLoop* loop, const char* ip, uint16_t port)

: loop_(loop),

// 创建非阻塞的监听socket

listenfd_(::socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK | SOCK_CLOEXEC, 0)),

acceptChannel_(new Channel(loop, listenfd_)) {

// 设置服务器地址

struct sockaddr_in addr;

addr.sin_family = AF_INET;

addr.sin_port = htons(port);

inet_pton(AF_INET, ip, &addr.sin_addr);

// 设置地址重用

int opt = 1;

::setsockopt(listenfd_, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

// 绑定地址

if (::bind(listenfd_, (struct sockaddr*)&addr, sizeof(addr)) < 0) {

perror("bind failed");

::close(listenfd_);

exit(EXIT_FAILURE);

}

// 设置接受连接的回调函数

acceptChannel_->setReadCallback([this]() { handleRead(); });

}

  

// 析构函数:关闭监听socket

Acceptor::~Acceptor() {

::close(listenfd_);

}

  

// 开始监听连接

void Acceptor::listen() {

::listen(listenfd_, SOMAXCONN); // SOMAXCONN是系统建议的最大值

acceptChannel_->enableReading(); // 启用读事件以接受新连接

}

  

// 处理新连接到达

void Acceptor::handleRead() {

struct sockaddr_in addr;

socklen_t len = sizeof(addr);

// 接受新连接,并设置为非阻塞模式

int connfd = ::accept4(listenfd_, (struct sockaddr*)&addr, &len,

SOCK_NONBLOCK | SOCK_CLOEXEC);

if (connfd >= 0) {

if (newConnectionCallback_) {

newConnectionCallback_(connfd); // 回调通知新连接

} else {

::close(connfd); // 如果没有设置回调,直接关闭连接

}

}

}

```

  

关键点解析:

10. **socket创建**:

- 使用SOCK_NONBLOCK标志创建非阻塞socket

- SOCK_CLOEXEC确保子进程不会继承socket

  

11. **地址绑定**:

- 使用sockaddr_in结构体设置IP和端口

- 设置SO_REUSEADDR选项允许地址重用

  

12. **事件处理**:

- 创建Channel管理监听socket

- 设置读事件回调处理新连接

  

13. **连接接受**:

- 使用accept4接受新连接

- 新连接也设置为非阻塞模式

- 通过回调函数通知上层处理新连接

  

### 2.4 TcpConnection类

  

TcpConnection表示一个TCP连接,负责:

  

- 数据的收发

- 连接的生命周期管理

- 处理各种IO事件

  

具体实现:

```cpp

// 构造函数:初始化连接,设置Channel的各种回调函数

TcpConnection::TcpConnection(EventLoop* loop, int sockfd)

: loop_(loop),

channel_(new Channel(loop, sockfd)) {

// 设置Channel的回调函数

channel_->setReadCallback([this]() { handleRead(); });

channel_->setWriteCallback([this]() { handleWrite(); });

channel_->setErrorCallback([this]() { handleError(); });

}

  

// 析构函数:关闭socket连接

TcpConnection::~TcpConnection() {

::close(channel_->fd());

}

  

// 连接建立后的初始化

void TcpConnection::connectEstablished() {

channel_->enableReading(); // 启用读事件

if (connectionCallback_) {

connectionCallback_(shared_from_this());

}

}

  

// 发送数据到对端

void TcpConnection::send(const std::string& message) {

if (message.empty()) return;

// 尝试直接发送数据

ssize_t nwrote = ::write(channel_->fd(), message.data(), message.size());

if (nwrote >= 0) {

// 如果没有发送完全部数据,将剩余数据放入发送缓冲区

if (static_cast<size_t>(nwrote) < message.size()) {

outputBuffer_.append(message.data() + nwrote, message.size() - nwrote);

channel_->enableWriting(); // 关注可写事件

}

}

}

  

// 处理可读事件

void TcpConnection::handleRead() {

char buf[65536]; // 64K缓冲区

ssize_t n = ::read(channel_->fd(), buf, sizeof(buf));

if (n > 0) { // 读取到数据

if (messageCallback_) {

messageCallback_(shared_from_this(), std::string(buf, n));

}

} else if (n == 0) { // 对端关闭连接

handleClose();

} else { // 发生错误

handleError();

}

}

  

// 处理可写事件:继续发送outputBuffer_中的数据

void TcpConnection::handleWrite() {

ssize_t n = ::write(channel_->fd(), outputBuffer_.data(), outputBuffer_.size());

if (n > 0) {

outputBuffer_.erase(0, n); // 删除已发送的数据

if (outputBuffer_.empty()) { // 数据发送完毕

channel_->disableWriting(); // 停止关注可写事件

}

}

}

  

// 处理连接关闭

void TcpConnection::handleClose() {

channel_->disableAll(); // 停止所有事件监听

if (closeCallback_) {

closeCallback_(shared_from_this());

}

}

```

  

关键点解析:

14. **生命周期管理**:

- 使用智能指针管理连接对象

- 自动关闭socket资源

- 通过回调通知连接状态变化

  

15. **数据发送**:

- 先尝试直接发送数据

- 未发送完的数据存入缓冲区

- 注册写事件继续发送

  

16. **数据接收**:

- 使用固定大小的缓冲区读取数据

- 通过回调函数传递数据给上层

- 处理连接关闭和错误情况

  

17. **事件处理**:

- 读事件:接收数据并回调

- 写事件:发送缓冲区数据

- 错误事件:通知连接关闭

  

### 2.5 TcpServer类

  

TcpServer是服务器的封装,提供:

  

- 启动服务器

- 管理所有TCP连接

- 处理连接的生命周期

  

具体实现:

```cpp

// 构造函数:初始化服务器

TcpServer::TcpServer(EventLoop* loop, const char* ip, uint16_t port)

: loop_(loop),

acceptor_(new Acceptor(loop, ip, port)) {

// 设置Acceptor的新连接回调

acceptor_->setNewConnectionCallback(

std::bind(&TcpServer::newConnection, this, std::placeholders::_1));

}

  

// 启动服务器

void TcpServer::start() {

acceptor_->listen(); // 开始监听连接

}

  

// 处理新连接

void TcpServer::newConnection(int sockfd) {

// 创建新的TcpConnection对象

auto conn = std::make_shared<TcpConnection>(loop_, sockfd);

connections_[sockfd] = conn; // 保存连接

// 设置连接的回调函数

conn->setConnectionCallback(connectionCallback_);

conn->setMessageCallback(messageCallback_);

conn->setCloseCallback(

std::bind(&TcpServer::removeConnection, this, std::placeholders::_1));

// 连接初始化

conn->connectEstablished();

// 通知新连接建立

if (connectionCallback_) {

connectionCallback_(conn);

}

}

  

// 移除断开的连接

void TcpServer::removeConnection(const TcpConnectionPtr& conn) {

// 从连接表中删除

size_t n = connections_.erase(conn->fd());

// 通知连接断开

if (connectionCallback_) {

connectionCallback_(conn);

}

}

```

  

关键点解析:

18. **连接管理**:

- 使用map存储所有活动连接

- 通过文件描述符索引连接对象

- 智能指针管理连接生命周期

  

19. **回调设置**:

- 为每个新连接设置消息回调

- 设置连接状态变化回调

- 设置连接关闭回调

  

20. **事件处理**:

- Acceptor处理新连接事件

- TcpConnection处理具体连接的读写事件

- 自动清理断开的连接

  

21. **资源管理**:

- 使用智能指针避免内存泄漏

- 连接断开时自动清理资源

- 优雅处理连接的生命周期

  

## 3. Linux网络编程基础

  

### 3.1 同步vs异步

22. **同步(Synchronous)**

- 程序按顺序执行,一个操作完成后才能进行下一个

- 例如:普通的文件读写,程序等待读写完成

- 优点:简单直观

- 缺点:效率低,容易阻塞

  

23. **异步(Asynchronous)**

- 操作立即返回,不等待结果

- 通过回调函数处理操作完成后的结果

- 优点:效率高,不会阻塞

- 缺点:编程复杂度高

  

### 3.2 阻塞vs非阻塞

24. **阻塞(Blocking)**

- 操作未完成时,程序停在那里等待

- 例如:read()函数在没有数据时会等待

- 优点:逻辑简单

- 缺点:无法处理其他任务

  

25. **非阻塞(Non-blocking)**

- 操作立即返回,即使未完成

- 可以同时处理多个任务

- 优点:响应快,效率高

- 缺点:需要轮询或事件通知

  

### 3.3 IO多路复用

26. **概念**

- 同时监听多个文件描述符(socket)

- 有事件发生时才处理

- Linux提供select/poll/epoll机制

  

27. **epoll优势**

- 能同时监听大量连接

- 只返回有事件的文件描述符

- 效率高,性能好

  

### 3.4 并发处理

28. **进程vs线程**

- 进程:独立的执行单元,有独立的内存空间

- 线程:共享进程的内存空间,开销更小

  

29. **事件驱动**

- 用一个线程处理多个连接

- 通过事件循环分发任务

- 避免了线程切换开销

  

### 3.5 网络编程基础

30. **Socket**

- 网络通信的端点

- 可以是TCP或UDP

- 有读写缓冲区

  

31. **TCP连接**

- 面向连接的可靠传输

- 建立连接需要三次握手

- 断开连接需要四次挥手

  

32. **网络字节序**

- 大端序:高字节在前

- 网络传输使用大端序

- 需要进行字节序转换

  

## 4. 示例程序

  

test_server.cpp展示了如何使用该网络库创建一个简单的回显服务器:

  

```cpp

int main() {

reactor::EventLoop loop;

reactor::TcpServer server(&loop, "0.0.0.0", 8888);

  

// 设置连接回调

server.setConnectionCallback([](const reactor::TcpServer::TcpConnectionPtr& conn) {

if (conn->connected()) {

std::cout << "新连接已建立" << std::endl;

} else {

std::cout << "连接已断开" << std::endl;

}

});

  

// 设置消息回调

server.setMessageCallback([](const reactor::TcpServer::TcpConnectionPtr& conn,

const std::string& message) {

std::cout << "收到消息: " << message << std::endl;

conn->send(message); // 回显消息

});

  

server.start();

loop.loop();

return 0;

}

```

  

## 4. 编译和运行

  

项目使用CMake构建系统:

  

33. 创建构建目录:

```bash

mkdir build && cd build

```

  

34. 生成构建文件:

```bash

cmake ..

```

  

35. 编译:

```bash

make

```

  

36. 运行测试服务器:

```bash

./test/test_server

```

  

## 5. 设计模式解析

  

### 5.1 Reactor模式

  

Reactor模式是一种事件驱动的设计模式,主要用于处理并发I/O操作。在这个项目中:

  

37. **事件多路分发器(EventLoop)**

- 使用epoll实现I/O多路复用

- 负责事件的监听和分发

- 维护事件循环

  

38. **事件处理器(Channel)**

- 封装文件描述符

- 注册感兴趣的事件

- 提供事件回调机制

  

39. **具体事件处理器(Acceptor/TcpConnection)**

- Acceptor处理连接事件

- TcpConnection处理读写事件

  

### 5.2 观察者模式

  

项目中大量使用了回调函数,这是观察者模式的一种实现:

  

40. **事件通知**

- Channel类中的readCallback_、writeCallback_等

- TcpServer中的connectionCallback_、messageCallback_

  

41. **事件订阅**

- 通过setXXXCallback方法设置回调

- 事件发生时自动调用对应回调

  

### 5.3 RAII资源管理

  

项目使用了现代C++的RAII特性:

  

42. **智能指针**

- 使用unique_ptr管理Channel等对象

- 使用shared_ptr管理TcpConnection

  

43. **资源自动释放**

- 析构函数中自动关闭文件描述符

- 连接断开时自动清理资源

  

## 6. 总结

  

这个网络库实现了Reactor模式的核心组件,提供了:

  

- 高效的事件处理机制

- 简洁的接口设计

- 完整的TCP服务器功能

- 良好的扩展性

  

通过合理的抽象和模块化设计,使得网络编程变得更加简单和高效。用户只需要关注业务逻辑,而不需要处理底层的网络细节。

  

## 7. 性能优化和最佳实践

  

### 7.1 性能优化

  

44. **非阻塞IO**

- 所有socket操作都是非阻塞的

- 使用epoll进行高效的事件监听

  

45. **缓冲区管理**

- 使用string作为缓冲区,自动扩容

- 支持大数据量的收发

  

46. **事件循环优化**

- 动态调整事件数组大小

- 避免频繁的内存分配

  

### 7.2 使用建议

  

47. **合理设置回调**

```cpp

server.setConnectionCallback([](const TcpConnectionPtr& conn) {

// 处理连接状态变化

});

server.setMessageCallback([](const TcpConnectionPtr& conn, const std::string& msg) {

// 处理消息

});

```

  

48. **错误处理**

- 注册错误回调函数

- 及时处理连接断开事件

  

49. **资源管理**

- 使用智能指针管理对象生命周期

- 避免手动管理内存

  

50. **扩展建议**

- 可以添加定时器功能

- 可以实现线程池处理业务逻辑

- 可以添加日志系统

  

## 8. Linux编程体系总结

  

### 8.1 系统编程基础

51. **文件操作**

- 文件描述符是核心概念

- 统一的"一切皆文件"理念

- 包括普通文件、设备、管道、socket等

  

52. **进程管理**

- 进程创建(fork)和执行(exec)

- 进程间通信(IPC)

- 信号处理机制

  

53. **内存管理**

- 虚拟内存机制

- 内存映射(mmap)

- 共享内存

  

### 8.2 网络编程体系

54. **分层结构**

- 应用层(HTTP、FTP、SSH等)

- 传输层(TCP、UDP)

- 网络层(IP)

- 链路层(以太网等)

  

55. **Socket编程模型**

- 流式套接字(SOCK_STREAM)

- 数据报套接字(SOCK_DGRAM)

- 原始套接字(SOCK_RAW)

  

56. **并发模型**

- 多进程模型

- 多线程模型

- 事件驱动模型(Reactor)

- IO多路复用(select/poll/epoll)

  

### 8.3 开发模式演进

57. **传统阻塞式IO**

- 简单直观

- 一个连接一个线程

- 并发量受限

  

58. **非阻塞IO + IO多路复用**

- 单线程处理多连接

- 基于事件驱动

- 高并发、高性能

  

59. **异步IO(AIO)**

- 操作系统级别的异步

- 无需轮询

- 适合IO密集型应用

  

### 8.4 实践经验总结

60. **设计原则**

- 模块化设计

- 接口抽象

- 资源管理(RAII)

- 错误处理

  

61. **性能优化**

- 使用合适的IO模型

- 避免阻塞操作

- 合理的缓冲区管理

- 注意内存使用

  

62. **调试和监控**

- 系统调用跟踪(strace)

- 网络抓包(tcpdump)

- 性能分析(perf)

- 日志记录

  

### 8.5 发展趋势

63. **新特性应用**

- io_uring(新的异步IO机制)

- QUIC协议

- 零拷贝技术

  

64. **编程范式**

- 协程和异步编程

- 响应式编程

- 函数式编程

  

65. **工程实践**

- 容器化部署

- 微服务架构

- 云原生开发

  

通过这个网络库的学习,你不仅可以掌握Linux网络编程的核心概念,还能了解现代C++的最佳实践。这些知识将帮助你更好地理解和开发高性能的网络应用。