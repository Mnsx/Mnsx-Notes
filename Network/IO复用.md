# IO复用

## 基于select的IO复用

### select 函数的功能

使用select函数时可以将多个文件描述符集中到一起统一监视

select函数的调用顺序

1. **设置文件描述符**

   利用select可以同时监视多个文件描述符，首先需要将要监视的文件描述符集中到一起，集中时也要按照监视项（接收、传输、异常）进行区分

   使用 `fd_set` 数组变量来执行此操作，其中最左端的位表示文件描述符0，如果该位设置为1，则表示文件描述符是监视对象

   通常，在fd_set变量中注册或更改值的操作都由宏完成

   * `FD_ZERO(fd_set* fdset)`：将 fd_set 所有位初始化为0
   * `FD_SET(int fd, fd_set* fdset)`：在参数 fdset 所指向的变量中注册文件描述符fd的信息
   * `FD_CLR(int fd, fd_set* fdset)`：在参数 fdset 所指向的变量中清除文件描述符 fd的信息
   * `FD_ISSET(int fd, fd_set* fdset)`：若参数fdset指向的变量中包含文件描述符fd的信息，则返回真

2. 设置检查范围和超时

   ```c
   int select(
       int maxfd, fd_set * readset, fd_set * writeset, fd_set * exceptset, const struct
       timeval * timeout);
   ```

   文件描述符的监视范围与select函数的第一参数有关，select函数要求通过第一个参数传递监视对象文本描述符的数量，**因此只需要将最大的文件描述符值+1再传递到selelct函数即可**

   select函数的超时时间与最后一个参数有关

   ```c
   struct timeval
   {
       long tv_sec; //seconds
       long tv_usec; //microseconds
   }
   ```

   select只在监视的文件描述符发生变化时才会返回，如果没有发生变化，就会进入阻塞状态，指定超时时间就是为了防止发生这种情况，**即使文件描述符中未发生变化，只要过了指定时间，也会从函数中返回**

## 基于epoll的IO复用

### select技术问题

* 每次调用select函数后常见的针对所有文件描述符的循环语句
* 每次调用select函数时都需要向该函数传递监视对象信息

### epoll实现

epoll无需编写以监视状态变化为目的的针对所有文件描述符的循环语句

且调用对应的`epoll_wait`函数时无需每次传递监视对象信息

* `epoll_create`：创建保存epoll文件描述符的空间
* `epoll_ctl`：向空间注册并注销文件描述符
* `epoll_wait`：与select类似，等待文件描述符发生变化

epoll中通过结构体`epoll_event`将发生变化的文件描述符单独集中在一起

```c++
struct epoll_event {
    __uint32_t events;
    epoll_data_t data;
}

typedef union epoll_data {
    void * ptr;
    int fd;
    __uint32_t u32;
    __uint64_t u64;
} epoll_data_t;
```

声明足够大的epoll_event结构体数组后，传递给epoll_wait函数时，发生变化的文件描述符信息被填入数组，因此不需要循环所有文件描述符

### epoll函数作用

* **epoll_create**

  ```c++
  int epoll_create(int zise); // 成功时返回epoll文件描述符，失败时返回-1
  ```

  通过参数size传递值决定epoll例程的大小，但**该值只是向操作系统提的建议**

  需要终止时，与其他文件描述符相同，调用`close`

* **epoll_ctl**

  生成epoll历程后，应在其内部注册监视对象文件描述符

  ```c++
  int epoll_ctl(int epfd, int op, int fd, struct epoll_event * event);
  ```

  * `epfd`：用于注册监视对象的epoll例程的文件描述符

  * `op`：用于指定监视对象的添加、删除或更改等操作

    > `EPOLL_CTL_ADD`：将文件描述符注册到epoll例程
    >
    > `EPOLL_CTL_DEL`：从epoll例程中删除文件描述符
    >
    > `EPOLL_CTL_MOD`：更改注册的文件描述符的关注事件发生情况

  * `fd`：需要注册的监视对象文件描述符

  * `event`：监视对象的事件类型

    > `EPOLLIN`：需要读取数据的情况
    >
    > `EPOLLOUT`：输出缓冲为空，可以立即发送数据的情况
    >
    > `EPOLLOUT`：收到OOB数据的情况
    >
    > `EPOLLRDHUP`：断开连接或半关闭的情况，这在边缘触发方式下非常有用
    >
    > `EPOLLERR`：发生错误的情况
    >
    > `EPOLLET`：以边缘触发的方式得到事件通知
    >
    > `EPOLLONESHOT`：发生一次事件后，相应的文件描述符不在收到事件通知，因此需要发送第二个参数EPOLL_CTL_MOD,，再次设置事件

* **epoll_wait**

  ```c++
  int epoll_wait(int epfd, struct epoll_event* events, int maxevents, int timeout);
  ```

  * `epfd`：表示事件发生监视范围的epoll例程的文件描述符
  * `events`：保存发生事件的文件描述符集合的结构体地址值
  * `maxevents`：第二个参数中可以保持的最大事件数
  * `timeout`：以1/1000秒为单位的等待事件，传递-1时，一直等待直到发生事件

### 条件触发和边缘触发

条件触发方式中，只要输入流缓冲有数据就会一直通知该事件

边缘触发中，缓冲收到数据时仅注册一次该事件

