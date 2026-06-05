### ROI

ROI感兴趣区域，表示从一张图像或矩阵中截取的某一块区域

```c++
cv::Rect roiRect(100, 50, 200, 100);
cv::Mat roi = img(roiRect);
```

**ROI不是设拷贝，而是共享原图数据**

ROI是创建一个新的Mat头部，让它指向原图的一部分数据

如果需要独立的ROI需要先使用clone函数进行深拷贝再提取ROI

**ROI越界报错**

如果原图无法达到ROI的长宽，那么就会触发断言错误，安全写法可以先检查

```c++
cv::Rect roiRect(100, 50, 200, 150);

if ((roiRect & cv::Rect(0, 0, img.cols, img.rows)) == roiRect) {
    cv::Mat roi = img(roiRect);
}
```

ROI主要应用于局部处理，如只对图像中一块区域做灰度化、模糊、绘制、复制等操作

除了使用`cv::Rect`还可以使用行列范围取ROI

```c++
cv::Mat roi = img(cv::Range(50, 200), cv::Range(100, 300));
```

**Range的结束位置不包含**

