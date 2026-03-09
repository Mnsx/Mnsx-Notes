# Unix系统编程

## POSIX文件操作

* open函数

  ```c
  int fd = open(const char *pathname, int flags, mode_t mode); 
  ```

  用于打开文件，意味着获得这个文件的访问句柄

  * `return`：**句柄（file descriptor）**

    标准输入0，标准输出1，标准错误2

  * `int flag`：

    * 主类

      | 参数     | 含义               |
      | -------- | ------------------ |
      | O_RDONLY | 以只读方式打开     |
      | O_WRONLY | 以只写方式打开     |
      | O_RDWR   | 以可读可写方式打开 |

      **三个方式是互斥的**

    * 副类

      | 参数     | 含义                                                         |
      | -------- | ------------------------------------------------------------ |
      | O_CREAT  | 如果文件不存在则创建该文件                                   |
      | O_EXCL   | 如果使用O_CREAT选项且文件存在，则返回错误消息                |
      | O_NOCTTY | 如果文件为终端，那么终端不可以调用open系统调用的那个进程的控制终端 |
      | O_TRUNC  | 如果文件已经存在则删除文件中的原有数据                       |
      | O_APPEND | 以追加的方式打开                                             |


    **主副可以配合使用**

  * `mode_t mode`：文件被创建时，可以通过这个参数指定权限，但是会受到掩码的影响

* read函数

  ```c
  ssize_t read(int fd, void *buf, size_t count);
  ```

* write函数

  ```c
  ssize_t write(int fd, const void *buf, size_t count);
  ```

* lseek函数

  ```c
  off_t lseek(int fd, off_t offset, int whence);
  ```

  * `int whence`：偏移量的起始位置

    | 参数     | 含义                     |
    | -------- | ------------------------ |
    | SEEK_SET | 从文件开始计算偏移量     |
    | SEEK_CUR | 从当前光标位置计算偏移量 |
    | SEEK_END | 从文件结束位置计算偏移量 |

* close函数

  ```c
  int close(int fd);
  ```

## 进程

### 进程概览

进程是操作系统进行资源分配和调度的基本单位

每个进程结束并被系统回收后，其PID可被重新分配给新的进程

遵循内核的延迟重用算法以避免PID冲突

### 父子进程关系

通过调用`fork()`系统调用，一个父进程可以创建一个新的子进程

子进程继承了父进程的大部分属性

子进程的PPID字段记录着父进程的PID

### 特殊进程

* **孤儿进程**: 当父进程在其子进程之前终止时，子进程会编程孤儿进程，此时操作系统会自动将其领养给`init进程（PID为1的特殊进程）`，使孤儿进程得以正常完成生命周期

* **僵尸进程**: **若子进程比父进程先结束，而父进程未正确处理子进程的终止状态**，子进程的状态信息就会滞留在系统中，形成僵尸进程。僵尸进程虽不占用CPU资源，但其在进程表中的条目仍会消耗一定的内存资源，**因此应当及时清理僵尸进程**

  > **可以使用`wait()`或者`waitpid()`来解决僵尸进程的问题**

### 进程创建

使用`fork()`函数创建一个与调用进程几乎完全相同的子进程

调用成功后**它会在父进程中返回子进程的PID**，在子进程中返回0，如果调用失败，则返回-1

子进程和父进程在内存布局上有所不同：它们共用代码区域，但是**数据、堆栈和其他私有空间则被复制并映射到独立的物理内存区域**

### 守护进程

守护进程是运行在后台的特殊进程，它独立于控制终端并且周期性的执行任务或等待触发事件

* **创建守护进程规则**

  1. 调用`umask`将文件模式创建屏蔽字设置为一个已知值（由继承得来的文件模式创建屏蔽字可能被设置为拒绝某些权限）
  2. 调用`fork()`，然后让父进程`exit()`
  3. 调用`setsid`创建一个新会话，使调用进程：
     * 成为新会话的首进程
     * 成为新进程组的组长进程
     * 没有控制终端
  4. 将当前工作目录更改为根目录（从父进程继承过来的当前工作目录可能挂载在文件系统中），**如果守护线程的当前工作目录在一个挂载文件系统中，那么该文件系统就不能被卸载**
  5. 关闭不再需要的文件描述符

