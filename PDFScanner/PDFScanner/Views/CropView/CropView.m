//
//  CropView.m
//  ImageHandleFunc
//
//  Created by Y on 2018/10/25.
//  Copyright © 2018 Y. All rights reserved.
//

#import "CropView.h"
#import "MagnifierView.h"
#import "UIColor+Ext.h"

@interface CropView ()

@property (strong, nonatomic) UIView *topLeftView;

@property (strong, nonatomic) UIView *topRightView;

@property (strong, nonatomic) UIView *bottomLeftView;

@property (strong, nonatomic) UIView *bottomRightView;

@property (strong, nonatomic) UIView *moveView;

@property (assign, nonatomic) BOOL isMove;

@property (strong, nonatomic) MagnifierView *magnifierView;

@end

@implementation CropView

- (UIView *)topLeftView
{
    if (!_topLeftView) {
        _topLeftView = [self drawCircleView:self.topLeft];
    }
    return _topLeftView;
}

- (UIView *)topRightView
{
    if (!_topRightView) {
        _topRightView = [self drawCircleView:self.topRight];
    }
    return _topRightView;
}

- (UIView *)bottomLeftView
{
    if (!_bottomLeftView) {
        _bottomLeftView = [self drawCircleView:self.bottomLeft];
    }
    return _bottomLeftView;
}

- (UIView *)bottomRightView
{
    if (!_bottomRightView) {
        _bottomRightView = [self drawCircleView:self.bottomRight];
    }
    return _bottomRightView;
}

- (MagnifierView *)magnifierView
{
    if (!_magnifierView) {
        _magnifierView = [[MagnifierView alloc] initWithFrame:CGRectMake(0.f, 0.f, MagnifierWidth, MagnifierWidth)];
        _magnifierView.layer.cornerRadius = MagnifierWidth * 0.5f;
        _magnifierView.clipsToBounds = YES;
        _magnifierView.renderView = self.window;
    }
    return _magnifierView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHex:0x808080].CGColor);
    CGContextSetLineWidth(context, LineWidth);
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.topLeft.x, self.topLeft.y);
    CGContextAddLineToPoint(context, self.topRight.x, self.topRight.y);
    CGContextAddLineToPoint(context, self.bottomRight.x, self.bottomRight.y);
    CGContextAddLineToPoint(context, self.bottomLeft.x, self.bottomLeft.y);
    CGContextClosePath(context);
    CGContextStrokePath(context);
}

- (void)drawWithTopLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight
{
    self.topLeft = topLeft;
    self.topRight = topRight;
    self.bottomLeft = bottomLeft;
    self.bottomRight = bottomRight;
    
    [self setNeedsDisplay];
}

- (void)setTopLeft:(CGPoint)topLeft
{
    _topLeft = topLeft;
    [self addSubview:self.topLeftView];
    
    self.topLeftView.center = topLeft;
}

- (void)setTopRight:(CGPoint)topRight
{
    _topRight = topRight;
    [self addSubview:self.topRightView];
    
    self.topRightView.center = topRight;
}

- (void)setBottomLeft:(CGPoint)bottomLeft
{
    _bottomLeft = bottomLeft;
    [self addSubview:self.bottomLeftView];
    
    self.bottomLeftView.center = bottomLeft;
}

- (void)setBottomRight:(CGPoint)bottomRight
{
    _bottomRight = bottomRight;
    [self addSubview:self.bottomRightView];
    
    self.bottomRightView.center = bottomRight;
}

- (UIView *)drawCircleView:(CGPoint)point
{
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CircleWidth, CircleWidth)];
    circleView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.3f];
    circleView.center = point;
    circleView.layer.cornerRadius = CircleWidth * 0.5f;
    return circleView;
}

