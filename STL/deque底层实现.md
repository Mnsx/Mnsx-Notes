# deque底层实现

## 数据结构

deque 允许常数时间内对起头端进行元素的插入或移除操作，deque 没有所谓容量观念，**因为它是动态的以分段连续空间组合而成的，随时可以增加一段新的空间并链接**

deque 提供 `Ramdon Access Iterator`，但它的迭代器并不是普通指针，**因此除非必要，应尽量选择 vector 而非 deque**，如果需要对 deque 进行排序操作，应该将 deque 复制到一个 vector，vector 排序之后，再复制回 deque

deque的最大任务是，将分段的定量连续空间上，维护其整体连续的假象，并提供随机存取的接口，而实现的代价就是复杂的迭代器架构

**deque 采用一块所谓的 map（非 STL 中的 map容器）作为主控**

```c++
template<typename _Tp, typename _Alloc>
class _Deque_base
{
    typedef _Tp*					_Ptr;
    typedef const _Tp*				_Ptr_const;
    
    // ...

    typedef typename iterator::_Map_pointer _Map_pointer;

    struct _Deque_impl_data
    {
        _Map_pointer _M_map;
        size_t _M_map_size;
        iterator _M_start;
        iterator _M_finish;
    };
};
```

* `_M_map`表示的是一个**指向指针数组的指针**（`T**`)，其中的每一个元素都指向一个固定大小的连续内存块，真正的数据存在连续内存块中
* `_M_ma_size`表示 Map 数组本身的大小，当 deque 元素存放不了现有的 Node 时，且 Map 数组也装满时，deque 就会给Map扩容
* `_M_start` 和 `_M_finish`分别指向第一个元素和最后一个元素，**deque 的迭代器非常重（通常占32字节），因为不仅要记录当前元素的位置，还要记录它所属的 Node，以及 Node 的边界**

## 迭代器

```c++
template<typename _Tp, typename _Ref, typename _Ptr>
struct _Deque_iterator
{
    #if __cplusplus < 201103L
    typedef _Deque_iterator<_Tp, _Tp&, _Tp*>		   iterator;
    typedef _Deque_iterator<_Tp, const _Tp&, const _Tp*> const_iterator;
    typedef _Tp*					   _Elt_pointer;
    typedef _Tp**					   _Map_pointer;
    // ...

    static size_t _S_buffer_size() _GLIBCXX_NOEXCEPT
    { return __deque_buf_size(sizeof(_Tp)); }

    typedef std::random_access_iterator_tag	iterator_category;
    typedef _Tp				value_type;
    typedef _Ptr				pointer;
    typedef _Ref				reference;
    typedef size_t				size_type;
    typedef ptrdiff_t				difference_type;
    typedef _Deque_iterator			_Self;

    _Elt_pointer _M_cur;
    _Elt_pointer _M_first;
    _Elt_pointer _M_last;
    _Map_pointer _M_node;
}
```

当声明处 deque 的迭代器时，这个迭代器内部就包含了四个变量

* `_Elt_poniter _M_cur`

  真正的工作迭代器，当解引用时，返回的就是这个指针指向的当前元素

* `_Elt_pointer _M_firtst`

  标记当前所在内存块的起始边界

* `_Elt_pointer _M_last`

  标记当前所在内存块的结束边界

* `_Map_pointer _M_node`

  它指向 `_M_map` 中的某个位置，通过这个指针，迭代器可以获取当前所在内存块位置

```c++
typedef std::random_access_iterator_tag	iterator_category;
```

这段代码的功能是，当调用萃取器获取当前迭代器类型时，欺骗萃取器，返回是随机访问迭代器

当 `_M_cur` 触碰到边界时，就会发生时空跳跃，调用内部的 `_M_set_node`，它是通过 `_M_node + 1`获取下一个内存块，再将 `_M_first` 和 `_M_last` 重新指向新的内存块的头部和尾部，最后再把`_M_cur` 放到新的内存块的开头

```c++
    static size_t _S_buffer_size() _GLIBCXX_NOEXCEPT
    { return __deque_buf_size(sizeof(_Tp)); }

    __deque_buf_size(size_t __size)
    { return (__size < _GLIBCXX_DEQUE_BUF_SIZE
              ? size_t(_GLIBCXX_DEQUE_BUF_SIZE / __size) : size_t(1)); }
```

这个函数用来决定缓冲区大小，通过调用 `__deque_buf_size(sizeof(_Tp))`，`_GLIBCXX_DEQUE_BUF_SIZE`通常被硬编码为512字节

* **元素很小，小于512时**

  那么就是使用 `512 / sizeof(T)` 公式，其返回值就是存放的个数

* **元素很大**

  直接返回1，那么就是一个数据块只能存放一个元素