* **守护进程日志管理**

  > （不推荐）使用文件输入输出创建日志文件
  >
  > ```c
  > #include <unistd.h>
  > #include <sys/types.h>
  > #include <sys/stat.h>
  > #include <fcntl.h>
  > #include <stdlib.h>
  > #include <stdio.h>
  > #include <signal.h>
  > #include <time.h>
  > #include <string.h>
  > 
  > void createDaemonize() {
  > 
  >  pid_t pid;
  >  umask(0);
  >  pid = fork();
  >  if (pid < 0) {
  > 
  >      exit(-1);
  >  } else if (pid > 0) {
  > 
  >      exit(0);
  >  }
  >  if (setsid() < 0) {
  > 
  >      exit(-1);
  >  }
  >  if (chdir("/") < 0) {
  > 
  >      exit(-1);
  >  }
  >  close(STDIN_FILENO);
  >  close(STDOUT_FILENO);
  >  close(STDERR_FILENO);
  > }
  > 
  > // 获取时间字符串
  > static void getLocalTime(char *buf, int size) {
  > 
  >  time_t now = time(NULL);
  > 
  >  struct tm *res = localtime(&now);   
  > 
  >  strftime(buf, size, "[%Y-%m-%d %H:%M:%S]", res);
  > }
  > 
  > // 通过文件读写完成日志功能
  > void startLog() {
  > 
  >  int fd;
  >  char buf[1024] = {0};
  > 
  >  fd = open("/home/mnsx/daemonize.log", O_WRONLY | O_CREAT | O_APPEND, 0644);
  >  if (fd < 0) {
  > 
  >      return;
  >  }
  > 
  >  getLocalTime(buf, sizeof(buf));
  > 
  >  // 日志内容
  >  char msg[100] = "Daemonize is running!\n";
  > 
  >  strncat(buf, msg, sizeof(buf) - strlen(buf));
  > 
  >  if (write(fd, buf, strlen(buf)) < 0) {
  > 
  >      close(fd);
  >      return;
  >  }
  > 
  >  close(fd);
  > 
  >  sleep(10);
  > }
  > 
  > void preLog() {
  > 
  >  int fd = open("/home/mnsx/daemonize.log", O_WRONLY | O_CREAT | O_APPEND, 0644);
  >  if (fd != -1) {
  >      char startup_msg[] = "=== Daemonize started ===\n";
  >      write(fd, startup_msg, strlen(startup_msg));
  >      close(fd);
  >  }
  > }
  > 
  > int main() {
  > 
  >  createDaemonize();
  >  // 启动日志文件
  >  preLog();
  >  while (1) {
  > 
  >      // 开启日志功能
  >      startLog();
  >  }
  >  return 0;
  > }
  > ```

  大多数守护进程都是用BSDS的syslog进行日志管理

  ![](.\Picture\BSD-syslog工作原理.png)

* **守护进程规范**

  1. 如果守护进程使用锁文件，那么该文件通常存储在`/var/run`目录中，**通常守护进程需要超级用户权限才能在此目录下创建文件**，锁文件的名字通常为name.pid，其中name是该守护进程的名字
  2. 如果守护进程支持配置选项，那么配置文件通常存放在`/etc`目录下，文件名通常为name.conf
  3. 守护进程可用命令行启动，但通常他们是系统初始化脚本之一启动的
  4. 当配置文件被修改后，通常需要重启守护进程才能生效，**可以使用SIGHUP信号**，当守护进程接收该信号，重新读取配置文件

### exec函数家族

exec函数家族用于在当前进程中执行一个新的程序

```c
int execl(const char *path, const char *arg0, ..., const char *argn, (char *)NULL);
```

此函数用于**执行一个可执行文件**

接受可执行文件的路径作为参数，并以可变参数的形式传递命令行参数，**参数列表以空指针`(char *)NULL`结尾

```c
int execv(const char *path, char * const argv[]);
```

此函数与`execl()`类似，但命令行参数以数组传递

argv是一个以空指针结尾的字符串数组

```c
int execle(const char *path, const char *arg0, ..., const char *argn, (char *)NULL, char * const envp[]);
```

此函数与`execl()`类似，但是可以指定环境变量

envp是以空指针结尾的字符串数组

```c
int execvp(const char *file, char *const argv[]);
```

此函数与`execv()`类似，它在程序的搜索路径中查找可执行文件

file是一个文件名，它会根据环境变量PATH中指定的路径搜索可执行文件

```c
int execve(const char *path, char *const argv[], char *const envp[]);
```

此函数与execv类似，但可以指定环境变量

**这些函数成功执行不会有返回值**，返回值为-1表示出现错误，并可以通过全局变量errno获取具体的错误代码

### system函数

通过调用操作系统提供的相关机制来在新的子进程中执行指定的命令，并等待命令执行完成后返回

```c
int system(const char *command);
```

其中，command是一个指向以NULL结尾的字符串指针，表示要执行的命令

函数返回一个表示命令执行结果的整数值

* **system的工作过程**

  1. 创建一个新的子进程
  2. 在子进程中调用操作系统提供的函数来执行指定的命令
  3. 父进程等待子进程执行完成
  4. 子进程完成执行后返回状态信息给父进程
  5. 父进程返回执行结果

* **system的返回结果**

  * 如果命令成功执行，并正常终止，返回一个非零值
  * 如果命令成功执行，**但是通过返回退出码表示出现了错误**，返回该退出码
  * 如果命令执行失败，或者无法执行命令，返回-1

