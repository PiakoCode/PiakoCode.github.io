# Redis使用

#redis

```shell
redis-server  // 启动redis服务器
redis-cli     // 启动redis命令行工具
```

## 基本操作

清除所有值

```
FLUSHALL
```

设置key

```sql
SET key value
```

获取key

```sql
GET key
```

查看key是否存在

```sql
EXISTS key
```

查看所有的key

```sql
KEYS 模式参数
```

查看以`llo`结尾的键

```sql
KEYS *llo
```

查看名为`name`的键

```sql
KEYS name
```

删除key

```sql
DEL key
```

删除所有键

```sql
FLASHALL
```

增加key 1

```sql
INCR key
```

减少key 1

```sql
DECR key
```

增加key 特定num

```sql
INCRBY key number
```

减少key 特定num

```sql
DECRBY key number
```

> [!info] 
> Redis中单个操作都是原子性的，多个客户端操作时，不会发生并发冲突。
> 
> x ==> 10
> 
> A: INCR x
> 
> B: INCR x
> 
> x ==> 12


设置key的寿命为xx秒

```sql
EXPIRE key number
```

查看key的寿命

```sql
TTL key
```
当返回值为-1时，key没有寿命限制

当返回值为-2时，key不存在或已经消失

>[!note]
>当重新SET key的值后，其生命周期将被重置(无限或自定义)

设置key的值和生命周期
```sql
SET key value EX number
```

取消生命周期限制
```sql
PERSIST key
```

## 数据类型

### 字符串 Strings

Redis Strings 能够存储序列的bytes，包括文本、序列化的对象、二进制数组。（显然可以存储图像）

值的大小不能超过512MB


设置和读取多个key
```
> mset a 10 b 20 c 30
OK
> mget a b c
1) "10"
2) "20"
3) "30"
```






### 列表 List

#### 基本指令