deque维护了两个迭代器，通过`begin()`和`end()`传回，这两个迭代器事实上一直保持在deque内，名为`start`和`finish`

```c++
void
    _M_set_node(_Map_pointer __new_node) _GLIBCXX_NOEXCEPT
{
    _M_node = __new_node;
    _M_first = *__new_node;
    _M_last = _M_first + difference_type(_S_buffer_size());
}

_Self&
    operator+=(difference_type __n) _GLIBCXX_NOEXCEPT
{
    const difference_type __offset = __n + (_M_cur - _M_first);
    if (__offset >= 0 && __offset < difference_type(_S_buffer_size()))
        _M_cur += __n;
    else
    {
        const difference_type __node_offset =
            __offset > 0 ? __offset / difference_type(_S_buffer_size())
            : -difference_type((-__offset - 1)
                               / _S_buffer_size()) - 1;
        _M_set_node(_M_node + __node_offset);
        _M_cur = _M_first + (__offset - __node_offset
                             * difference_type(_S_buffer_size()));
    }
    return *this;
}
```

## 内存管理

在外层的类模板定义中，默认使用标准库的 std::allocator

```c++
template<typename _Tp, typename _Alloc = std::allocator<_Tp> >
class deque : protected _Deque_base<_Tp, _Alloc>
{}
```

这里的deque实际上继承自`_Deque_base`的基类，**STL的惯用手法是把内存管理和业务逻辑区分开，内存分配的声明就在这个基类中**

```c++
template<typename _Tp, typename _Alloc>
class _Deque_base
{
    protected:
    // 萃取器，用来同意获取Allocator的属性
    typedef __gnu_cxx::__alloc_traits<_Tp_alloc_type>	 _Alloc_traits;

    typedef _Tp*					_Ptr;
    typedef const _Tp*				_Ptr_const;

    // 负责分配_M_map里的指针数组
    typedef typename _Alloc_traits::template rebind<_Ptr>::other
        _Map_alloc_type;
    typedef __gnu_cxx::__alloc_traits<_Map_alloc_type> _Map_alloc_traits;

    typedef _Alloc		  allocator_type;
}
```

当使用`std::deque<int>`时，编译器默认给你`std::allocator<int>`，这个分配器只能分配int类型，当deque需要扩容`_M_map`时，他需要申请的是充满指针的数组，所以**必须使用`rebind`重绑定机制把`std::allocator<int>`变成`std::allocator<int*>`**，然后用这个新的分配器申请内存

```c++
explicit
    deque(size_type __n, const value_type& __value = value_type(),
          const allocator_type& __a = allocator_type())
    : _Base(__a, _S_check_init_len(__n, __a))
    { _M_fill_initialize(__value); }

_Deque_base(const allocator_type& __a, size_t __num_elements)
    : _M_impl(__a)
    { _M_initialize_map(__num_elements); }

template<typename _Tp, typename _Alloc>
void
_Deque_base<_Tp, _Alloc>::
_M_initialize_map(size_t __num_elements)
{
    const size_t __num_nodes = (__num_elements / __deque_buf_size(sizeof(_Tp))
                                + 1);

    this->_M_impl._M_map_size = std::max((size_t) _S_initial_map_size,
                                         size_t(__num_nodes + 2));
    this->_M_impl._M_map = _M_allocate_map(this->_M_impl._M_map_size);

    _Map_pointer __nstart = (this->_M_impl._M_map
                             + (this->_M_impl._M_map_size - __num_nodes) / 2);
    _Map_pointer __nfinish = __nstart + __num_nodes;

    __try
    { _M_create_nodes(__nstart, __nfinish); }
    __catch(...)
    {
        _M_deallocate_map(this->_M_impl._M_map, this->_M_impl._M_map_size);
        this->_M_impl._M_map = _Map_pointer();
        this->_M_impl._M_map_size = 0;
        __throw_exception_again;
    }

    this->_M_impl._M_start._M_set_node(__nstart);
    this->_M_impl._M_finish._M_set_node(__nfinish - 1);
    this->_M_impl._M_start._M_cur = _M_impl._M_start._M_first;
    this->_M_impl._M_finish._M_cur = (this->_M_impl._M_finish._M_first
                                      + __num_elements
                                      % __deque_buf_size(sizeof(_Tp)));
}
```

上述是创建要给deque需要进行的流程，他会调用函数去创建`_M_map`

```c++
const size_t __num_nodes = (__num_elements / __deque_buf_size(sizeof(_Tp))
                            + 1);
```

根据`__deque_buf_size`计算出一个Node能够装的元素个数，然后计算出所需的Node个数

```c++
this->_M_impl._M_map_size = std::max((size_t) _S_initial_map_size,
                                     size_t(__num_nodes + 2));
```

在使用计算出的结果时，最后进行了+2，这就是deque能够O(1)时间在头尾插入的原因