### 进程通信

* **无名管道**

  无名管道pipe是一种半双工的通信方式，数据只能单向流动，且只能在具有亲缘关系的进程间使用

  ```c
  #include <stdio.h>
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <sys/wait.h>
  #include <fcntl.h>
  #include <unistd.h>
  
  int main() {
  
      int fds[2];
      int res = pipe(fds);
      if (res != 0) {
  
          return -1;
      }
  
      pid_t pid;
      pid = fork();
      char readBuf[50] = {0};
      char writeBuf[50] = "Hello world!";
      if (pid == 0) {
  
          // 子进程
          read(fds[0], readBuf, sizeof(readBuf));
          printf("read content is %s\n", readBuf);
          sprintf(writeBuf, "Goodbye world!");
          write(fds[1], writeBuf, sizeof(writeBuf));
      } else if (pid > 0) {
  
          // 父进程
          write(fds[1], writeBuf, sizeof(writeBuf));
          sleep(10);
          read(fds[0], readBuf, sizeof(readBuf));
          printf("parent read content is %s\n", readBuf);
          wait(NULL);
      } else {
  
          return -1;
      }
  
      return 0;
  }
  ```

* **有名管道**

  有名管道FIFO也是半双工的通信方式，但它允许无亲缘关系进程间的通信

  有名管道的文件仅仅作为传输数据的通道，**并不会存放传输的数据**

  使用有名管道时需要先启动**读**，在写入管道后，如果不存在读取，那么可能存在内容丢失

  ```c
  #include <stdio.h>
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <fcntl.h>
  #include <unistd.h>
  
  int main() {
  
      if (access("fifo", F_OK) != 0) { 
  
          char *command = "mkfifo fifo";
          system(command);
      }
  
      int fd = open("/home/mnsx/fifo", O_RDWR);
      char readBuf[50] = {0};
      char writeBuf[50] = "Goodbye world!";
      read(fd, readBuf, sizeof(readBuf));
      printf("2_1 read from 2_2, message is %s\n", readBuf);
      write(fd, writeBuf, sizeof(writeBuf));
  
      return 0;
  }
  ```

  ```c
  #include <stdio.h>
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <fcntl.h>
  #include <unistd.h>
  
  int main() {
  
      if (access("fifo", F_OK) != 0) { 
  
          char *command = "mkfifo fifo";
          system(command);
      }
  
      int fd = open("/home/mnsx/fifo", O_RDWR);
      char readBuf[50] = {0};
      char writeBuf[50] = "Hello world!";
      write(fd, writeBuf, sizeof(writeBuf));
      sleep(10);
      read(fd, readBuf, sizeof(readBuf));
      printf("2_2 read from 2_1, message is %s\n", readBuf);
  
      return 0;
  }
  ```

