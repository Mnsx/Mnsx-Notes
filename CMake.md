# 快速上手

## 项目构成

**Project**

* **bin**：主要用于存放可执行文件
* **build**：主要用于存放编译过程中产生的文件
* **include**：主要用于存放开发过程中的头文件
* **src**：主要用于存放开发过程中的源文件
## 基础编写

基于项目过程可以简单的编写一个基础版的`CMakeLists.txt`文件

```cmake
# 指定最低可以使用的版本号
cmake_minimum_required(VERSION 3.10)

# 项目名称
project(Test)

# 将bin目录设置为可执行文件的输出路径
set (EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)

# 将src目录下的所有源文件保存在SRC_LIST变量中
aux_source_directory(src SRC_LIST)

# 指定头文件路径
include_directories(intclude)

# 添加需要被执行的文件并指定输出文件名称
add_executable(main ${SRC_LIST})
```

* `EXECUTABLE_OUTPUT_PATH`：可执行文件的输出路径
* `${PROJECT_SOURCE_DIR}`：CMake提供的变量，表示CMakeFile所在的文件路径