# Lambda表达式

## 捕获参数列表

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

## 传入参数列表

匿名函数支持外部传入参数

```c++
int answer = [](int x){cout << "answer = " << answer;}(100);
```

## 可选参数

`specifiers`说明符，**值传递捕获的外部变量在默认情况下只读**，在Lambda表达式中添加`mutable`关键字，**但是修改的是副本的值**

```c++
auto a = [value](int x) mutable {value++};
```

## 避免默认捕获模式

C++11有两种默认捕获模式：按引用或按值

**按引用捕获会导致闭包包含指涉到局部变量的引用，或者指涉到定义Lambda表达式的作用域内的形参引用**

一旦由Lambda表达式所创建的闭包越过了，局部变量或形参的作用域，那么闭包内的引用就会空悬

C++14提供了在Lambda表达式中使用auto声明的能力

**按值捕获指针时，在Lambda表达式中会创建闭包中持有的这个指针的副本，但是无法阻止外部可能会对这个指针进行delete，导致空悬**

**捕获只能针对于在创建Lambda表达式的作用域内可见的非静态局部变量（包括形参）**，而当前类的的成员变量不包括在内

```c++
class Widget {
    int divisor;
    
    void addFilter() const;
};

void Widget::addFilter() const {
    
    filters.emplace_back(
    	
        [=](int value) {
            
            return vlaue % divisor == 0;
        }
    )
}
```

而其的divisor其实是this->divisor，默认的按值捕获，捕获了当前函数所在对象的this指针

所以说Lambda闭包的存活与它含有this指针副本的Widget对象的生命周期绑定在了一起

```c++
using filterContainer = std::vector<std::fucntion<bool(int)>>;

FilterContainer filters;

void doSomeWork() {
    
    auto pw = std::make_unique<Widget>();
    
    pw->addFilter();
}
```

上述代码通过make_unique创建了Widget对象，即一个指向Widget指针的筛选函数，然后将这个函数加入到filters中，不过当doSomeWork结束之后，Widget对象即std::unique_ptr就会被销毁，这就导致filter中包含一个空悬指针的元素

在C++14中，捕获成员变量的更好方式是使用广义Lambda捕获，对于广义捕获而言，没有默认捕获模式一说

```c++
void Widget::addFilter() const {
    
    filters.emplace_back(
    	[divisor = divisor](int value) {
            
            return value % divisor == 0;
        }
    )
}
```

## 初始化捕获

C++14能够提供通过移动将对象加入闭包的操作，而C++11只有近似达成移动捕获行为的做法，这种做法的名称就是初始化捕获

初始化捕获，可以做到C++11的捕获形式能够做到的所有事情，**唯一不能表示的就是默认捕获模式**

在C++11中实现C++14初始化捕获得效果

```c++
class IsValAndArch {
    
public:
    using DataType = std::unique_ptr<Widget>;
    
    explicit IsValAndArch(DataType&& ptr) : pw(std::move(ptr)) {}
    
    bool operator()() const {
        
        return pw->isValidated() && pw->isArchived();
    }
    
private:
    DataType pw;
};

auto func = IsValAndArch(std::make_unique<Widget>());
```

如果在C++11中费曜使用Lambda表达式，按移动捕获

1. 把需要捕获得对象移动到`std::bind`产生得对象中
2. 给到Lambda表达式一个指涉到想要捕获对象的引用

```c++
std::vector<double> data;

auto func = std::bind([](const std::vector<double>& data) {
    
    ...
}, std::move(data));
```

和Lambda表达式相似的，std::bind也能够生成函数对象，可以称为返回的函数对象为绑定对象，**std::bind的第一个实参是个可调用对象，接下来的所有实参都是传给该对象的值**

绑定对象含有传递给std::bind所有实参的副本，对于每个左值实参都绑定对象内的对应的对象内对其实施的是复制构造，而对于每个右值实参，实施的是移动构造，这样就绕过了C++11无法将右值到闭包的限制
