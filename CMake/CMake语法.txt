# 单行注释

# [=[ 多行注释
	# [[ 可以使用任意数量=，但是首尾=必须相同
	# ]]
# ]=]

# 执行指令，CMake中使用空格来分割指令参数
# 指令名不区分大小写，但是约定使用小写加下划线
command(argument1 "argument2" argument3)

# CMake提供三类指令
# 项目指令：主要用于定义编译流程，在生成构建系统期间生效，管理目标、属性和依赖，这些指令直接影响最终的二进制产出
# 脚本指令：CMake本身的语法，不会直接产生二进制文件，而是用来控制逻辑流、处理字符串或操作文件，可以在CMake运行的任意阶段生效，可以在cmake -P script.cmake中运行这些指令，而不需要进行编译
# CTest指令：CMake自带的测试驱动引擎专用指令，不负责编译，只负责管理和运行测试用例，构建完成后，执行测试阶段

# CMake提供三种类型的参数
# 方括号参数 不会进行求值，并用于将多行字符串作为单个参数逐字传递给命令，包含制表符和换行符形式的空白，通常用于包含较长的文本块
message([=[multiline
	bracket
	argument
	]=])
# 引号参数 它们将展开转义序列
message("argument")
# 非引号参数
message(three;separated;arguments) # 通过;来分隔
message(a\ siglle\ argument) # 通过反斜杠将空格转移为字符串，这是一个参数

# 变量
set(Mystring1 "Text1") # 设置变量
unset(Mystring1) # 取消变量
message(${Mystring1}) # 引用变量，如果没有对应字符串，那么使用空串代替
message(${MyOuter${MyInner}}) # 会从内而外解析
# CMake提供三类变量
# 普通变量 
# 缓存变量 存储在构建书中的CMakeCache.txt文件中的变量，包含在项目配置阶段收集的信息，包括从系统和通过GUI从用户收集的信息，只存在项目中不存在于脚本
# 通过set修改，要求提供变量<type>和<docstring>值
# BOOL：一个布尔的开/关值
# FILEPATH：磁盘上文件的路径
# STRING：字符串
# INTERNAL：字符串，使用此类型会隐式添加FORCE关键字
$CACHE{} # 用于引用缓存变量
# 环境变量 生成环境中用于启动CMake进程的变量的副本，并使它们在单一的全局作用域中可用，允许通过set、unset修改，但是不会对实际的系统环境进行更改
$ENV{} # 用于引用环境变量

# 变量作用域
# 可以在set或unset末尾添加PARENT_SCOPE来更改调用父类作用域的变量
function(Inter)
	message(" > Inter: ${V}")
	set(V 3)
	# set(V 3 PARENT_SCOPE)
	message(" < Inter: ${V}")
endfunction()

function(Outer)
	message(" > Outer: ${V}")
	set(V 2)
	Inner()
	message(" < Outer: ${V}")
endfunction()

set(V 1)
message(" > Global: ${V}")
Outer()
message(" < Global: ${V}")

# 列表
# CMake会将所有元素连接成一个字符串，使用;分隔
# 创建一个列表可以使用set()或:set(myList)
# CMake提供list指令，提供大量子命令来读取、搜索、修改和排序列表
# 大部分情况下，项目中不需要使用列表

# 控制结构，分为三类，条件块、循环和定义指令
# 条件块
i(condition)
	commands
elseif(condition)
	commands
else()
	commands
endif()
# 条件支持NOT、AND和OR逻辑操作符
# 在条件中使用普通变量名等于写入${VAR}
set(VAR1 FALSE)
set(VAR2 "VAR1")
if(${VAR2}) # 结果是FALSE
# 只有当字符串等于ON, Y, YES或TRUE时才认为是布尔值true
# CMake提供操作符比较操作，EQUAL、LESS、LESS_EQUAL、GREATER和GREATER_EQUAL
# 循环
# 循环块用while()指令创建，用endwhile()关闭
while(condition)
	commands
endwhile()
# foreach块通过foreach()和endforeach()
foreach(loop_var RANGE max)
	commands
endforeach()
set(MY__LIST 1 2 3)
foreach(VAR IN LISTS MY_LIST ITEMS e f )
	message(${VAR}) # 1 2 3 e f
endforeach()
# 定义指令
# 可以使用macro()或funciton()定义自己的命令
# macro的工作方式，宏，不会调用堆栈上创建单独的条目，在宏中调用return()比函数中返回级别更高
# funtion为本地变量创建一个单独的作用域，在调用者的变量作用域中工作
# ${ARGC}：参数的数量
# ${ARGV}：所有参数的列表
# ${ARG0}...：特定索引处的实参值
# ${ARGN}：最后一个预期参数之后，由调用者传递的匿名参数列表
macro(MyMacro myVar)
	set(myVar "new value")
	message("argument: ${myVar}")
endmacro
# CMake为每个函数设置以下变量
# CMAKE_CURRENT_FUNTION
# CMAKE_CURRENT_FUNTION_LIST_DIR
# CMAKE_CURRENT_FUNTION_LIST_FILE
# CMAKE_CURRENT_FUNTION_LIST_LINE
function(MyFunction FirstArg)
message("Function: ${CMAKE_CURRENT_FUNCTION}")
message("File: ${CMAKE_CURRENT_FUNCTION_LIST_FILE}")
message("FirstArg: ${FirstArg}")
set(FirstArg "new value")
message("FirstArg again: ${FirstArg}")
message("ARGV0: ${ARGV0} ARGV1: ${ARGV1} ARGC: ${ARGC}")
endfunction()

set(FirstArg "first value")
MyFuntion("Value1" "Value2")
message("FirstArg in global scope: ${FirstArg}")

# 实用指令
# message()，将文本呢打印到标准输出，提供MODE参数，可以自定义输出的样式，并且在出现错误的情况下，可以停止代码
# FATAL_ERROR：将停止处理和生成
# SEND_ERROR：将继续处理，但跳过生成
# WARNING：继续处理
# AUTHOR_WARNING：CMake警告，继续处理
# DEPRECATION：若启用了CMAKE_ERROR_DEPRECATED或CMAKE_WARN_DEPRECATED变量将进行相应的处理
# NOTICE或默认模式：将向stderr输出一条消息
# STATUS：继续处理，建议用于用户的主要消息
# VERBOSE：继续处理，用于不是很有必要的信息
# DEBUG：继续处理，并包含项目出现问题时可能有用的详细信息
# TRACE：继续处理，并建议在项目开发期间打印项目，通常发布后删除
# include()，用于将CMake代码划分到单独的文件中，以保持内容的有序和独立性
# 提供文件名（以.cmake为扩展名），CMake尝试打开并执行，不会创建嵌套，因此对该文件的变量修改会影响调用的作用域
# 文件不存在抛出错误，除非使用optional关键字指定为可选，可以提供一个返回关键字，成功返回完整路径填充，失败则用NOTFOUND填充
include(<file|module> [OPTIONAL] [RESULT_VARIABLE <var>])
# include_guard()指令，包含有副作用的文件时，可能需要限制，以便只包含一次
# DIRECTORY将在当前目录及以下应用保护
# GLOBAL将对整个构建应用保护
include_guard([DIRECTORY|GLOBAL])
