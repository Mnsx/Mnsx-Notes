# 处理数据

## 整型变量的选择

如果变量表示的整数值**大于16位**的最大可能值，则使用long

如果要存储的值超过20e，可使用long long

通常情况下，仅当有大型整型数组时，才有必要使用short

## 整型不同字面值输出

在默认情况下，cout以十进制格式显示整数

如果要以十六进制或八进制方式显示值，需要使用dec、hex、oct控制符，分别代表十进制、十六进制、八进制格式

```c++
#include <iostream>

using namespace std;

int main() {

    int a = 42;
    int b = 42;
    int c = 42;

    cout << "十进制: " << a << endl;
    cout << oct;
    cout << "八进制: " << b << endl;
    cout << hex;
    cout << "十六进制: " << c << endl;

    return 0;
}
```

如果需要使用hex或oct作为变量可以不声明名称空间，转而使用std::hex

## cout.put()

提供显示字符的方法，可以替代<<运算符

和使用<<运算符的区别在于：

* `cout <<`: 重载运算符，支持多种数据类型
* `cout.put()`: 成员函数，**只接受字符**

## C++转义序列的编码

![](.\Picture\C++转义序列的编码.png)

## E表示法

d.dddE+n指的是将小数点向右移动n位

d.dddE~n指的是将小数点向左移动n位

## 表达式中的类型转换

计算表达式时，将bool、char、unsigned char、signed char和short值转换为int

如果short比int短，则unsigned short类型将被转换位int，相同则转换成unsigned int

不同类型进行算术运算时，较小的类型将被转换为较大的类型

# 复杂类型

## 数组的初始化规则

只有在定义数组时才能使用初始化

不能将一个数组赋值给另一个数组

```c
int a[4] = {1, 2, 3, 5};
int b[4];
a[4] = {6, 7, 8, 9}; // not allowed
b = a; // not allowed
```

## 读取一行字符串输入

可以使用`get()`和`getline()`

`getline()`将丢弃换行符，`get()`将保留换行符

* `getline()`

  通过回车键输入的换行符确定输入结束，或者读取到指定数量的字符

  第一个参数，用来存储输入行的数组名称

  第二个参数，要读取的字符数（包括'\0')

* `get()`

  拥有多种变体，可以与getline()相同方式使用，这种情况下不会读取并丢弃换行符，二十将其保留在输入队列中

  ```c++
  #include <iostream>
  
  using namespace std;
  
  int main() {
  
      char name[50] = {0};
      cin.get(name, 10);
      cout << name;
      cin.get(); // get会将换行符保留在输入流中
      cin.get(name, 20);
      cout << name;
  
      return 0;
  }
  ```

  或者可以使用`cin.get(name, 10).get()`来避免换行符被保留的问题

  `cin.get()`只是读取一个字符

  > **为什么使用`get()`而不是`getline()`？**
  >
  > 1. 老式实现没有getline()
  > 2. get()使输入更仔细

## 空行和其他问题

* 当读取到空行时（`get()`），将设置失效位，接下来的输入将被阻断

  可以通过使用`cin.clear()`来输入输入

* 另一个潜在的问题，输入字符串可能比分配空间长，则会将多余的字符留在输入队列中，而`getline()`会设置失效位，并关闭后面的输入

* 混合输入字符串和数字

  ```c
  #include <iostream>
  
  using namespace std;
  
  int main() {
  
      char str[10] = {0};
      char add[10] = {0};
  
      cin >> str; // 123
      // 剩余的回车符被读取了，直接退出
      cin.getline(add, 10);
      cout << str;
      cout << add;
      
      return 0;
  }
  ```

  可以通过`cin.get()`读取剩余的换行符

  也可以通过`cin>>year`返回的cin对象调用`get()`方法读取剩余的换行符

## string类的使用

可以将一个string对象赋值给另一个string对象

可以适合用运算符+将两个string对象合并起来

string对象可以通过size()方法获取字符串长度

string对象会根据内容自动调整大小

## 结构体的位字段

```c++
struct torgle_register {
    
    unsigned int SN : 4; // 限制为4字节
}
```

## 分配内存和释放内存

功能类似于`malloc()`，提供需要的数据类型，new将找到一个长度合适的内存块，并返回该内存块的地址

```c++
int* pn = new int;
```

可以使用`delete()`将使用完成后的内存空间归还给内存池

可以使用new创建数组

```c++
int * p = new int[10];
```

在释放这个数组内存时，需要使用

```c++
delete [] p;
```

## 管理数据内存的方式

* **自动存储**

  自动变量是一个局部变量，其作用域为包含它的代码块

  **自动变量通常存储在栈中**

* **静态存储**

  整个程序执行期间都存在的存储方式

* **动态存储**

  程序管理一个内存池，被称为自由存储空间或堆

## 模板类vector

动态数组，可以在运行阶段设置vector对象的长度

可以在末尾附加新的数据，可以在中间插入新数据

**必须包含头文件vector**

```c++
#include <iostream>
#include <vector>

using namespace std;

int main() {

    vector<int> v;
    v = {1, 2, 3};
    cout << v[1] << endl;
}
```

## 模板类array（C++11）

array对象的长度是固定的，使用的栈内存存放数据，效率和数组相同

```c++
#include <iostream>
#include <array>

using namespace std;

int main() {

    array<int, 5> a;
    a = {1, 2, 3, 4};
    cout << a[3] << endl;
}
```

## 数组、vector、array区别

![](.\Picture\数组、vector、array对比.png)

# 函数

## 指针与const

const对指针进行声明有两种不同的定义

* const修饰的是`*pt`，意味着指针指向一个常量对象

  防止使用该指针来修改所指向的值

  ```c++
  #include <iostream>
  
  using namespace std;
  
  int main() {
  
      int age = 10;
  
      const int *p = &age;
  
      *p = 20; // 报错，无法通过指针修改所指向的值 
  
      return 0;
  }
  ```

* const直接修饰指针，将指针本身声明为常量

  防止改变指针指向的位置

## 函数指针

函数的地址是存储其机器语言代码的内存的开始地址

函数原型`double fun(int);`那么函数指针的声明就应该是`double (*p) (int);`