- [`LPUSH`](https://redis.io/commands/lpush) adds a new element to the head of a list; [`RPUSH`](https://redis.io/commands/rpush) adds to the tail.
- [`LPOP`](https://redis.io/commands/lpop) removes and returns an element from the head of a list; [`RPOP`](https://redis.io/commands/rpop) does the same but from the tails of a list.
- [`LLEN`](https://redis.io/commands/llen) returns the length of a list.
- [`LMOVE`](https://redis.io/commands/lmove) atomically moves elements from one list to another.
- [`LTRIM`](https://redis.io/commands/ltrim) reduces a list to the specified range of elements.



`LPUSH` 将一个新的元素放在list的头部
`RPUSH` 将一个新的元素放在list的尾部
```
LPUSH key element [element ...]
```



`LPOP` 从list头部删除并返回一个元素
`RPOP` 从list尾部删除并返回一个元素
```
LPOP key [count]
```

`LLEN` 返回list的长度
```
LLEN key
```

`LMOVE` 原子地将元素移动到另一个list
```
LMOVE source destination <LEFT | RIGHT> <LEFT | RIGHT>
```


`LTRIM` 将一个列表减少到指定的元素范围。

`LRANGE` 从左到右遍历list  `RRANGE` 从右到左遍历lit
```
LRANGE list 0 -1
```

```
redis> LPUSH list "d" "c" "b" "a"
(integer) 4
redis> LRANGE list 0 -2
1) "a"
2) "b"
3) "c"
```


### 集合 Set

#### 基本指令

- [`SADD`](https://redis.io/commands/sadd) adds a new member to a set.
- [`SREM`](https://redis.io/commands/srem) removes the specified member from the set.
- [`SISMEMBER`](https://redis.io/commands/sismember) tests a string for set membership.
- [`SINTER`](https://redis.io/commands/sinter) returns the set of members that two or more sets have in common (i.e., the intersection).
- [`SCARD`](https://redis.io/commands/scard) returns the size (a.k.a. cardinality) of a set.
See the [complete list of set commands](https://redis.io/commands/?group=set).


`SADD` 向集合中添加一个元素
```
SADD key member [member ...]
```

`SREM` 移除集合中的特定元素
```
SREM key member [member ...]
```

`SISMEMBER` 查看元素是否在集合中
```
SISMEMBER key member
```

`SINTER` 返回集合的交集
```
SINTER key [key ...]
```

`SCARD` 返回集合中元素的个数
```
SCARD key
```

### 哈希 Hash

`HSET` 设置哈希中的键值对
```
HSET key 键 值
```

`HGET` 获取键|值
```
HGET key 键|值
```

`HGETALL` 获取所有键值对
```
> HGETALL
键
值
键
值
...
...

```

`HDEL` 删除哈希中的某个键值对
```
HDEL key 键|值
```

`HEXISTS` 判断某个键值对是否存在
```
HEXISTS key 键
```

`HKEYS` 查看有哪些键(filed)
```
HKEYS key
```

`HLEN` 查看哈希中键值对的数量
```
HLEN key
```

### 有序集合 SortedSet

#### 基本指令

`ZADD` 
```
ZADD key  值 键 值 键 ...
```

`ZRANGE` 
```
ZRANGE key 起始位置 结束位置
ZRANGE key 起始位置 结束位置 WITHSCORES
```

`ZSCORE`  查看集合中元素的值
```
ZSCORE key 键
```

`ZRANK` 查看某元素的排名
```
ZRANK key 键
```

`ZREVRANK` 查看某元素的排名（从大到小）
```
ZREVRANK key 键
```

### 地理空间Geospatial

`GEOADD` 添加地理位置信息
```
GEOADD key 经度 纬度 城市名 (经度 纬度 城市名 经度 纬度 城市名 ...)
```

`GEOPOS` 获取地理位置的经纬度
```
GEOPOS key 城市名
```

`GEODIST` 两个位置间的距离(默认单位为M)
```
GEODIST key city1 city2 
```

```
GEODIST key city1 city2 KM
```
结果以KM为单位


`GEOSEARCH` 搜索临近的位置
```
GEOSEARCH key FROMMEMBER city1 BYRADIUS 300KM
```
搜索city1 300KM内的位置(会包括自己)

### HyperLogLog


通过降低精确度，换取更小的内存消耗

```
PFADD key member [member ...]
```


读取基数
```
PFCOUNT key
```


合并多个hyperloglog
```
PFMERGE key-result key1 key2
```


### 位图Bitmap

bitmap是一种特殊的数据结构，它以位的方式存储数据。每个位代表一个二进制值，可以是0或1。Bitmap在Redis中以字符串的形式存储，每个字符可以存储8个位。

Bitmap可用于统计在线用户、统计用户活跃度

value只能为0或1

设置offset位置的值

```
SETBIT key offset value
```

得到offset位置的值

```
GETBIT key offset
```

设置某段位置的值(因为位图本质上是字符串)

```
SET Key "\xF0"
```

F0 (11110000)


统计key里有多少个1
```
BITCOUNT key
```

得到key里第一个0或1的位置

```
BITPOS key 0
BITPOS key 1

BITPOS key 1 strat end
```


`BITFIELD`命令是用于对位图进行操作的命令。位图是一种数据结构，它可以将一个连续的位序列组织起来，每个位只能存储`0`或`1`。`BITFIELD`命令可以对位图进行读取、设置、修改和计数等操作。

`BITFIELD`命令的基本语法如下：
```
BITFIELD key [GET type offset] [SET type offset value] [INCRBY type offset increment] [OVERFLOW WRAP|SAT|FAIL]
```

位图的每个位都可以用不同的类型表示，常见的类型有：
- `u[N]`：无符号整数，占用N个位，可以表示的最大值为2^N-1。
- `i[N]`：有符号整数，占用N个位，可以表示的范围为-2^(N-1)到2^(N-1)-1。
- `f[N.M]`：浮点数，占用N个位，其中M个位表示小数部分。

`BITFIELD`命令的具体使用方法如下：
- `GET type offset`：获取位图中指定偏移量的位的值。
- `SET type offset value`：设置位图中指定偏移量的位的值。
- `INCRBY type offset increment`：将位图中指定偏移量的位的值增加指定的增量。
- `OVERFLOW WRAP|SAT|FAIL`：设置位图操作溢出时的处理方式，可选的处理方式有：`WRAP`（循环）、`SAT`（饱和）和`FAIL`（失败）。

`BITFIELD`命令可以用于一些常见的应用场景，例如：
- 统计用户的签到情况：使用位图记录用户每天是否签到，可以方便地进行签到次数统计。
- 存储用户权限：使用位图记录用户的权限信息，可以快速判断用户是否具有某项权限。
- 计数器：使用位图记录某个事件发生的次数，可以实现简单的计数功能。

## 订阅模式和Stream
### 发布订阅模式

需要多个终端

`SUBSCRIBE` 订阅某个频道（然后一直进行等待，接收到消息也不会停止）
```
SUBSCRIBE 频道名
```

`PUBLISH` 在某个频道上发布消息

```
PUBLISH 频道名 消息
```

可以有多个接收者。


### 消息队列Stream

创建一个Stream，并向其中添加消息

例如，下面的命令创建了一个名为`mystream`的Stream，并添加了一个消息：

```
XADD mystream * message hello
```

其中，`*`表示使用redis自动生成的当前时间戳作为消息的ID，`message`是消息的键，`hello`是消息的值。


获得Stream长度
```
XLEN mystream
```


使用`XRANGE`得到Stream中的所有信息
```
XRANGE mystream - +
```


删除信息
```
XDEL mystream id
```


使用`XTRIM`保留指定数量的条目来控制stream数据结构的大小

```
XTRIM mystream MAXLEN [~] count
```

MAXLEN是一个表示最大长度的整数值，count是一个整数值，用于指定要保留的最大条目数量。

count可以是正整数，表示保留最新的count条目；也可以是负整数，表示保留最旧的count条目。如果在count前面加上"~"符号，则表示保留的条目数量是不包括count条目在内的。



使用`XREAD`或`XREADGROUP`命令来从Stream中读取消息。例如，下面的命令读取了`mystream`中的所有消息：
```
XREAD STREAMS mystream 0
```
其中，`STREAMS mystream 0`表示从`mystream`中读取从ID为0开始的所有消息。`STREAMS mystream $`表示读取现在开始以后最新的消息



```
XREAD COUNT 2 BLOCK 1000 STREAMS mystream 0
```

COUNT 2 表示一次**读取**两个消息，BLOCK表示没有消息的话，阻塞1000毫秒

消息是重复读取的



可以使用`XREADGROUP`命令来创建一个消费者组，并从Stream中消费消息。例如，下面的命令创建了一个名为`mygroup`的消费者组，并从`mystream`中消费消息：
```
XGROUP CREATE mystream mygroup 0
```

使用`XINFO`查看消费者组的信息
```
XINFO GROUPS mygroup
```


将消费者加入消费者组
```
XGROUP CREATECONSUMER mystream mygroup consumer1
```


接下来，你可以使用`XREADGROUP`命令来从`mygroup`中消费消息：
```
XREADGROUP GROUP mygroup consumer1 COUNT 1 STREAMS mystream >
```

其中，`GROUP mygroup consumer1`表示加入到`mygroup`消费者组中，并使用`consumer1`作为消费者的名称，`COUNT 1`表示一次最多消费1条消息，`STREAMS mystream >`表示从`mystream`中读取从上次消费的位置开始的所有消息。


当你成功消费了一条消息后，你需要使用`XACK`命令来确认消费。例如，下面的命令确认了`mygroup`消费者组消费了ID为`1591020728176-0`的消息：
```
XACK mystream mygroup 1591020728176-0
```




## 事务

Redis的事务是通过 MULTI、EXEC、DISCARD 和 WATCH 等命令来实现的。

1. MULTI：用于标记一个事务的开始，之后的命令都会被放入事务队列中等待执行。
2. EXEC：执行所有在事务队列中的命令并将结果返回给客户端。执行过程中，Redis会按顺序执行所有的命令，如果其中一个命令执行失败，那么事务会终止，已执行的命令不会回滚。
3. DISCARD：取消当前事务，清空事务队列，并恢复到非事务状态。
4. WATCH：用于监视一个或多个键，如果在事务执行期间被其他客户端修改，则事务将被放弃。


```
MULTI

xxx
xxx
xxx

EXEC/DISCARD
```


>[!info]
>在Redis中，事务并不具备原子性，当事务中的一个命令执行失败时，剩余的命令仍然会继续执行



## Redis持久化

可在`/etc/redis/redis.conf` 修改`save`配置，

```

################################ SNAPSHOTTING  ################################

# Save the DB to disk.
#
# save <seconds> <changes> [<seconds> <changes> ...]
#
# Redis will save the DB if the given number of seconds elapsed and it
# surpassed the given number of write operations against the DB.
#
# Snapshotting can be completely disabled with a single empty string argument
# as in following example:
#
# save ""
#
# Unless specified otherwise, by default Redis will save the DB:
#   * After 3600 seconds (an hour) if at least 1 change was performed
#   * After 300 seconds (5 minutes) if at least 100 changes were performed
#   * After 60 seconds if at least 10000 changes were performed
#
# You can set these explicitly by uncommenting the following line.
#
# save 3600 1 300 100 60 10000

```

可以用`save`命令手动保存

快照文件为`dump.rdb`，用`xxd`查看该二进制文件

`bgsave` 会创建一个子进程来进行保存，适合文件较大的情况


AOF会使redis自动保存指令，需要配置


## 主从复制

Redis的主从复制是一种数据复制机制，用于将一个Redis服务器的数据复制到其他多个Redis服务器，以实现数据的冗余备份和读写分离。

一般写主节点，读从节点

`role` 查看当前节点角色

`replicaof host port` 配置所属主节点

从节点需要修改配置文件中的端口号、pidfile、dbfilename 防止冲突


## 哨兵模式

`redis -sentinel` 启动哨兵节点（需要使用配置sentinel.conf）

```
sentinel monitor 主节点名称 ip地址 端口号 1
# 1表示只需要一个哨兵节点同意，就可以进行故障转移
```