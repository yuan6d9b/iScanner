//
//  MagnifierView.m
//  ImageHandleFunc
//
//  Created by Y on 2018/10/25.
//  Copyright © 2018 Y. All rights reserved.
//

#import "MagnifierView.h"

@implementation MagnifierView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        //为了居于状态条之上
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.layer.delegate = self;
        //保证和屏幕读取像素的比例一致
        self.layer.contentsScale = [[UIScreen mainScreen] scale];
    }
    return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    //提前位移半个长宽的坑
    CGContextTranslateCTM(ctx, self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    CGContextScaleCTM(ctx, 1.5, 1.5);
    //再次位移后就可以把触摸点移至self.center的位置
    CGContextTranslateCTM(ctx, -1 * self.renderPoint.x, -1 * self.renderPoint.y);
    
    [self.renderView.layer renderInContext:ctx];
}

- (void)setRenderPoint:(CGPoint)renderPoint
{
    _renderPoint = renderPoint;
    
    [self.layer setNeedsDisplay];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    self.layer.borderColor = hidden ? [[UIColor clearColor] CGColor] : [[UIColor lightGrayColor] CGColor];
}

@end
