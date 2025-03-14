
# C++-Code

自己实现String类

```cpp
#include <iostream>
#include <cstring>

using namespace std;

class String{
public:
    // 默认构造函数
    String(const char *str = nullptr);
    // 拷贝构造函数
    String(const String &str);
    // 析构函数
    ~String();
    // 字符串赋值函数
    String& operator=(const String &str);

private:
    char *m_data;
    int m_size;
};

// 构造函数
String::String(const char *str)
{
    if(str == nullptr)  // 加分点：对m_data加NULL 判断
    {
        m_data = new char[1];   // 得分点：对空字符串自动申请存放结束标志'\0'的
        m_data[0] = '\0';
        m_size = 0;
    }
    else
    {
        m_size = strlen(str);
        m_data = new char[m_size + 1];
        strcpy(m_data, str);
    }
}

// 拷贝构造函数
String::String(const String &str)   // 得分点：输入参数为const型
{
    m_size = str.m_size;
    m_data = new char[m_size + 1];  //加分点：对m_data加NULL 判断
    strcpy(m_data, str.m_data);
}

// 析构函数
String::~String()
{
    delete[] m_data;
}

// 字符串赋值函数
/*
我们先用delete释放了实例m_data的内存，如果此时内存不足导致new char抛出异常，则m_data将是一个空指针，
这样非常容易导致程序崩溃。违背了异常安全性原则。
*/
String& String::operator=(const String &str)  // 得分点：输入参数为const
{
    if(this == &str)    //得分点：检查自赋值
        return *this;

    delete[] m_data;    //得分点：释放原有的内存资源
    m_size = strlen(str.m_data);
    m_data = new char[m_size + 1];  //加分点：对m_data加NULL 判断
    strcpy(m_data, str.m_data);
    return *this;       //得分点：返回本对象的引用
}

// 字符串赋值函数（推荐使用）
// 保证了异常安全性
String& String::operator=(const String &str)
{
    if(this != &str)
    {
        String str_temp(str);

        char* p_temp = str_temp.m_data;
        str_temp.m_data = m_data;
        m_data = p_temp;
    }
    return *this;
}
```

String.cpp

```cpp
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <ostream>
#include "String.hpp"

String::String(const char *str)
{
    if (str == nullptr)
    {
        m_size = 0;
        m_data = new char[1];
        m_data[0] = '\0';
    }
    else
    {
        m_size = strlen(str);
        m_data = new char[m_size+1];
        strcpy(m_data, str);
    }
}

String::String(const String &str) {
    m_size = str.m_size;
    m_data = new char[m_size];
    strcpy(m_data, str.m_data);
}

String::~String() {
    delete [] m_data;
}

String& String::operator=(const String &str) {
    if (this != &str) {
        String strTemp(str);

        char* pTemp = strTemp.m_data;
        strTemp.m_data = m_data;
        m_data = pTemp;

    }
    return *this;
}

std::ostream& operator<<(std::ostream& stream, const String &str) {
    stream<<str.m_data;
    return stream;
}
```

String.hpp
```cpp
#include <ostream>
class String
{
  private:
    char *m_data;
    int m_size;

  public:
    String(const char *str = nullptr);
    String(const String &str);

    String &operator=(const String &str);
    friend std::ostream& operator<<(std::ostream &stream, const String &str);
    
    ~String();
};


```

main.cpp
```cpp
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include "string/String.hpp"


int main()
{
    String a = "asdfadsf";
    std::cout<<a<<std::endl;
    return 0;
}
```


## 读取文件内容

```cpp
#include <fstream>
#include <string>
#include <sstream>

std::string readFile(const std::string& filePath) {
    std::ifstream fileStream(filePath);
    if(!fileStream) {
        std::cerr << "无法打开文件: " << fileName << std::endl;
        exit(1);
    }
   
    std::stringstream stringStream;
    stringStream << fileStream.rdbuf();
    return stringStream.str();
}

```

