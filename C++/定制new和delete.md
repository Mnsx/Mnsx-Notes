# 定制new和delete

## new-handler

当`operator new`抛出异常以反映未获满足的内存需求之前，它会先调用一个**客户指定的错误处理函数**，`new-handler`

通过调用`set_new_handler`函数可以声明一个`new-handler`

```c++
typedf void (*new_handler) ();
new_handler set_new_handler(new_handler p) throw();
```

`set_new_handler`的参数是个指针，指向`operator new`无法分配足够内存时改被调用的函数，其返回值也是个指针，**指向`set_new_handler`被调用前被替换的那个`new-handler`函数**

当`operator new`无法满足内存申请时，**它会不断调用`new-handler`函数**，直到找到足够内存

所以一个设计良好的`new-handler`函数应该: 

* **让更多内存可以被使用**

  实现这个策略的一个做法是，程序一开始执行就分配一大块内存，而后`new-handler`第一次调用，将它们释放给程序使用

* **安装另一个`new-hadler`**

  如果目前的`new-handler`无法获取更多可用内存，或者它直到另一个`new-handler`有这个能力，那么这个`new-handler`用另一个替换自己

  或者，**令`new-handler`修改影响自己行为的`static`、`namespace`、`global`数据**，保证下一次调用执行不同的策略

* **卸除`new-handler`**

  将`nullptr`传入`set_new_handler`，`operator new`会在内存分配不成功时抛出异常

* **抛出`bad_alloc`异常**

  这样的异常不会被`operator new`捕捉，因此会被传播到内存寻求处理

* **不返回，通常调用`abort`或`exit`**

C++允许在类中提供自定义的`set_new_handler`和`operator new`，通**过`set_new_handler`指定类专属的`new-handler`，至于`operator new`则取保在分配类对象的过程中用类专属的`new-handler`替换全局的处理器**

```c++
class A {
private:
    static new_handler curretHandler;
public:
    static new_handler set_new_handler(new_handler p) throw ();
    static void * operator new(size_t size) throw(bad_alloc)
};

new_handler A::currentHandler = 0; // null
new_handler A::set_new_handler(new_handler p) throw() {
    new_handler oldHandler = currentHandler;
    currentHandler = p;
    return oldHandler;
}
void * A：：operator new(size_t size) throw (bad_alloc) {
    NewHandlerHodler h(set_new_handler(curretHandler));
    return ::operator new(size);
}
```

**使用`new_handler`时应当使用RAII资源管理器来包装，保证在使用结束后会被通过析构函数自动释放**

可以直接使用的`set_new_handler`模板类

```c++
// 声明
template<typename T>
class NewHandlerSupport {
private:
    static std::new_handler currentHandler;
public:
    static std::new_handler set_new_handler(std::new_handler p) throw();
    static void * operator new(std::size_t size) throw(std::bad_alloc);
};

// 实现
template<typename T>
std::new_handler NewHandlerSupport<T>::set_new_handler(std::new_handler p) throw() {
    std::new_handler oldHandler = currentHandler;
    currentHandler = p;
    return oldHandler;
}
template<typename T>
void * NewHandlerSupport<T>::operator new(std::size_t size) throw(std::bad_alloc) {
    NewHandlerHolder h(std::set_new_handelr(currentHandler));
    return ::operator new(size);
}
// 默认实现
template<typename T>
std::new_handler NewHandlerSupport<T>::currentHandler = 0;
```

## new和delete替换时机

替换编译器的`operator new`或`operator delete`的原因

* **用来检测运用上的错误**

  各种编写错误可能导致**数据`overruns`（写入点在分配区块尾端之后）或`underruns`（写入点在分配区块起点之前**
  
  如果自定义一个`operator new`，**便可以超额分配内存，以额外空间防止特定的`byte patterns`（即签名）**
  
  `operator delete`便可以检查上述签名是否原封不动，来判断是否发生了`overruns`或者`underruns`，`operator delete`可以记录这个问题以及发生问题的指针
  
* **为了强化效能**

  默认的`operator new`和`operator delete`主要用于一般目的，他需要解决各种情况

  默认的实现必须考虑碎片化问题，这最终会导致程序无法满足大区块内存需求

* **为了收集使用上的统计数据**

  >  自定义`operator new`和`operator delete`可以收集到，软件如何使用讴歌其动态内存，分配区块的大小分布如何，寿命分布如何，更倾向于FIFO还是LIFO或者是随机分配归还，运行形态是否随时间改变，所能使用的最大动态分配量是多少

* **为了弥补默认分配器中的非最佳齐位**

  许多计算机体系结构要求特定的类型必须放在特定的内存地址上，必须x86,如果是8-byte齐位，其访问速度就会快很多

* **为了将相关对象集中**

  如果某些数据结构会被一起使用，**那么为此数据结构创建另一个`heap`**，就能够在处理这些数据时将内存页错误的频率降到最低

* **为了获得非传统行为**

  如果想要分配和归还**共享内存**，但是这个行为只能在C中讴歌进行操作，就可以通过自定义`operator new`的方法，让C API批上C++的外壳

## 编写new/delete的规范

在继承的情况下，如果子类继承了父类的`operator new`，可能会出现问题，所以在正常情况下，应该将内存申请量错误的调用行为改为标准`operator new`

```c++
void * Base::operator new(std::size_t size) throw(std::bad_alloc) {
    if (size != sizeof(Base)) {
        return ::operator new(size);
    }
}
```

在重载`operator new[]`时，需要知道唯一需要做的就是**分配一块未加工内存**，因为无法判断对象的大小，因为如果是继承而来的父类，可能由于多态指向的是子类对象

C++保证**删除`nullptr`永远安全**

```c++
void operator delete(void * a) throw () {
    if (a == 0) return;
    ...
}
```

删除中继承情况就简单很多，只需要 **多加一个检查删除数量的动作**，如果出现删除大小有误的情况，直接将删除行为转交给`::operator delete`

```c++
void operator delete(void * a) throw () {
    if (a == 0) return;
    if (size != sizeof(a)) {
        ::operator delete(a);
        return;
    }
    ...
}
```

## new和delete必须同时重写

如果`operator new`接受的参数除了一定会有的`size_t`之外还有其他的，那么这个便是所谓的`placement new`

众多的`placement new`中特别有用的是一个**接受一个指针指向对象该被构造之处**

```c++
void * operator new(std::size_t, ...) throw();
```

如果内存分配成功，但是构造函数抛出异常，运行期系统有责任取消`operator new`的分配并恢复旧观，然后运行期系统无法直到真正调用的`operator new`如何运行，因此无法取消分配和恢复旧观，**运行期系统寻找参数个数和类型都与`operator new`相同的`operator delete`**

如果运行期系统不知道如何取消并恢复原先对`placement new`的调用，就会什么都不做，所以重写`new`的同时也要重写`delete`，但是**如果没有在构造函数中抛出异常，那么就会调用正常形式的`operator delete`而不是`placement delete`**

声明的`placement new`和`placement delete`可能会掩盖正常的`global`形式，同样的子类实现的`placement`可能会掩盖全局和父类的，**所以如果要自定义`operator new`需要考虑名称掩盖问题**