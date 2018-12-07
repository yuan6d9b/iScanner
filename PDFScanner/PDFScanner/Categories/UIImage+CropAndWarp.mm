//
//  UIImage+CropAndWarp.m
//  PDFScanner
//
//  Created by Y on 2018/11/13.
//  Copyright © 2018 Y. All rights reserved.
//

#import "UIImage+CropAndWarp.h"

@implementation UIImage (CropAndWarp)

+ (UIImage *)cropAndWarpImage:(UIImage *)image :(CGPoint)topLeft :(CGPoint)topRight :(CGPoint)bottomLeft :(CGPoint)bottomRight
{
    UIImage *orientationImage = image;
    
    CGPoint tl = topLeft;
    CGPoint tr = topRight;
    CGPoint br = bottomRight;
    CGPoint bl = bottomLeft;
    
    CGFloat w1 = sqrt(pow(br.x - bl.x , 2) + pow(br.x - bl.x, 2));
    CGFloat w2 = sqrt(pow(tr.x - tl.x , 2) + pow(tr.x - tl.x, 2));
    
    CGFloat h1 = sqrt(pow(tr.y - br.y , 2) + pow(tr.y - br.y, 2));
    CGFloat h2 = sqrt(pow(tl.y - bl.y , 2) + pow(tl.y - bl.y, 2));
    
    CGFloat maxWidth = (w1 < w2) ? w1 : w2;
    CGFloat maxHeight = (h1 < h2) ? h1 : h2;
    
    cv::Point2f src[4], dst[4];
    src[0].x = tl.x;
    src[0].y = tl.y;
    src[1].x = tr.x;
    src[1].y = tr.y;
    src[2].x = br.x;
    src[2].y = br.y;
    src[3].x = bl.x;
    src[3].y = bl.y;
    
    dst[0].x = 0;
    dst[0].y = 0;
    dst[1].x = maxWidth - 1;
    dst[1].y = 0;
    dst[2].x = maxWidth - 1;
    dst[2].y = maxHeight - 1;
    dst[3].x = 0;
    dst[3].y = maxHeight - 1;
    
    cv::Mat undistorted = cv::Mat(cvSize(maxWidth,maxHeight), CV_8UC4);
    cv::Mat original;
    UIImageToMat(orientationImage, original);
    
    // 透视变换
    cv::warpPerspective(original, undistorted, cv::getPerspectiveTransform(src, dst), cvSize(maxWidth, maxHeight));
    // 拿到透视变换图片
    UIImage *warpImage = MatToUIImage(undistorted);
    original.release();
    undistorted.release();
    
    return warpImage;
}

@end
