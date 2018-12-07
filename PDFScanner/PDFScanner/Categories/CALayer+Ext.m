//
//  CALayer+Ext.m
//  PDFScanner
//
//  Created by Y on 2018/12/6.
//  Copyright © 2018 Y. All rights reserved.
//

#import "CALayer+Ext.h"

@implementation CALayer (Ext)

- (void)shake
{
    CABasicAnimation*animation=[CABasicAnimation animationWithKeyPath:@"transform"];
    //持续时间
    animation.duration = 0.1;
    //抖动次数
    animation.repeatCount = MAXFLOAT;
    //反极性
    animation.autoreverses = YES;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.transform, -0.2f, 0.f, 0.f, 0.2f)];
    animation.toValue= [NSValue valueWithCATransform3D:CATransform3DRotate(self.transform,0.2f, 0.f, 0.f, 0.2f)];
    [self addAnimation:animation forKey:@"wiggle"];
    
}

@end
