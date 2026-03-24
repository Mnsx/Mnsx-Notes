# Lambda表达式

### 捕获参数列表

捕获的额外部变量列表，通过逗号分隔，可进行值传和引用传捕获

```c++
class LambdaTest {
public:
    void test1(int input) {
        int value = 10;
        auto a1 = [](int x) {};
        auto a2 = [value](int x) {};
        auto a3 = [this](int x) {};
        auto a4 = [&value](int x) {};
        auto a5 = [=](int x) {}; // 值传递所有可访问的外部变量
        auto a6 = [&](int x) {}; // 引用传递所有可访问的外部变量
    }
}
```

### 传入参数列表

匿名函数支持外部传入参数

```c++
int answer = [](int x){cout << "answer = " << answer;}(100);
```

### 可选参数

`specifiers`说明符，**值传递捕获的外部变量在默认情况下只读**，在Lambda表达式中添加`mutable`关键字，**但是修改的是副本的值**

```c++
auto a = [value](int x) mutable {value++};
```