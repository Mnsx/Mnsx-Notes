# POSIX文件操作

## 文件操作函数

* open函数

  ```c
  int fd = open(const char *pathname, int flags, mode_t mode);
  ```

  用于“打开文件”，意味着获得这个文件的访问句柄

  * **句柄（file descriptor）fd**

    标准输入 0，标准输出 1，标准出错 2

    每打开一个文件就会返回句柄来操作这个文件，一般是从3开始

    `close(fd)`句柄就会返回给操作系统

  * 参数1（pathname）

    要打开的文件路径

  * **参数2（flags）**

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

  * **参数3（mode）**

    如果文件被新建，可以使用mode指定其权限

    使用8进制数进行设置，例如777、751，但是会因为掩码收到影响

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

  用于移动偏移文件光标

  * **参数3（whence）**

    偏移量计算的位置

    | 参数     | 含义                     |
    | -------- | ------------------------ |
    | SEEK_SET | 从文件开始计算偏移量     |
    | SEEK_CUR | 从当前光标位置计算偏移量 |
    | SEEK_END | 从文件结束位置计算偏移量 |

* close函数

  ```c
  int close(int fd);
  ```

```c
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main() {

    // int fd = open("./test.txt", O_RDWR | O_CREAT);
    // printf("fd = %d\n", fd);

    int fd = open("./test.txt", O_RDWR | O_CREAT, 777);

    if (fd < 0) {
        // 打开失败
        return -1;
    }

    // char buf[1024] = {0};
    // int readSize = read(fd, buf, sizeof(buf));
    // printf("read data: %s\tread size: %d\tbuffer size: %ld\n", buf, readSize, sizeof(buf));

    // char buf[1024] = "Goodbye world!";
    // int writeSize = write(fd, buf, sizeof(buf));
    // printf("write size: %d\tbuffer size: %ld\n", writeSize, sizeof(buf));

    char buf[10] = {0};
    read(fd, buf, sizeof(buf));
    
    // SEEK_SET
    lseek(fd, 4, SEEK_SET);

    // SEEK_CUR
    // lseek(fd, -3, SEEK_CUR);

    // SEEK_END
    // lseek(fd, -10, SEEK_END);

    read(fd, buf, sizeof(buf));
    printf("read data: %s\n", buf);

    close(fd);

    return 0;
}
```

# 进程

## 进程概览

进程是操作系统进行资源分配和调度的基本单位

每个进程结束并被系统回收后，其PID可被重新分配给新的进程

遵循内核的延迟重用算法以避免PID冲突

## 父子进程关系

通过调用`fork()`系统调用，一个父进程可以创建一个新的子进程

子进程继承了父进程的大部分属性

子进程的PPID字段记录着父进程的PID

## 特殊情况进程

* **孤儿进程**: 当父进程在其子进程之前终止时，子进程会编程孤儿进程，此时操作系统会自动将其领养给`init进程（PID为1的特殊进程）`，使孤儿进程得以正常完成生命周期

* **僵尸进程**: **若子进程比父进程先结束，而父进程未正确处理子进程的终止状态**，子进程的状态信息就会滞留在系统中，形成僵尸进程。僵尸进程虽不占用CPU资源，但其在进程表中的条目仍会消耗一定的内存资源，**因此应当及时清理僵尸进程**

  > **可以使用`wait()`或者`waitpid()`来解决僵尸进程的问题**
  >
  > ```c
  > #include <sys/types.h>
  > #include <unistd.h>
  > #include <stdio.h>
  > 
  > int main() {
  > 
  >     int pid = fork();
  > 
  >     if (pid > 0) {
  >         wait();
  >         // waitpid(pid);
  >         // 如果不使用wait()那么子进程将成为僵尸进程
  >         sleep(5);
  >         printf("父进程pid: %d\n", getpid());
  >     } else if (pid == 0) {
  >         printf("子进程pid: %d\t父进程pid: %d\n", getpid(), getppid());
  >     } else {
  >         return -1;
  >     }
  > 
  >     return 0;
  > }
  > ```

## 进程创建

使用`fork()`函数创建一个与调用进程几乎完全相同的子进程

调用成功后**它会在父进程中返回子进程的PID**，在子进程中返回0，如果调用失败，则返回-1

子进程和父进程在内存布局上有所不同：它们共用代码区域，但是**数据、堆栈和其他私有空间则被复制并映射到独立的物理内存区域**