CGPoint legend_point;
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    self.isMove = NO;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.topLeftView.frame, point)) {
        self.moveView = self.topLeftView;
        self.isMove = YES;
        legend_point = [touch locationInView:self.topLeftView];
    }else if (CGRectContainsPoint(self.topRightView.frame, point)) {
        self.moveView = self.topRightView;
        self.isMove = YES;
        legend_point = [touch locationInView:self.topRightView];
    }else if (CGRectContainsPoint(self.bottomLeftView.frame, point)) {
        self.moveView = self.bottomLeftView;
        self.isMove = YES;
        legend_point = [touch locationInView:self.bottomLeftView];
    }else if (CGRectContainsPoint(self.bottomRightView.frame, point)) {
        self.moveView = self.bottomRightView;
        self.isMove = YES;
        legend_point = [touch locationInView:self.bottomRightView];
    }
    
    if (self.isMove) {
        //window的hidden默认为YES
        self.magnifierView.hidden = NO;
        // 坐标系转换 self点转到window上
        CGPoint wPoint = [self.window convertPoint:point fromView:self];
        self.magnifierView.center = CGPointMake(wPoint.x, wPoint.y - MagnifierWidth);
        // 设置渲染的中心点
        self.magnifierView.renderPoint = wPoint;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (!self.isMove) return;
    @autoreleasepool {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        // 转化成相对的中心
        point.x += self.moveView.frame.size.width / 2.0f - legend_point.x;
        point.y += self.moveView.frame.size.height / 2.0f - legend_point.y;
        // 限制范围
        if (point.x < LineWidth * 0.5) {
            point.x = LineWidth * 0.5;
        }
        if (point.y < LineWidth * 0.5) {
            point.y = LineWidth * 0.5;
        }
        if (point.x > self.frame.size.width - LineWidth * 0.5) {
            point.x = self.frame.size.width - LineWidth * 0.5;
        }
        if (point.y > self.frame.size.height - LineWidth * 0.5) {
            point.y = self.frame.size.height - LineWidth * 0.5;
        }
        
//        if (point.x < self.moveView.frame.size.width / 2.0f) {
//            point.x = self.moveView.frame.size.width / 2.0f;
//        }
//        if (point.y < self.moveView.frame.size.height / 2.0f) {
//            point.y = self.moveView.frame.size.height / 2.0f;
//        }
//
//        if (point.x > self.frame.size.width - self.moveView.frame.size.width / 2.0f) {
//            point.x = self.frame.size.width - self.moveView.frame.size.width / 2.0f;
//        }
//        if (point.y > self.frame.size.height - self.moveView.frame.size.height / 2.0f) {
//            point.y = self.frame.size.height - self.moveView.frame.size.height / 2.0f;
//        }
        
        self.moveView.center = point;
        if (self.moveView == self.topLeftView) {
            self.topLeft = point;
        }else if (self.moveView == self.topRightView) {
            self.topRight = point;
        }else if (self.moveView == self.bottomLeftView) {
            self.bottomLeft = point;
        }else if (self.moveView == self.bottomRightView) {
            self.bottomRight = point;
        }
        [self setNeedsDisplay];
        
        // window的hidden默认为YES
        self.magnifierView.hidden = NO;
        // 坐标系转换 self点转到window上
        CGPoint wPoint = [self.window convertPoint:point fromView:self];
        self.magnifierView.center = CGPointMake(wPoint.x, wPoint.y - MagnifierWidth);
        // 设置渲染的中心点
        self.magnifierView.renderPoint = wPoint;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (self.magnifierView) {
        // 用完一定要记得置nil。
        self.magnifierView = nil;
    }
}

/**
 重写hitTest方法，去监听“⭕️"按钮，目的是为了让超出的部分点击也有反应
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.isHidden == NO)
    {
        CGPoint tlp = [self convertPoint:point toView:self.topLeftView];
        CGPoint trp = [self convertPoint:point toView:self.topRightView];
        CGPoint blp = [self convertPoint:point toView:self.bottomLeftView];
        CGPoint brp = [self convertPoint:point toView:self.bottomRightView];
        
        // 判断如果这个新的点是在⭕️上，那么处理点击事件最合适的view就是⭕️
        if ([self.topLeftView pointInside:tlp withEvent:event]) {
            return self.topLeftView;
        } else if ([self.topRightView pointInside:trp withEvent:event]) {
            return self.topRightView;
        } else if ([self.bottomLeftView pointInside:blp withEvent:event]) {
            return self.bottomLeftView;
        } else if ([self.bottomRightView pointInside:brp withEvent:event]) {
            return self.bottomRightView;
        } else {//如果点不在按钮身上，直接让系统处理就可以了
            return [super hitTest:point withEvent:event];
        }
    } else {
        return [super hitTest:point withEvent:event];
    }
}

@end
