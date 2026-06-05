### Channel

在Mat中，channels表示，每一个矩阵元素里包含多少数值分量，对于图像而言表示，每个像素有几个颜色/数据通道

Mat的完整type由两部分组成：**depth + channels**

```shell
CV_8UC3 = CV_8U + C3
```

表示8位无符号整数，3通道

channels决定一个像素如何访问

* 单通道图像

  ```c++
  cv::Mat gray(480, 640, CV_8UC1);
  uchar value = gray.at<uchar>(100, 200);
  ```

* 三通道图像

  ```c++
  cv::Mat gray(480, 640, CV_8UC1);
  uchar value = gray.at<uchar>(100, 200);
  ```

* 三通道float图像

  ```c++
  cv::Mat m(480, 640, CV_32FC3);
  cv::Vec3f value = m.at<cv::Vec3f>(100, 200);
  ```

`elemSize()`表示一个完整元素占多少字节，包含通道

`elemSize1()`表示单个通道占多少字节

**通道的拆分和合并**

```c++
std::vector<cv::Mat bgr;
cv::split(img, bgr);
```

如果img是CV_8UC3，那么bgr.size就是3，每个代表一个通道

```c++
cv::Mat merged;
cv::merge(bgr, merged)
```