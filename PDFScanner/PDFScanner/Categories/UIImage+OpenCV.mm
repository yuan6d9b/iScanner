//
//  UIImage+OpenCV.m
//  PDFScanner
//
//  Created by Y on 2018/11/14.
//  Copyright © 2018 Y. All rights reserved.
//

#import "UIImage+OpenCV.h"

@implementation UIImage (OpenCV)

/**
 图像增强 拉普拉斯锐化
 
 @return 增强锐化后图片
 */
- (UIImage *)sharpening
{
    cv::Mat src_F2D, dst_F2D;
    UIImageToMat(self, src_F2D);
    cv::Mat kernel = (cv::Mat_<float>(3, 3) << 0, -1, 0, -1, 5, -1, 0, -1, 0);
    /// 使用滤波器
    filter2D(src_F2D, dst_F2D, src_F2D.depth(), kernel);
    UIImage *img = MatToUIImage(dst_F2D);
    return img;
}

/**
 灰度图片
 
 @return 灰度图片
 */
- (UIImage*)gray
{
    // 1.将iOS的UIImage转成c++图片
    cv::Mat mat_image_gray;
    UIImageToMat(self, mat_image_gray);
    // 2. 将c++彩色图片转成灰度图片
    // 参数一：数据源
    // 参数二：目标数据
    // 参数三：转换类型
    cv::Mat mat_image_dst;
    cvtColor(mat_image_gray, mat_image_dst, cv::COLOR_BGRA2GRAY);
    // 3.灰度 -> 可显示的图片
    cvtColor(mat_image_dst, mat_image_gray, cv::COLOR_GRAY2BGR);
    // 4. 将c++处理之后的图片转成iOS能识别的UIImage
    return MatToUIImage(mat_image_gray);
}

@end
