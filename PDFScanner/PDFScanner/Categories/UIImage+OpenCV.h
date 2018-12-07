//
//  UIImage+OpenCV.h
//  PDFScanner
//
//  Created by Y on 2018/11/14.
//  Copyright © 2018 Y. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#endif

#import <UIKit/UIKit.h>

@interface UIImage (OpenCV)

/** 图像增强 拉普拉斯锐化 */
- (UIImage *)sharpening;

/** 灰度图片 */
- (UIImage*)gray;

@end
