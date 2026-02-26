# POSIX文件操作

## POSIX标准

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