递归搜索文件夹中文件

```c++
#include <iostream>
#include <filesystem>
#include <chrono>
#include <memory>

namespace fs = std::filesystem;

const std::string PATH = "./";

int search(const std::string& path, std::shared_ptr<int> sum) {
    try {
        for (const auto& entry : fs::directory_iterator(path)) {
            std::string name = entry.path().filename().string();
            std::cout << "file: " << name << std::endl;

            if (fs::is_directory(entry.status())) {
                search(entry.path().string() + "/", sum);
            } else {
                (*sum)++;
            }
        }
    } catch (const std::filesystem::filesystem_error& e) {
        std::cerr << "Error: " << e.what() << std::endl;
    }

    return 0;
}

int main() {
    auto now = std::chrono::steady_clock::now();
    auto sum = std::make_shared<int>(0);

    search(PATH, sum);

    auto elapsed_time = std::chrono::steady_clock::now() - now;
    std::cout << "Elapsed time: " << std::chrono::duration_cast<std::chrono::milliseconds>(elapsed_time).count() << " ms" << std::endl;
    std::cout << "Count: " << *sum << std::endl;

    return 0;
}
```


## 线程池


### C++ 11 version

ref: [GitHub - progschj/ThreadPool: A simple C++11 Thread Pool implementation](https://github.com/progschj/ThreadPool)


```cpp

#ifndef THREAD_POOL_H
#define THREAD_POOL_H

#include <vector>
#include <queue>
#include <memory>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <future>
#include <functional>
#include <stdexcept>

class ThreadPool {
public:
    explicit ThreadPool(size_t);
    template <class F, class... Args>
    auto enqueue(F&& f, Args&&... args)
        -> std::future<typename std::result_of<F(Args...)>::type>;
    ~ThreadPool();

private:
    // need to keep track of threads so we can join them
    std::vector<std::thread> workers;
    // the task queue
    std::queue<std::function<void()>> tasks;

    // synchronization
    std::mutex              queue_mutex;
    std::condition_variable condition;
    bool                    stop;
};

// the constructor just launches some amount of workers
inline ThreadPool::ThreadPool(size_t threads) : stop(false) {
    for (size_t i = 0; i < threads; ++i)
        workers.emplace_back([this] {
            for (;;) {
                std::function<void()> task;
                
                {
                    std::unique_lock<std::mutex> lock(this->queue_mutex);
                    this->condition.wait(lock, [this] {
                        return this->stop || !this->tasks.empty();
                    });
                    if (this->stop && this->tasks.empty())
                        return;
                    task = std::move(this->tasks.front());
                    this->tasks.pop();
                }
                
                task();
            }
        });
}

// add new work item to the pool
template <class F, class... Args>
auto ThreadPool::enqueue(F&& f, Args&&... args)
    -> std::future<typename std::result_of<F(Args...)>::type> {
    using return_type = typename std::result_of<F(Args...)>::type;

    auto task = std::make_shared<std::packaged_task<return_type()>>(
        std::bind(std::forward<F>(f), std::forward<Args>(args)...));

    std::future<return_type> res = task->get_future();
    {
        std::unique_lock<std::mutex> lock(queue_mutex);

        // don't allow enqueueing after stopping the pool
        if (stop)
            throw std::runtime_error("enqueue on stopped ThreadPool");

        tasks.emplace([task]() { (*task)(); });
    }
    condition.notify_one();
    return res;
}

// the destructor joins all threads
inline ThreadPool::~ThreadPool() {
    {
        std::unique_lock<std::mutex> lock(queue_mutex);
        stop = true;
    }
    condition.notify_all();
    for (std::thread& worker : workers)
        worker.join();
}

#endif
```


### C++ 20 version

ref: https://github.com/progschj/ThreadPool/issues/109

```cpp
#ifndef THREAD_POOL_H
#define THREAD_POOL_H

#include <vector>
#include <queue>
#include <memory>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <future>
#include <functional>
#include <stdexcept>

class ThreadPool {
public:
    ThreadPool(size_t);
    template <class F, class... Args>
    auto enqueue(F&& f, Args&&... args)
        -> std::future<typename std::result_of<F(Args...)>::type>;
    ~ThreadPool();

private:
    // need to keep track of threads so we can join them
    std::vector<std::thread> workers;
    // the task queue
    std::queue<std::function<void()>> tasks;

    // synchronization
    std::mutex              queue_mutex;
    std::condition_variable condition;
    bool                    stop;
};

// the constructor just launches some amount of workers
inline ThreadPool::ThreadPool(size_t threads) : stop(false) {
    for (size_t i = 0; i < threads; ++i)
        workers.emplace_back([this] {
            for (;;) {
                std::function<void()> task;

                {
                    std::unique_lock<std::mutex> lock(this->queue_mutex);
                    this->condition.wait(lock, [this] {
                        return this->stop || !this->tasks.empty();
                    });
                    if (this->stop && this->tasks.empty())
                        return;
                    task = std::move(this->tasks.front());
                    this->tasks.pop();
                }

                task();
            }
        });
}

// add new work item to the pool
template <class F, class... Args>
auto ThreadPool::enqueue(F&& f, Args&&... args)
    -> std::future<typename std::result_of<F(Args...)>::type> {
    using return_type = typename std::invoke_result<F&&,Args&&...>::type; // ------ 改动------

    auto task = std::make_shared<std::packaged_task<return_type()>>(
        std::bind(std::forward<F>(f), std::forward<Args>(args)...));

    std::future<return_type> res = task->get_future();
    {
        std::unique_lock<std::mutex> lock(queue_mutex);

        // don't allow enqueueing after stopping the pool
        if (stop)
            throw std::runtime_error("enqueue on stopped ThreadPool");

        tasks.emplace([task]() { (*task)(); });
    }
    condition.notify_one();
    return res;
}

// the destructor joins all threads
inline ThreadPool::~ThreadPool() {
    {
        std::unique_lock<std::mutex> lock(queue_mutex);
        stop = true;
    }
    condition.notify_all();
    for (std::thread& worker : workers)
        worker.join();
}

#endif
```


## 禁用类的拷贝和移动

**禁用拷贝**

```cpp

```

**禁用移动**

```cpp

```


```cpp
ClassName(const ClassName&) = delete;
ClassName(ClassName&&) = delete;
ClassName& operator=(const ClassName&) = delete;
ClassName& operator=(ClassName&&) = delete;
```

宏形式
```cpp
#define DISABLE_COPY_AND_MOVE(ClassName) \
ClassName(const ClassName &) = delete; \
ClassName(ClassName &&) = delete; \
ClassName &operator=(const ClassName &) = delete; \
ClassName &operator=(ClassName &&) = delete;
```



## 警告、Assert

```c
#define Assert(expr)                                                           \
  if(!(expr)) {                                                                \
    printf("assert error: %s\n", #expr);                                       \
    *(volatile int *)0 = 0;                                                    \
  }
```

# SkipList

```cpp
#pragma once
#include <iostream>
#include <ostream>
#include <type_traits>
#include <vector>
#ifndef SKIPLIST_H
#define SKIPLIST_H

#include <cstddef>
#include "utils.h"

/**
 * @brief 
 * 
 * @tparam T key
 * @tparam U value
 */
template<typename T>
class SkipListNode {
public:
    SkipListNode() = delete;
    // 跳表节点构造函数
    SkipListNode<T>(T value, size_t level);

    ~SkipListNode() = default;

    DISALLOW_COPY_AND_MOVE(SkipListNode);

    T set_value(T value);
    T get_value() const {
        return value;
    }
    std::vector<SkipListNode<T> *> forward; // 跳表节点的前向指针数组
private:
    T value;
};

/**
 * @brief 跳表节点构造函数
 *
 * @tparam T
 */
template<typename T>
SkipListNode<T>::SkipListNode(T value, size_t level) {
    this->value = value;
    this->forward.resize(level, nullptr);
}

template<typename T>
class SkipList {
public:
    SkipList(int max_level, float p);
    ~SkipList();
    SkipListNode<T> *search(T value);
    void insert(T value);
    void remove(T value);

    DISALLOW_COPY_AND_MOVE(SkipList);

private:
    size_t random_level();

private:
    size_t max_level_{0};  // 跳表的最大层数
    float p_{0.5};         // 跳表的概率
    int current_level_{0}; // 当前跳表的层数

    SkipListNode<T> *head_; // 跳表的头节点
};

template<typename T>
SkipList<T>::SkipList(int max_level, float p) : max_level_(max_level), p_(p) {
    head_ = new SkipListNode<T>(-1, max_level_);
}

template<typename T>
SkipList<T>::~SkipList() {

    SkipListNode<T> *current = head_;
    SkipListNode<T> *next = nullptr;
    
    // 遍历并删除所有节点
    while (current != nullptr) {
        next = current->forward[0];
        delete current;
        current = next;
    }
    
    head_ = nullptr;
}

template<typename T>
void SkipList<T>::insert(T value) {

    std::vector<SkipListNode<T> *> update(max_level_, nullptr);
    SkipListNode<T> *current = head_;

    // 从最高层开始查找
    for (int i = current_level_ - 1; i >= 0; i--) {

        while (current->forward[i] && current->forward[i]->get_value() < value) {
            // 找到当前层中大于value的节点
            current = current->forward[i];
        }
        // 记录当前层中大于value的节点
        update[i] = current;
    }

    // 随机生成一个层数
    int level = random_level();

    // 如果随机生成的层数大于当前层数，则更新当前层数
    if (level > current_level_) {
        for (int i = current_level_; i < level; i++) {
            update[i] = head_;
        }
        current_level_ = level;
    }

    // 创建新节点
    SkipListNode<T> *new_node = new SkipListNode<T>(value, level);
    // 将新节点插入到跳表中
    for (int i = 0; i < level; i++) {
        new_node->forward[i] = update[i]->forward[i];
        update[i]->forward[i] = new_node;
    }

    std::cout << "插入节点" << value << "成功" << std::endl;
}

template<typename T>
void SkipList<T>::remove(T value) {
    std::vector<SkipListNode<T> *> update(max_level_, nullptr);
    SkipListNode<T> *current = head_;

    // 从最高层开始查找
    for (int i = current_level_ - 1; i >= 0; i--) {
        while (current->forward[i] && current->forward[i]->get_value() < value) {
            current = current->forward[i];
        }
        update[i] = current;
    }

    current = current->forward[0];

    if (current && current->get_value() == value) {
        for (int i = 0; i < current_level_; i++) {
            if (update[i]->forward[i] != current) {
                break;
            }
            update[i]->forward[i] = current->forward[i];
        }
    }

    // 删除空层
    while (current_level_ > 1 && !head_->forward[current_level_ - 1]) {
        current_level_--;
    }

    std::cout << "删除节点" << value << "成功" << std::endl;
}


template<typename T>
SkipListNode<T> *SkipList<T>::search(T value) {
    SkipListNode<T> *current = head_;

    for (int i = current_level_ - 1; i >= 0; i--) {
        while (current->forward[i] && current->forward[i]->get_value() < value) {
            current = current->forward[i];
        }
    }

    current = current->forward[0];

    if (current && current->get_value() == value) {
        return current;
    }

    return nullptr;
}

template<typename T>
size_t SkipList<T>::random_level() {
    size_t level = 1;
    while (rand() < RAND_MAX * p_ && level < max_level_) {
        level++;
    }
    return level;
}

#endif
```