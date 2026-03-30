# auto

## 优先使用auto

> `std::function`是C++11标准库中的一个模板，它把函数指针的思想推广
>
> 函数指针只能涉及到函数，而`std::function`可以指涉任何可调用对象
>
> ```c++
> std::function<void a(int b, double c)> func;
> ```
>
> 闭包是指一个函数记住并访问它所在的作用域，即使这个函数在它声明的作用域外执行
>
> 就好比于，Lambda函数，指定捕获外部变量，这就是一种闭包的实现

使用`auto`声明的、存储着一个闭包的变量和该闭包是同一类型，从而它需要的内存量应该也和闭包相同

而使用`std::function`声明的、存储着一个闭包变量是std::funciton的一个实例，所以它应该占有固定的内存量，而**这个内存量可能对于存储的闭包而言并不一定够用**，这种情况下std::function的构造函数**就会分配堆上的内存来存储闭包**

结论就是，std::function对象一般会比使用auto声明的变量多使用内存

auto除了避免未初始化的变量和罗嗦的变量声明，并且可以直接持有闭包外，它还能解决一种问题

```c++
std::unordered_map<std::string, int> m;

for (const std::pair<std::string, int> & p : m) {}
```

上述代码问题在于，**`std::unordered_map`键值部分是const**，所以编译器就需要将每个对象做一次复制，以去除const的修饰，生成一个符合要求类型的临时对象，这是一个非常不应该的消耗，而是用auto就可以避免这种情况

## auto类型异常问题

> std::vector\<bool>的operator[]的返回值并不是容器中的一个元素的引用，**它返回的是std::vector<bool\>::reference类型的对象**（这是个嵌套在std::vector<bool\>里的类）
>
> 使用这个类的原因，是因为对std::vector<bool\>做了特化处理，用了一种压缩形式表示其持有的bool元素，这样每个bool元素可以用一个bit来表示
>
> 这样的做法会导致operator[]应该返回一个bool&，但是C++中禁止bit的引用，**因为单个的bit没有单独的存储地址，不符合C++引用的底层逻辑**，所以编译器对std::vector<bool\>::reference做了一个向bool的隐式类型转换

因为上述缘故，所以使用auto申明的变量去接收一个std::vector\<bool>类型的operator[]就会出现，auto表示的值与期望的值不同的情况，这就是代理类的实例

而大部分的隐式代理类就和auto冲突，所以在使用auto声明变量时，应该尽量避免接收隐式代理类

在发现auto自动推导的类型与所期望的类型不同时，可以主动进行一次强制类型转换如

```c++
auto ifConn = static_cast<bool>(features(w)[s]);
```
