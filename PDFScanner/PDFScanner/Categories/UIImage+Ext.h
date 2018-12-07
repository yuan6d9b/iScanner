//
//  UIImage+Ext.h
//  PDFScanner
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Ext)

/** 不受tintcolor影响 */
- (UIImage *)alwaysOriginal;

/** 受tintcolor影响 */
- (UIImage *)alwaysTemplate;

/** 根据颜色绘制图片 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/** 获取旋转后的图片 */
+ (UIImage *)saveRotatedImageWithAngle:(CGFloat)rotationAngle OriginalImage:(UIImage *)originalImage;

/** 解决拍照旋转90度问题 */
+ (UIImage *)imageWithRightOrientation:(UIImage *)aImage;

/** 压缩图片 */
+ (UIImage *)imageCompress:(UIImage*)image;

/** 添加沉底水印 */
+ (UIImage *)addWaterImageToImage:(UIImage *)image;

/** 二值化 */
- (UIImage *)binaryImage;

/** 灰度 */
- (UIImage *)grayImage;

@end
