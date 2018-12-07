//
//  UIImageView+ContentFrame.m
//  PDFScanner
//
//  Created by Y on 2018/11/13.
//  Copyright © 2018 Y. All rights reserved.
//

#import "UIImageView+ContentFrame.h"

@implementation UIImageView (ContentFrame)

- (CGRect)contentFrame
{
    CGSize imageSize = self.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(self.bounds) / imageSize.width, CGRectGetHeight(self.bounds) / imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width * imageScale, imageSize.height * imageScale);
    CGRect imageFrame = CGRectMake(0.5f * (CGRectGetWidth(self.bounds) -scaledImageSize.width), 0.5f * (CGRectGetHeight(self.bounds) -scaledImageSize.height), scaledImageSize.width, scaledImageSize.height);
    return imageFrame;
}

- (CGFloat)contentScale
{
    CGSize imageSize = self.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(self.bounds) / imageSize.width, CGRectGetHeight(self.bounds)/imageSize.height);
    return imageScale;
}

@end
