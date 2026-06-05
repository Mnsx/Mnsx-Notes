### imread

```c++
cv::Mat img = cv::imread("resource/test.jpg");

cv::Mat img = cv::imread("resource/test.jpg", cv::IMREAD_COLOR);
```

第二个参数控制读取方式

| 参数                   | 含义                             |
| ---------------------- | -------------------------------- |
| `cv::IMREAD_COLOR`     | 读取为 3 通道 BGR 彩色图，默认值 |
| `cv::IMREAD_GRAYSCALE` | 读取为单通道灰度图               |
| `cv::IMREAD_UNCHANGED` | 按原始格式读取，包括 alpha 通道  |
| `cv::IMREAD_ANYDEPTH`  | 保留原图深度，例如 16-bit 图像   |
| `cv::IMREAD_ANYCOLOR`  | 尽量保留图像颜色格式             |