* **消息队列**

  消息队列**只有释放消息队列或关闭操作系统才会消失**

  本质上是位于内核空间的链表

  消息类型用整数表示，而且必须大于0

  每种类型的消息都被对应的链表所维护

  **消息队列不适合表较大的数据的传输**

  > `ftok()`是一个用于生成唯一IPC键值的函数（File to Key）
  >
  > 在需要进行进程通信时，它能把一个存在的文件路径和一个整数项目ID装换成一个唯一的键值（key_t类型）
  >
  > ```c
  > key_t ftok(const char *pathname, int proj_id);
  > ```
  >
  > * `pathname`: 一个**必须存在且进程可以访问**的文件路径
  > * `proj_id`: 项目ID，**只有最低有效位8位（0-255）**
  > * **返回值**: 成功时返回生成的`key_t`类型的IPC键值，失败时返回-1

  **常用函数**

  ```c
  int msgget(key_t key, int msgflg);
  ```

  * `msgflg`用于控制消息队列的创建、访问权限以及特定操作行为

    * **创建/打开模式**

      `IPC_CREAT`: 若key不存在则创建新队列，存在则直接打开

      `IPC_CREAT | IPC_EXCL`: 若key存在则报错，确保创建的是新队列

      `0`: 仅当队列已存在时打开，不存在则报错 

    * **权限设定**

      包含9位的权限标识

    * **私有队列**

      如果配和`IPC_PRIVATE`使用，会初始化创建进程专有的队列，每次都会创建一个新的对象

  ```c
  int msgsnd(int msqid, const void *msgp, size_t msgsz, int msgflg);
  ```

  ```c
  ssize_t msgrcv(int msqid, void *msgp, size_t msgsz, long msgtyp, int msgflg);
  ```

  * 用于发送和接受消息，接受消息时如果队列中没有对应类型的消息，那么会阻塞进程等待接受消息

    * `msgflg`主要用于控制消息队列满时的发送行为

      `0`（默认值）: **阻塞方式**，如果消息队列满时，会一直阻塞，直到有足够空间容纳新消息，或消息队列被删除

      `IPC_NOWAIT`: **非阻塞方式**，如果消息队列满时，不会等待，而是立即返回-1，并将`errno`设置为`EAGAIN`

  ```c
  int msgctl(int msqid, int cmd, struct msqid_ds *buf);
  ```

  * `cmd`: 控制命令

    `IPC_STAT`: 获取消息队列的`msqid_ds`结构，并将其存入buf中

    `IPC_SET`: 根据buf指向的结构，设置消息队列的UID、GID、模式等属性

    `IPC_RMID`: 从内核中删除指定的消息队列

  * `struct msqid_ds *buf`

    ```c
    struct msqid_ds {
    
        struct ipc_perm msg_perm;   // 拥有者关系和权限
        time_t msg_stime;           // 最后发送时间
        time_t msg_rtime;           // 最后接受时间
        time_t msg_ctime;           // 最后修改时间
        unsigned long __msg_cbytes; // 目前已经使用的字节数
        msgqnum_t msg_qnum;         // 目前已经有的消息数量
        msglen_t msg_qbytes;        // 最大允许的字节长度
        pid_t msg_lspid;            // 最后发送消息的PID
        pid_t msg_lrpid;            // 最后接受消息的PID
    };
    ```

  * **返回值**: 成功返回0，失败返回-1

  ```c
  #include <stdio.h>
  #include <sys/types.h>
  #include <sys/ipc.h>
  #include <sys/msg.h>
  #include <string.h>
  
  struct msgBuf {
  
      long msgType;
      char msgText[1024];
  };
  
  int main() {
  
      // 创建十六进制数
      key_t key = ftok("profile", 77);
  
      // 创建消息队列
      int msgId = msgget(key, IPC_CREAT | IPC_PRIVATE);
  
      // 处理消息内容
      struct msgBuf mb;
      mb.msgType = 7;
      strcpy(mb.msgText, "Hello world!");
  
      // 发送消息
      msgsnd(msgId, &mb, sizeof(mb), 0);
  
      return 0;
  }
  ```

  ```c
  #include <stdio.h>
  #include <sys/types.h>
  #include <sys/ipc.h>
  #include <sys/msg.h>
  #include <string.h>
  
  struct msgBuf {
  
      long msgType;
      char msgText[1024];
  };
  
  int main() {
  
      // 获取消息队列
      key_t key = ftok("profile", 77);
      int msgId = msgget(key, IPC_PRIVATE);
  
      // 接受消息
      struct msgBuf mb;
      msgrcv (msgId, &mb, sizeof(mb), 7, 0);
  
      printf("%s\n", mb.msgText);
  
      return 0;
  }
  ```

* **共享内存**

  共享内存相对于消息队列**减少了用户态和内核态之间的消息拷贝过程**

  每个进程都会维护一个从内存地址到虚拟内存页面之间的映射关系

  **访问共享内存区域和访问进程独有的内存区域一样快**

  但是需要应用程序子集做互斥

  ```c
  int shmget(key_t key, size_t size, int shmflg);
  ```

  * `shmflg`用于设定共享内存的创建模式、存储权限以及特殊操作行为

    `IPC_CREAT`: 如果不存在与key相同的共享内存，则新建，如果存在则返回现有的共享内存的标识

    `IPC_EXCL`: 和`IPC_CREAT`配合使用，如果key确定共享内存存在，则返回失败，这样强制创建全新的共享内存

    存储权限模式：通常以八进制数标识

    `SHM_HUGETLB`: 使用[大页面]来分配共享内存，以提高内存提效率（大于预设的4KB）

    `SHM_NORESERVE`: 不在交换分区中为这块共享内存保留空间

  ```c
  void *shmat(int shmid, const void *shmaddr, int shmflg);
  ```

  * `shmaddr`通常设置为NULL，则系统会自动分配合适的内存空间

  * `shmflg`用于控制共享内存隐射到调用过程地址空间的方式及访问权限

    `0`（默认）: 共享内存以读写模式隐射，且**shmaddr必须为NULL**

    `SHM_RDONLY`: 以只读方式隐射共享内存

    `SHM_RND`: 配合`shmaddr`参数使用，将地址自动向上取整到内存也边界

    `SHM_REMAP`: 替换由`shmaddr`指定的当前隐射（需要和`shmaddr`非空配合使用）

  ```c
  int shmdt(const void *shmaddr);
  ```

  用于释放共享内存区域

  ```c
  #include <stdio.h>
  #include <sys/ipc.h>
  #include <sys/shm.h>
  #include <string.h>
  
  int main() {
  
      // 获取共享内存
      int shmId = shmget(ftok("profile", 77), 1024, IPC_CREAT);
      
      // 获取共享内存地址
      void *addr = shmat(shmId, NULL, 0);
  
      // 写入
      strcpy((char *)addr, "Hello world");
  
      // 释放共享内存
      shmdt(addr);
  
      return 0;
  }
  ```

  ```c
  #include <stdio.h>
  #include <sys/ipc.h>
  #include <sys/shm.h>
  #include <string.h>
  
  int main() {
  
      // 获取共享内存
      int shmId = shmget(ftok("profile", 77), 1024, IPC_CREAT);
      
      // 获取共享内存地址
      void *addr = shmat(shmId, NULL, 0);
  
      // 读取
      printf("%s\n", (char *)addr);
  
      // 释放共享内存
      shmdt(addr);
  
      return 0;
  }
  ```

