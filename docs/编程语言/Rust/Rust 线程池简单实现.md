# Rust 线程池简单实现

#rust #并发 #并行

```rust
use std::sync::{mpsc, Arc, Mutex};
use std::thread;

// 定义一个 Job 类型别名，它是一个 Boxed 的闭包
// FnOnce: 闭包可以被调用一次
// Send: 闭包可以被安全地发送到另一个线程
// 'static: 闭包不包含任何非静态生命周期的引用
type Job = Box<dyn FnOnce() + Send + 'static>;

// 线程池与工作线程之间传递的消息
enum Message {
    NewJob(Job), // 新的任务
    Terminate,   // 终止信号
}

pub struct ThreadPool {
    workers: Vec<Worker>,
    sender: Option<mpsc::Sender<Message>>,
}

struct Worker {
    id: usize,
    thread: Option<thread::JoinHandle<()>>,
}

impl ThreadPool {
    /// 创建一个新的 ThreadPool。
    ///
    /// `threads` 参数是池中线程的数量。
    ///
    /// # Panics
    ///
    /// 如果 `threads` 为 0，`new` 函数会 panic。
    pub fn new(threads: u32) -> Result<Self, PoolCreationError> {
        if threads == 0 {
            return Err(PoolCreationError("Thread count must be greater than 0".to_string()));
        }

        let (sender, receiver) = mpsc::channel();
        let receiver = Arc::new(Mutex::new(receiver)); // 允许多个 worker 共享 receiver

        let mut workers = Vec::with_capacity(threads as usize);

        for id in 0..threads {
            workers.push(Worker::new(id as usize, Arc::clone(&receiver)));
        }

        Ok(ThreadPool {
            workers,
            sender: Some(sender),
        })
    }

    /// 将一个任务提交到线程池中执行。
    ///
    /// `job` 是一个闭包，它将被发送到线程池中的某个空闲线程执行。
    pub fn spawn<F>(&self, job: F)
    where
        F: FnOnce() + Send + 'static,
    {
        let job = Box::new(job);
        // 使用 unwrap 是因为 sender 只会在 ThreadPool drop 时变为 None
        self.sender
            .as_ref()
            .unwrap()
            .send(Message::NewJob(job))
            .expect("ThreadPool::spawn: Failed to send job to worker. Channel might be closed.");
    }
}

// 当 ThreadPool 被丢弃时，确保所有线程都完成工作并被清理
impl Drop for ThreadPool {
    fn drop(&mut self) {
        println!("Sending terminate message to all workers.");
        if let Some(sender) = self.sender.as_ref() {
            for _ in &self.workers {
                // 尽力发送，如果接收端已经关闭也无妨
                let _ = sender.send(Message::Terminate);
            }
        }

        // 关闭 sender，这样 worker 在尝试接收新任务时会知道没有更多任务了
        // 这一步很重要，因为如果 worker 正在等待任务，而 sender 没有被 drop，
        // 即使发送了 Terminate 消息，worker 也可能在 Terminate 消息被处理前
        // 继续阻塞在 recv() 上。drop(sender) 会使 recv() 返回 Err，从而使 worker 退出。
        drop(self.sender.take());


        println!("Shutting down all workers.");
        for worker in &mut self.workers {
            println!("Shutting down worker {}", worker.id);
            if let Some(thread) = worker.thread.take() { // take 出线程句柄并 join
                match thread.join() {
                    Ok(_) => println!("Worker {} finished.", worker.id),
                    Err(e) => eprintln!("Worker {} panicked during shutdown: {:?}", worker.id, e),
                }
            }
        }
        println!("All workers have been shut down.");
    }
}
impl Worker {
    fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Message>>>) -> Worker {
        let thread = thread::spawn(move || loop {
            // 从通道接收消息
            // lock() 会阻塞当前线程，直到互斥锁可用
            // recv() 会阻塞当前线程，直到有消息可用或通道关闭
            let message = receiver.lock().unwrap().recv();

            match message {
                Ok(Message::NewJob(job)) => {
                    // println!("Worker {} got a job; executing.", id);
                    job(); // 执行任务
                    // println!("Worker {} finished job.", id);
                }
                Ok(Message::Terminate) => {
                    // println!("Worker {} was told to terminate.", id);
                    break; // 收到终止信号，退出循环
                }
                Err(_) => {
                    // 当发送端关闭且通道中没有更多消息时，recv 会返回 Err
                    // println!("Worker {} disconnecting; sender dropped.", id);
                    break; // 发送端已关闭，退出循环
                }
            }
        });

        Worker {
            id,
            thread: Some(thread),
        }
    }
}

#[derive(Debug)]
pub struct PoolCreationError(String);

impl std::fmt::Display for PoolCreationError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Failed to create thread pool: {}", self.0)
    }
}

impl std::error::Error for PoolCreationError {}


// 使用示例
fn main() {
    let pool = match ThreadPool::new(4) {
        Ok(p) => p,
        Err(e) => {
            eprintln!("Error creating thread pool: {}", e);
            return;
        }
    };
    println!("Thread pool created with 4 threads.");

    for i in 0..10 {
        let task_id = i;
        pool.spawn(move || {
            println!("Task {} starting by thread {:?}", task_id, thread::current().id());
            thread::sleep(std::time::Duration::from_secs(1));
            println!("Task {} finished by thread {:?}", task_id, thread::current().id());
        });
    }

    println!("All tasks submitted. Main thread will sleep for a bit to allow some tasks to start.");
    thread::sleep(std::time::Duration::from_millis(500)); // 给一些任务启动的时间

    println!("Main thread is now explicitly dropping the pool to trigger shutdown.");
    // 当 pool 离开作用域时，它的 Drop trait 实现会被调用，从而优雅地关闭所有线程。
    // 或者我们可以显式地 drop(pool);
    drop(pool);

    println!("Thread pool has been dropped. Main thread exiting.");
    // 注意：主线程退出后，如果工作线程没有被正确 join，它们可能会被强制终止。
    // Drop impl 确保了 join 的发生。
}
```