```c
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>

int main() {

    // 创建一个子进程
    int pid = fork();

    // fork返回给父进程子进程pid
    if (pid > 0) {
        // 父进程进入
        printf("父进程pid: %d\n", getpid());
    // fork返回给子进程0
    } else if (pid == 0) {
        // 子进程进入
        printf("子进程pid: %d\t父进程pid: %d\n", getpid(), getppid());
    } else {
        // 创建子进程错误
        return -1;
    }

    return 0;
}
```

## 守护进程

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

  ```c
  #include <unistd.h>
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <fcntl.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <signal.h>
  
  void create_daemonize() {
  
      pid_t pid;
  
      // 设置文件权限掩码
      umask(0);
  
      // 创建子进程并让父进程退出
      pid = fork();
      if (pid < 0) {
  
          exit(-1);
      } else if (pid > 0) {
  
          exit(0);
      }
  
      // 创建新的会话
      if (setsid() < 0) {
  
          exit(-1);
      }
  
      // 改变工作目录
      if (chdir("/") < 0) {
  
          exit(-1);
      }
  
      // 关闭标准文件描述符
      close(STDIN_FILENO);
      close(STDOUT_FILENO);
      close(STDERR_FILENO);
  
      // 重定向到/dev/null 根据需求进行
      // open("/dev/null", O_RDONLY);
      // open("/dev/null", O_RDWR);
      // open("/dev/null", O_RDWR);
  }
  
  int main() {
  
      create_daemonize();
  
      // 守护进程执行逻辑
      while (1) {
  
          sleep(10);
      }
  
      return 0;
  }
  ```

* **守护进程日志管理**

  > **使用文件输入输出创建日志文件**
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
  >     pid_t pid;
  >     umask(0);
  >     pid = fork();
  >     if (pid < 0) {
  > 
  >         exit(-1);
  >     } else if (pid > 0) {
  > 
  >         exit(0);
  >     }
  >     if (setsid() < 0) {
  > 
  >         exit(-1);
  >     }
  >     if (chdir("/") < 0) {
  > 
  >         exit(-1);
  >     }
  >     close(STDIN_FILENO);
  >     close(STDOUT_FILENO);
  >     close(STDERR_FILENO);
  > }
  > 
  > // 获取时间字符串
  > static void getLocalTime(char *buf, int size) {
  > 
  >     time_t now = time(NULL);
  >     
  >     struct tm *res = localtime(&now);   
  > 
  >     strftime(buf, size, "[%Y-%m-%d %H:%M:%S]", res);
  > }
  > 
  > // 通过文件读写完成日志功能
  > void startLog() {
  > 
  >     int fd;
  >     char buf[1024] = {0};
  > 
  >     fd = open("/home/mnsx/daemonize.log", O_WRONLY | O_CREAT | O_APPEND, 0644);
  >     if (fd < 0) {
  > 
  >         return;
  >     }
  > 
  >     getLocalTime(buf, sizeof(buf));
  > 
  >     // 日志内容
  >     char msg[100] = "Daemonize is running!\n";
  > 
  >     strncat(buf, msg, sizeof(buf) - strlen(buf));
  > 
  >     if (write(fd, buf, strlen(buf)) < 0) {
  > 
  >         close(fd);
  >         return;
  >     }
  > 
  >     close(fd);
  > 
  >     sleep(10);
  > }
  > 
  > void preLog() {
  > 
  >     int fd = open("/home/mnsx/daemonize.log", O_WRONLY | O_CREAT | O_APPEND, 0644);
  >     if (fd != -1) {
  >         char startup_msg[] = "=== Daemonize started ===\n";
  >         write(fd, startup_msg, strlen(startup_msg));
  >         close(fd);
  >     }
  > }
  > 
  > int main() {
  > 
  >     createDaemonize();
  >     // 启动日志文件
  >     preLog();
  >     while (1) {
  > 
  >         // 开启日志功能
  >         startLog();
  >     }
  >     return 0;
  > }
  > ```

  大多数守护进程都使用BSD的syslog进行日志管理

  ![](E:\Documents\Notes\Picture\BSD-syslog工作原理.png)

* **守护进程规范**
  1. 如果守护进程使用锁文件，那么该文件通常存储在`/var/run`目录中，**通常守护进程需要超级用户权限才能在此目录下创建文件**，锁文件的名字通常为name.pid，其中name是该守护进程的名字
  2. 如果守护进程支持配置选项，那么配置文件通常存放在`/etc`目录下，文件名通常为name.conf
  3. 守护进程可用命令行启动，但通常他们是系统初始化脚本之一启动的
  4. 当配置文件被修改后，通常需要重启守护进程才能生效，**可以使用SIGHUP信号**，当守护进程接收该信号，重新读取配置文件

## exec函数家族

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

## system函数介绍

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


## 进程通信

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

  

  