* **信号**

  进程通过调用`kill()`向其他进程发送一个信号，成功返回0，失败返回-1

  ```c
  int kill(pid_t pid, int sig);
  ```

  通过`signal()`对信号进行捕获操作

  ```c
  sighandler_t signal(int signum, sighandler_t handler);
  ```

  准备捕获的信号为sig参数，接收到指定信号后将要调用的函数由func指定，还可以通过`SIG_IGN`去忽略信号

  ```c
  #include <stdio.h>
  #include <signal.h>
  
  void fun(int sigNum) {
  
      printf("%d\n", sigNum);
  }
  
  int main() {
  
      // signal(SIGINT, fun);
      signal(SIGINT, SIG_IGN);
      while (1);
  
      return 0;
  }
  ```

* **区别**

  | IPC方式  | 通信类型      | 数据量 | 同步方式   | 通信方向 | 适用范围      |
  | -------- | ------------- | ------ | ---------- | -------- | ------------- |
  | 无名管道 | 字节流        | 小     | 自带阻塞   | 单向     | 父子/亲缘进程 |
  | 有名管道 | 字节流        | 小     | 自带阻塞   | 单向     | 任何进程      |
  | 消息列表 | 结构化消息    | 中     | 可选阻塞   | 双向     | 任何进程      |
  | 共享内存 | 内存数据      | 大     | 需额外同步 | 双向     | 任何进程      |
  | 信号     | 事件通知      | 极小   | 异步       | 单向     | 任何进程      |
  | Socket   | 字节流/数据报 | 大     | 自带阻塞   | 双向     | 跨网          |

## 线程

### 线程的定义

线程是进程内的轻量级执行单元，具备独立的执行流

同时与同一进程内的其他线程共享以下资源

* 虚拟内存空间（代码段、数据段、堆）
* 文件描述符表、信号处理（部分）
* 进程ID、用户ID等进程级属性

> pthread_t含义
>
> pthread_t是线程的唯一标识符，类型可能是整数、指针或结构体（依赖系统实现），不能直接用printf输出，需要使用`pthread_self())`获取当前线程ID，或通过`pthread_equal(tid1, tid2)`比较ID是否相同

### 线程的使用

* 创建线程

  ```c
  int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void *), void *arg);
  ```

  `返回值`: 如果创建成功返回0，如果创建失败返回错误码

  `pthread_t *thread`:  存储新线程的ID

  `const pthread_attr_t *attr`: 线程属性，NULL表示默认属性

  `void *(*start_routine) (void *)`: 线程执行函数

  `void *arg`: 线程执行函数中的参数 

  > 新线程从`start_routine`函数开始执行，共享进程的虚拟内存空间，线程函数的参数`args`可传递任意类型数据

* 终止线程

  **正常终止: **

  1. 线程函数`return`: 返回值作为线程的退出状态
  2. 调用`pthread_exit(void *retval)`: 显式终止线程，`retval`作为退出状态

  **异常终止:**

  1. 取消线程，通过`pthread_cancel(tid)`向线程发送取消请求，线程可注册取消处理函数`pthread_setcancelhandler`，清理资源后终止
  2. 进程退出，进程调用`exit()`，所有线程会立即终止，可能导致资源泄露

* 连接线程

  ```c
  int pthread_join(pthread_t thread, void **retval);
  ```

  用于回收可结合线程的资源，阻塞父线程直到目标线程终止，获取其退出状态`retval`

  若线程处于可结合状态且未被join，会成为僵尸线程，占用资源

* 线程分离

  分离状态的线程终止时，资源会被内核自动回收，无需`pthread_join`，适合无需同步退出状态的线程（后台守护线程）

  ```c
  // 创建分离状态
  pthread_attr_t attr;
  pthread_attr_init(&attr);
  // 设置分离状态
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED); 
  pthread_create(&tid, &attr, thread_func, NULL);
  pthread_attr_destroy(&attr);
  
  // 线程创建后，调用detach设置分离状态 
  pthread_detach(tid) 
  ```

### 线程重要属性