* `_S_initial_map_size`通常是8
* **它会在前后都流出空位，这样头插和尾插时，都不需要进行扩容操作，直接在空位挂载新的Node即可**

```c++
_Map_pointer __nstart = (this->_M_impl._M_map
                         + (this->_M_impl._M_map_size - __num_nodes) / 2);
```

**deque会将所需的Node从中间开始（居中对齐）**，原因就是因为是双端队列，所以要保证能够左右两边给相等的预留空间

```c++
this->_M_impl._M_start._M_set_node(__nstart);
this->_M_impl._M_finish._M_set_node(__nfinish - 1);
this->_M_impl._M_start._M_cur = _M_impl._M_start._M_first;
this->_M_impl._M_finish._M_cur = (this->_M_impl._M_finish._M_first
                                  + __num_elements
                                  % __deque_buf_size(sizeof(_Tp)));
```

最后，代码设置了分别指向第一个Node和最后一个Node的最后一个元素的下一个位置的两个迭代器`start`和`finish`

```c++
void
    push_back(const value_type& __x)
{
    if (this->_M_impl._M_finish._M_cur
        != this->_M_impl._M_finish._M_last - 1)
    {
        _Alloc_traits::construct(this->_M_impl,
                                 this->_M_impl._M_finish._M_cur, __x);
        ++this->_M_impl._M_finish._M_cur;
    }
    else
        _M_push_back_aux(__x);
}
```

deque在进行尾插时，会判断预留空间是否足够，如果不够则会调用`_M_push_back_aux(__x)`扩充`_M_map`的空间

```c++
template<typename _Tp, typename _Alloc>
void
deque<_Tp, _Alloc>::
_M_push_back_aux(const value_type& __t)
{
    if (size() == max_size())
        __throw_length_error(
        __N("cannot create std::deque larger than max_size()"));

    _M_reserve_map_at_back();
    *(this->_M_impl._M_finish._M_node + 1) = this->_M_allocate_node();
    __try
    {
        this->_M_impl.construct(this->_M_impl._M_finish._M_cur, __t);
        #endif
        this->_M_impl._M_finish._M_set_node(this->_M_impl._M_finish._M_node
                                            + 1);
        this->_M_impl._M_finish._M_cur = this->_M_impl._M_finish._M_first;
    }
    __catch(...)
    {
        _M_deallocate_node(*(this->_M_impl._M_finish._M_node + 1));
        __throw_exception_again;
    }
}
```

上述代码就是进行动态挂载的逻辑

```c++
if (size() == max_size())
    __throw_length_error(
    __N("cannot create std::deque larger than max_size()"));
```

首先会判断是否已经达到系统允许的极限内存，**申请资源前，先判断是否合法**

```c++
_M_reserve_map_at_back();
```

检查Map指针数组的最后一个各自里是否还有位置，如果Map数组也已经满了，那么就会今昔你个重新分配，**这保证了后续操作不会出现越界的问题**

```c++
*(this->_M_impl._M_finish._M_node + 1) = this->_M_allocate_node();
```

调用分配器，申请一个新的Node，将新的内存指针存入当前Node的下一个槽位，此时的`_M_finish`还没有进入新的Node中

```c++
this->_M_impl.construct(this->_M_impl._M_finish._M_cur, __t);
#endif
this->_M_impl._M_finish._M_set_node(this->_M_impl._M_finish._M_node
                                    + 1);
this->_M_impl._M_finish._M_cur = this->_M_impl._M_finish._M_first;
```

这段代码就是deque能够维持连续性幻觉的核心

1. 在旧Node的最后一个可用位置构造对象
2. 调用`_M_set_node`，让finish迭代器更新自己的指针

```c++
void
    pop_back() _GLIBCXX_NOEXCEPT
{
    __glibcxx_requires_nonempty();
    if (this->_M_impl._M_finish._M_cur
        != this->_M_impl._M_finish._M_first)
    {
        --this->_M_impl._M_finish._M_cur;
        _Alloc_traits::destroy(_M_get_Tp_allocator(),
                               this->_M_impl._M_finish._M_cur);
    }
    else
        _M_pop_back_aux();
}
```

如果移除元素后，当前的Node缓冲区中没有元素，那么就会调用`_M_pop_baok_aux()`，去删除Node

```c++
template <typename _Tp, typename _Alloc>
void deque<_Tp, _Alloc>::
_M_pop_back_aux()
{
    _M_deallocate_node(this->_M_impl._M_finish._M_first);
    this->_M_impl._M_finish._M_set_node(this->_M_impl._M_finish._M_node - 1);
    this->_M_impl._M_finish._M_cur = this->_M_impl._M_finish._M_last - 1;
    _Alloc_traits::destroy(_M_get_Tp_allocator(),
                           this->_M_impl._M_finish._M_cur);
}
```
