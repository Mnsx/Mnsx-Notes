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

![](D:\Document\Notes\2026\Picture\C++转义序列的编码.png)

## E表示法

d.dddE+n指的是将小数点向右移动n位

d.dddE~n指的是将小数点向左移动n位

## 表达式中的类型转换

计算表达式时，将bool、char、unsigned char、signed char和short值转换为int

如果short比int短，则unsigned short类型将被转换位int，相同则转换成unsigned int

不同类型进行算术运算时，较小的类型将被转换为较大的类型