* 分离状态：`PTHREAD_CREATE_JOINABLE`（默认）或`PTHREAD_CREATE_DETACHED`
* 栈大小：通过`pthread_attr_setstacksize`设置线程栈大小
* 调整策略：`SCHED_FIFO`、`SCHED_RR`，配合优先级控制线程调度

### 线程同步

* **互斥锁**

  有线程访问进程空间中的公共资源时，该线程执行加锁操作，防止其他线程访问

  访问完成后解锁操作，将资源让给其他线程

  本质上互斥锁就是一个全局变量

  * **互斥锁的初始化**

    初始化`pthread_mutex_t`变量的方式有两种

    ```c
    // 使用特定的宏定义
    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    // 使用初始化函数
    pthread_mutex_t mutexNew;
    pthread_mutex_init(&mutexNew, NULL);
    ```

    区别在于，函数式创建可以自定义互斥锁的属性，对于使用malloc()函数分配动态内存的互斥锁只能通过函数式进行初始化

  * **互斥锁的加锁和解锁**

    ```c
    int pthread_mutex_lock(pthread_mutex_t* mutex);   //实现加锁
    int pthread_mutex_trylock(pthread_mutex_t* mutex);  //实现加锁
    int pthread_mutex_unlock(pthread_mutex_t* mutex);   //实现解锁
    ```

    执行`pthread_mutex_lock()`函数会使进程进入等待（阻塞）状态，直到互斥锁的得到释放

    执行`prhread_mutex_trylock()`函数不会阻塞线程，直接返沪非零数（加锁失败）

  * **互斥锁的销毁**

    ```c
    int pthread_mutex_destroy(pthread_mutex_t *mutex);
    ```

    **只有使用动态内存创建的锁需要在`free()`之前进行`pthread_mutex_destory()`方法**

* **信号量**

  类似计数器，常用在多线程同步任务中，信号量可以在当前线程任务完成后，通知别的线程

  * **二值信号量**：信号量的值只有0和1，资源锁住为0，资源可用为1
  * **计数信号量**：信号量的值在0到大于1的限制值之间，该计数表示可用的资源的个数

  **信号量的创建**

  ```c
  int sem_init(sem_t *sem, int pshared, unsigned int value);
  ```

  `sem_t *sem`：指向信号对象

  `int pshared`：指控信号量的类型，0为线程之间使用，非零为进程之间使用

  `unsigned int value`：信号量sem的初始值

  **信号量的使用**

  ```c
  int sem_post(sem_t *sem);
  ```

  将信号量的值加一

  ```c
  int sem_wait(sem_t *sem); 
  int sem_trywait(sem_t *sem);
  int sem_timedwait(sem_t *sem, const struct timespec *abs_timeout);
  ```

  * `sem_wait`阻塞式
  * `sem_trywait`非阻塞式，如果信号量的值为0，直接退出并返回错误信息
  * `sem_timedwait`超时等待，将阻塞直到信号量不为0或者超时

  **信号量的销毁**

  ```c
  int sem_destroy(sem_t *sem);
  ```

* **条件变量**

  使用方法和`sem`类似

  它允许线程在特定条件不满足时挂起等待，直到另一个线程满足条件并发送信号唤醒

  **条件变量必须和互斥锁配合使用，以避免竞态条件**

  使用`pthread_cond_t`类型并结合`pthread_mutex_t`

  线程获取互斥锁后调用`pthread_cond_wait`，函数会自动释放互斥锁并将线程挂起，等待被唤醒，**被唤醒后会自动重新获取互斥锁**

  另一个线程满足条件后，调用`pthread_cond_signal`唤醒至少一个等待线程或`pthread_cond_broadcast`唤醒所有等待线程

  **等待线程通常需要循环检查条件**

* **读写锁**

  读写锁是用来解决多个读和一个写操作同一数据的一致性问题，读操作可以共享，写操作是排他的

  * **强读者同步**：当写操作没有完成时，就可以进行读操作
  * **强写者同步**：当所有写操作都写完之后才能进行读操作

  **读写锁初始化**

  ```c
  int pthread_rwlock_init(pthread_rwlock_t *restrict rwlock, const pthread_rwlockattr_t *restrict attr);
  pthread_rwlock_t rwlock = PTHREAD_RWLOCK_INITIALIZER;
  ```

  `pthread_rwlock_t`：读写锁标识符

  `pthread_rwlockattr_t`：读写锁初始化参数

  **也可以直接使用头文件提供的宏定义**

  **读写锁销毁**

  ```c
  int pthread_rwlock_destroy(pthread_rwlock_t *rwlock);
  ```

  **获取读写锁的读锁**

  * **阻塞式**

    ```c
    int pthread_rwlock_rdlock(pthread_rwlock_t *rwlock);
    ```

  * **非阻塞式**

    ```c
    int pthread_rwlock_tryrdlock(pthread_rwlock_t *rwlock);
    ```

  **获取读写锁的写锁**

  * **阻塞式**

    ```c
    int pthread_rwlock_wrlock(pthread_rwlock_t *rwlock);
    ```

  * **非阻塞式**

    ```c
    int pthread_rwlock_trywrlock(pthread_rwlock_t *rwlock);
    ```

