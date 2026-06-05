### clone和copyTo区别

* **调用**

  ```c++
  cv::Mat dst = src.clone();
  src.copyTo(dst);
  ```

* **返回**

  `clone()`返回一个新的Mat

  `copyTo()`拷贝到已有Mat

* **支持mask**

  copyTo支持mask，而clone不支持这种选择性复制