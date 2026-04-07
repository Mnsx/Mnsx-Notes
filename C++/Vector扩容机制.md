

# Vector 底层实现

## 数据结构

```c++
struct _Vector_impl_data
{
    pointer _M_start;
    pointer _M_finish;
    pointer _M_end_of_storage;
}
```

vector 的本质核心就是三个指针

* `start` ：指向数组头
* `finish`：指向当前最后一个元素的下一个位置
* `end_of_storage`：指向整块申请到的内存的最末尾

函数 `size()` 就是通过 finish - start 获取的，而函数 `capacity()` 就是通过 end_of_storage - start 获取的

**为了降低空间配置时的速度成本，vector实际配置的大小可能比客户端需求量更大一些，已备可能的扩充**

通过者三个迭代器，可以轻易提供很多容器所需技能

```c++
_GLIBCXX_NODISCARD _GLIBCXX20_CONSTEXPR
    iterator
    begin() _GLIBCXX_NOEXCEPT
{ return iterator(this->_M_impl._M_start); }

_GLIBCXX_NODISCARD _GLIBCXX20_CONSTEXPR
    iterator
    end() _GLIBCXX_NOEXCEPT
{ return iterator(this->_M_impl._M_finish); }

_GLIBCXX_NODISCARD _GLIBCXX20_CONSTEXPR
    size_type
    size() const _GLIBCXX_NOEXCEPT
{ return size_type(this->_M_impl._M_finish - this->_M_impl._M_start); }

_GLIBCXX_NODISCARD _GLIBCXX20_CONSTEXPR
    size_type
    capacity() const _GLIBCXX_NOEXCEPT
{ return size_type(this->_M_impl._M_end_of_storage
                   - this->_M_impl._M_start); }

_GLIBCXX_NODISCARD _GLIBCXX20_CONSTEXPR
    bool
    empty() const _GLIBCXX_NOEXCEPT
{ return begin() == end(); }

_GLIBCXX_NODISCARD _GLIBCXX20_CONSTEXPR
    reference
    operator[](size_type __n) _GLIBCXX_NOEXCEPT
{
    __glibcxx_requires_subscript(__n);
    return *(this->_M_impl._M_start + __n);
}

_GLIBCXX_NODISCARD _GLIBCXX20_CONSTEXPR
    reference
    front() _GLIBCXX_NOEXCEPT
{
    __glibcxx_requires_nonempty();
    return *begin();
}

_GLIBCXX_NODISCARD _GLIBCXX20_CONSTEXPR
    reference
    back() _GLIBCXX_NOEXCEPT
{
    __glibcxx_requires_nonempty();
    return *(end() - 1);
}
```

## 迭代器

vector 是一个连续线性空间，因为 vector 的迭代器所需的操作行为，普通指针都天生具备，所以无论 vector 的元素类型，普通指针都可以作为 vector 的迭代器

vector 支持随机存取，而普通指针也有这样的能力，所以 vctor 提供的是 `Random Access Iterators`

```c++
template<typename _Tp, typename _Alloc = std::allocator<_Tp> >
class vector : protected _Vector_base<_Tp, _Alloc>
{
    typedef _Vector_base<_Tp, _Alloc>			_Base;
    typedef typename _Base::pointer			pointer;
    typedef __gnu_cxx::__normal_iterator<pointer, vector> iterator;
    // ...
}
```

这里声明迭代器的部分，拆分来看

* `__gnu_cxx`：这里是 GCC 特有的命名空间，里面存放的标准库的内部实现细节
* `__normal_iterator`：这是一个**类模板**，是一个包装器
* `<pointer, vector>`：这是传给包装盒的两个参数
  * `pointer`：在 vector 的定义里，它通常就是 T*
  * `vector`：指的是这个迭代器的使用者

使用包装器的原因

* **区分迭代器和原生指针**
* **满足迭代器规范**
* **方便调试和保护**

`__normal_iterator`的定义，它的内部只有一个成员变量

```c++
template<typename _Iterator, typename _Container>
class __normal_iterator
{
    protected:
    _Iterator _M_current; // 表示就是Pointer
}
```

## 构造和内存管理

```c++
typedef typename __gnu_cxx::__alloc_traits<_Alloc>::template
rebind<_Tp>::other _Tp_alloc_type;
```

上面是现在 C++ 的分配器实现，上述代码的含义就是，将传入的分配器，强制转成专门分配 _Tp 的分配器，并将它存入 _Vector_impl 中

而分配内存的代码如下

```c++
_Alloc_traits::allocate(_M_impl, __n);
```

vector 提供许多 constructors，其中一个允许指定空间大小和初值

