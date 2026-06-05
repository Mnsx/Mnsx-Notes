### Step

Mat中的step表示**相邻两行数据起始地址之间相差多少字节**

step的主要作用是在于访问像素时，Mat内部数据时一段连续或近似连续的内存，如果需要访问`(row, col)`位置的像素

```c++
uchar* ptr = img.data + row * img.step + col * img.elemSize();
```

对于CV_8UC3

```c++
cv::Vec3b& pixel = *reinterpret_cast<cv::Vec3b*>(img.data + y * img.step + x * img.elemSize());

cv::Vec3b pixel = img.at<cv::Vec3b>(y, x);
```

**ROI中的step**

ROI每一行只是原图的行中的一段，下一行ROI的起始位置要跳到原图下一行的对应位置，而不是紧挨着前一行ROI结束的位置

**isContinuous和step**

如果一个Mat的数据是连续存储的

```c++
mat.isContinuous()； // 返回true
```

通常连续矩阵满足

```c++
mat.step == mat.cols * mat.elemSize()
```

但是对于ROI来说，返回false，因为ROI的每行之间都有跳过的原图数据

**step和step1的区别**

step的单位是字节，而step1的单位是元素通道单位，准确来说是以elemSize1为单位

```shell
img.elemSize() = 12
img.elemSize1() = 4
img.step = 4 * 12 = 48
img.step1() = 48 / 4 = 12
```

