# Reactor模式

核心思想: "事件就绪时处理通知"

关键组件

1. **Reactor**: 
   - 负责监听所有的事件源（如文件描述符、网络连接等）。
   - 当某个事件源就绪时，Reactor会通知相应的处理器进行处理。
   - Reactor通常使用I/O多路复用技术（如`select`、`poll`、`epoll`等）来实现高效的事件监听。

2. **Handler**:
   - 每个事件源对应一个处理器（Handler）。
   - 处理器负责处理特定类型的事件（如读、写、异常等）。
   - 当Reactor通知某个事件源就绪时，对应的处理器会被调用来处理该事件。

3. **Demultiplexer**:
   - Demultiplexer是Reactor的核心部分，负责等待多个事件源上的事件。
   - 当某个事件源就绪时，Demultiplexer会返回相应的事件类型和事件源标识符。
   - Reactor根据这些信息找到对应的处理器并调用它。