```c++
_GLIBCXX20_CONSTEXPR
    vector(size_type __n, const value_type& __value,
           const allocator_type& __a = allocator_type())
    : _Base(_S_check_init_len(__n, __a), __a)
    { _M_fill_initialize(__n, __value); }

_GLIBCXX20_CONSTEXPR
    void
    _M_fill_initialize(size_type __n, const value_type& __value)
{
    this->_M_impl._M_finish =
        std::__uninitialized_fill_n_a(this->_M_impl._M_start, __n, __value,
                                      _M_get_Tp_allocator());
}

template<typename _ForwardIterator, typename _Size, typename _Tp,
typename _Allocator>
    _GLIBCXX20_CONSTEXPR
    _ForwardIterator
    __uninitialized_fill_n_a(_ForwardIterator __first, _Size __n,
                             const _Tp& __x, _Allocator& __alloc)
{
    _ForwardIterator __cur = __first;
    __try
    {
        typedef __gnu_cxx::__alloc_traits<_Allocator> __traits;
        for (; __n > 0; --__n, (void) ++__cur)
            __traits::construct(__alloc, std::__addressof(*__cur), __x);
        return __cur;
    }
    __catch(...)
    {
        std::_Destroy(__first, __cur, __alloc);
        __throw_exception_again;
    }
}
```

这行的关键就在与 __traits::construct 它的作用是，告诉编译器，在指向的地址上用，给定的模板，构造一个新对象

当使用 `push_back()` 将新元素插入 vector 尾端时，该函数首先检查是否还有备用空间，如果有就直接在备用空间上构造，并调整迭代器，是vector变大，如果没有备用空间，就扩充

```C++
const size_type __len =
    _M_check_len(size_type(1), "vector::_M_realloc_insert");
pointer __new_start(this->_M_allocate(__len));
pointer __new_finish(__new_start);
```

* `_M_check_len`：决定新的内存空间的大小，**通常是2倍**
* `_M_allocate`：向系统申请一块原始内存，这个内存上没有对象，只有地址

```c++
_Alloc_traits::construct(this->_M_impl,
                         __new_start + __elems_before,
                         #if __cplusplus >= 201103L
                         std::forward<_Args>(__args)...);
```

**底层代码并不是先将旧的数据迁移，而是先把新插入的元素构造出来**

存放的位置就是新内存中对应的索引位置，即 `__new_start + __elemes_before`

这样实现的原因是，如果构建新元素失败，**旧数据不会被修改**

**旧数据迁移**主要分为两种方式

```c++
if _GLIBCXX17_CONSTEXPR (_S_use_relocate())
{
    __new_finish = _S_relocate(__old_start, __position.base(),
                               __new_start, _M_get_Tp_allocator());

    ++__new_finish;

    __new_finish = _S_relocate(__position.base(), __old_finish,
                               __new_finish, _M_get_Tp_allocator());
}
```

这是优化版本，如果数据类型是简单的（如，int 或指针），它会直接调用 `_S_relocate` ，底层类似 `memcpy` ，瞬间完成

```c++
else
    #endif
{
    __new_finish
        = std::__uninitialized_move_if_noexcept_a
        (__old_start, __position.base(),
         __new_start, _M_get_Tp_allocator());

    ++__new_finish;

    __new_finish
        = std::__uninitialized_move_if_noexcept_a
        (__position.base(), __old_finish,
         __new_finish, _M_get_Tp_allocator());
}

template<typename _InputIterator, typename _ForwardIterator,
typename _Allocator>
    _GLIBCXX20_CONSTEXPR
    inline _ForwardIterator
    __uninitialized_move_if_noexcept_a(_InputIterator __first,
                                       _InputIterator __last,
                                       _ForwardIterator __result,
                                       _Allocator& __alloc)
{
    return std::__uninitialized_copy_a
        (_GLIBCXX_MAKE_MOVE_IF_NOEXCEPT_ITERATOR(__first),
         _GLIBCXX_MAKE_MOVE_IF_NOEXCEPT_ITERATOR(__last), __result, __alloc);
}

#define _GLIBCXX_MAKE_MOVE_IF_NOEXCEPT_ITERATOR(_Iter) \
  std::__make_move_if_noexcept_iterator(_Iter)
```

这是标准版的迁移，主要使用调用 `std::__uninitialized_move_if_noexcept_a`

数据迁移的策略，**如果类有 `noexcept` 的移动构造函数，就是用移动操作，否则，为了安全会选择使用拷贝**，主要是通过宏定义 `_GLIBCXX_MAKE_MOVE_IF_NOEXCEPT_ITERATOR` 实现的这个判断

而数据迁移的具体实现是通过两段式搬运，**先是搬运插入点之前的旧数据，然后搬运插入点之后的旧数据**

```c++
std::_Destroy(__old_start, __old_finish, _M_get_Tp_allocator());
_GLIBCXX_ASAN_ANNOTATE_REINIT;
_M_deallocate(__old_start,
              this->_M_impl._M_end_of_storage - __old_start);
```

* `_Destroy`：依次调用就内存里每个对象的析构函`

```c++
this->_M_impl._M_start = __new_start;
this->_M_impl._M_finish = __new_finish;
this->_M_impl._M_end_of_storage = __new_start + __len;
```

最后更新 vector 内部的三个核心指针

```c++
__catch(...)
{
    if (!__new_finish)
        _Alloc_traits::destroy(this->_M_impl,
                               __new_start + __elems_before);
    else
        std::_Destroy(__new_start, __new_finish, _M_get_Tp_allocator());
    _M_deallocate(__new_start, __len);
    __throw_exception_again;
}
```

而这段代码保证了，如果迁移失败，旧数据依旧能够安全