# Unix网络编程

## TCP/IP 5层协议

| 层次    | 层名       | 核心作用             | 常见协议 / 标准                         |
| ------- | ---------- | -------------------- | --------------------------------------- |
| 第 5 层 | 应用层     | 应用程序之间通信     | HTTP、HTTPS、FTP、DNS、DHCP、SMTP、POP3 |
| 第 4 层 | 传输层     | 端到端数据传输       | TCP、UDP                                |
| 第 3 层 | 网络层     | 寻址、路由、跨网传输 | IPv4、IPv6、ICMP（ping）、ARP           |
| 第 2 层 | 数据链路层 | 局域网内传输、帧封装 | 以太网、MAC 地址、PPP                   |
| 第 1 层 | 物理层     | 传输 0/1 比特流      | 网线、光纤、无线电、电压标准            |

## UDP

**UDP是无连接不可靠的数据报协议**

![](.\Picture\UDP协议模型.png)

* **获取socket套接字**

  ```c
  int socket(int domain, int type, int protocol);
  ```

  * `return`：成功返回一个操作新套接字的文件句柄，失败返回-1
  * `int domain`：如果是IPV4使用`AF_INET`，如果是IPV6使用`AF_INET6`
  * `int type`：`SOCK_STREAM`以TCP的方式进行网络数据传输，`SOCK_DGRAM`以UDP的方式进行网络数据传输
  * `int protocol`：对于特定的套接字类型仅支持单一协议，此时协议可指定为0

* **绑定域名信息到套接字**

  ```c
  int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
  ```

  * `返回值`：成功返回0，不成功返回-1

  * `int sockfd`：套接字文件句柄

  * `const struct sockaddr *addr`：存放本机IP地址和port端口号的结构体

    ```c
    struct sockaddr {
        sa_family_t sa_family;
        char        sa_data[14];
    }; // 已经被废
    struct sockaddr_in {
        short            sin_family;   
        unsigned short   sin_port;     
        struct in_addr   sin_addr; // 可以填INADDR_ANY，监听0.0.0.0地址，socket只绑定端口，让路由表决定ip     
        char             sin_zero[8];  
    };
    
    struct in_addr {
        unsigned long s_addr;  // load with inet_aton()
    };
    ```

  * `socklen_t addrlen`：结构体长度

* **发送数据**

  ```c
  ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
                 const struct sockaddr *dest_addr, socklen_t addrlen);
  ```

  * `renturn`：成功返回发送的字节数，失败返回-1
  * `int flags`：直接使用0，有特殊需要查看文档使用
  * `const struct sockaddr *dest_addr`：目标主机的域名信息结构体（可以为NULL）

* **接收数据**

  ```c
  ssize_t recvfrom(int sockfd, void *buf, size_t len, int flags,
                   struct sockaddr *src_addr, socklen_t *addrlen);
  ```

* **关闭套接字**

  ```c
  int close(int fd);
  ```

## TCP

TCP是一种面向连接、可靠、基于字节流的传输层通信协议

![](.\Picture\TCP三次握手.png)

![](.\Picture\TCP四次挥手.png)

**通信过程**

> **为什么需要三次握手？**
>
> 避免失效的连接请求报文段被服务端接收，导致资源浪费
>
> **半关闭状态**
>
> 第二次挥手后，通道关闭，但服务端到客户端的通道仍可用，服务端可以继续向客户端发数据，直到第三次挥手

## TCP和UDP的区别

1. TCP是面向连接的，UDP是无连接的
2. TCP是可靠的，UDP是不可靠的
3. TCP是面向字节流的，UDP是面向数据报文的
4. TCP只支持点对点通信，UDP支持一对一、一对多、多对多
5. TCP报文首部20个字节，UDP首部8个字节
6. TCP有拥塞控制机制，UDP没有
7. TCP协议下双方发送接收缓存区都有，UDP并没有意义上的发送缓冲区，但是存在接收缓冲区

## IO多路复用

`poll`是linux中IO多路复用函数，核心作用是**同时监听多个文件描述符的事件，阻塞等待其中任意一个或多个fd就绪，然后返回就绪的fd数量和状态**

```c
int poll(struct pollfd *fds, nfds_t nfds, int timeout);

struct pollfd {
    int   fd;         // 要监听的文件描述符（如套接字、标准输入、文件等）
    short events;     // 要监听的事件（输入：比如 POLLIN 表示关注“可读”）
    short revents;    // 实际发生的事件（输出：由内核填充，比如返回 POLLIN 表示该 fd 可读）
};
```

