### inRange作用

`cv::inRange()`的作用是判断每个像素是否在指定范围内，结果会生成一张二值mask图

**函数原型**

```c++
cv::inRange(src, lowerb, upperb, dst);
```

src表示输入图像，lowerb表示下界，upperb表示上界，dst表示输出二值图

> 红色有两段Hue，Hue是环形，在OpenCV中是0-179，红色在0和179附近