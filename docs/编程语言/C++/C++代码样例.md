
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