| 常量      | 含义                                             |
| --------- | ------------------------------------------------ |
| `POLLIN`  | 关注 “可读” 事件（如套接字有数据、客户端连接）   |
| `POLLOUT` | 关注 “可写” 事件（如文件 / 套接字可写入数据）    |
| `POLLERR` | 关注 “错误” 事件（由内核自动检测，无需手动设置） |
| `POLLHUP` | 关注 “挂起” 事件（如客户端断开连接）             |

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <poll.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define PORT 8888
#define MAX_FDS 2  // 要监听的 fd 数量：监听套接字 + 标准输入

int main() {
    // 1. 创建 TCP 监听套接字
    int listen_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (listen_fd == -1) {
        perror("socket failed");
        exit(1);
    }

    // 2. 绑定 IP 和端口
    struct sockaddr_in server_addr;
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);
    if (bind(listen_fd, (struct sockaddr*)&server_addr, sizeof(server_addr)) == -1) {
        perror("bind failed");
        close(listen_fd);
        exit(1);
    }

    // 3. 开始监听
    if (listen(listen_fd, 5) == -1) {
        perror("listen failed");
        close(listen_fd);
        exit(1);
    }
    printf("服务器启动，监听 8888 端口；按任意键+回车可输入指令\n");

    // 4. 初始化 pollfd 数组（监听 2 个 fd：listen_fd + stdin(0)）
    struct pollfd fds[MAX_FDS];
    // 监听 fd 0：标准输入（关注可读事件）
    fds[0].fd = 0;
    fds[0].events = POLLIN;
    fds[0].revents = 0;  // 初始化输出位为 0
    // 监听 fd 1：TCP 监听套接字（关注可读事件，即有客户端连接）
    fds[1].fd = listen_fd;
    fds[1].events = POLLIN;
    fds[1].revents = 0;

    // 5. 循环调用 poll 监听事件
    while (1) {
        // 调用 poll：永久阻塞（timeout=-1），直到有 fd 就绪
        int ready_num = poll(fds, MAX_FDS, -1);
        if (ready_num == -1) {
            perror("poll failed");
            break;
        }

        // 6. 遍历 pollfd 数组，检查哪个 fd 就绪
        for (int i = 0; i < MAX_FDS; i++) {
            // 只处理就绪的 fd（revents 非 0）
            if (fds[i].revents & POLLIN) {
                // 情况 1：标准输入就绪（用户输入）
                if (fds[i].fd == 0) {
                    char buf[1024] = {0};
                    read(0, buf, sizeof(buf)-1);
                    printf("你输入的指令：%s", buf);
                }
                // 情况 2：监听套接字就绪（有客户端连接）
                else if (fds[i].fd == listen_fd) {
                    struct sockaddr_in client_addr;
                    socklen_t client_len = sizeof(client_addr);
                    int conn_fd = accept(listen_fd, (struct sockaddr*)&client_addr, &client_len);
                    if (conn_fd == -1) {
                        perror("accept failed");
                        continue;
                    }
                    // 打印客户端信息
                    char client_ip[INET_ADDRSTRLEN];
                    inet_ntop(AF_INET, &client_addr.sin_addr, client_ip, sizeof(client_ip));
                    printf("客户端 %s:%d 已连接\n", client_ip, ntohs(client_addr.sin_port));
                    close(conn_fd);  // 示例简化：连接后直接关闭
                }
            }
        }
    }

    // 7. 收尾
    close(listen_fd);
    return 0;
}
```

## 网络抓包分析

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <linux/if_ether.h> // 以太网头结构体

// 打印数据包的十六进制内容（每16字节换行，方便分析）
void logbuf(const unsigned char *buf, int len) {
    if (len <= 0) return;
    printf("\n************捕获数据包 len=%d 字节***********\n", len);
    int i = 0;
    for (i = 0; i < len; i++) {
        printf("%02x ", buf[i]); // 加空格分隔，可读性更好
        if ((i + 1) % 16 == 0) { // 每16个字节换行（修正原逻辑）
            printf("\n");
        }
    }
    // 最后一行不足16字节时补换行
    if (i % 16 != 0) {
        printf("\n");
    }
    printf("*******************************************\n");
}

int main() {
    // 创建PF_PACKET类型的原始套接字，捕获所有以太网帧
    int sock = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
    if (sock < 0) {
        perror("创建原始套接字失败（需要root权限，运行时加sudo）");
        exit(1); // 非0退出表示异常
    }

    printf("开始抓包（按Ctrl+C停止）...\n");
    while (1) {
        char buf[1024];
        // 读取原始以太网帧数据
        int ret = read(sock, buf, sizeof(buf));
        if (ret < 0) {
            perror("read失败");
            continue;
        }
        // 打印十六进制数据包
        logbuf((unsigned char*)buf, ret);
    }

    close(sock); // 实际不会执行到这里，Ctrl+C终止
    return 0;
}
```

