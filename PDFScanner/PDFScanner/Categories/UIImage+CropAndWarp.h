//
//  UIImage+CropAndWarp.h
//  PDFScanner
//
//  Created by Y on 2018/11/13.
//  Copyright © 2018 Y. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#endif

#import <UIKit/UIKit.h>

@interface UIImage (CropAndWarp)

+ (UIImage *)cropAndWarpImage:(UIImage *)image :(CGPoint)topLeft :(CGPoint)topRight :(CGPoint)bottomLeft :(CGPoint)bottomRight;

@end
