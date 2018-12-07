//
//  RectangleView.m
//  PDFScanner
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#import "RectangleView.h"

@implementation RectangleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawEdgeWithTopLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGAffineTransform  transform = CGAffineTransformIdentity;
        transform = CGAffineTransformScale(transform, self.frame.size.width, - self.imageSize.height * self.frame.size.width / self.imageSize.width);
        transform = CGAffineTransformTranslate(transform, 0, - 1);
        
        self.topLeft = CGPointApplyAffineTransform(topLeft , transform);
        self.topRight = CGPointApplyAffineTransform(topRight , transform);
        self.bottomLeft = CGPointApplyAffineTransform(bottomLeft , transform);
        self.bottomRight = CGPointApplyAffineTransform(bottomRight , transform);
        
        [self setNeedsDisplay];
    });
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!self.imageSize.height && !self.imageSize.width) {
        
        CGContextClearRect(context, self.bounds);
        
        return;
    }
    
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    UIColor * color = [UIColor colorWithRed:4 / 255.0 green:51 / 255.0 blue:1 alpha:0.5];
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.topLeft.x, self.topLeft.y);
    CGContextAddLineToPoint(context, self.topRight.x, self.topRight.y);
    CGContextAddLineToPoint(context, self.bottomRight.x, self.bottomRight.y);
    CGContextAddLineToPoint(context, self.bottomLeft.x, self.bottomLeft.y);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

@end
