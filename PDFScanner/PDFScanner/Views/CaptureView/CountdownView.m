//
//  CountdownView.m
//  ImageHandleFunc
//
//  Created by Y on 2018/11/2.
//  Copyright © 2018 Y. All rights reserved.
//

#import "CountdownView.h"
#import "POP.h"

@interface CountdownView ()

@property (assign, nonatomic) CGFloat preValue;

@property (assign, nonatomic) CGFloat currentValue;

@end

@implementation CountdownView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 设置背景颜色
        self.backgroundColor = [UIColor clearColor];
        // 设置正常状态
        [self setupNormalState];
        // 设置倒计时view
        //        [self setupCountdownState];
        
        self.preValue = 0.0;
        self.currentValue = 0.0;
    }
    return self;
}

CGFloat lineWidth = 4.f;

CGFloat padding = 6.f;

- (void)setupNormalState
{
    // 圆环
    CAShapeLayer *cirque = [CAShapeLayer layer];
    CGFloat cirqueRadius = (CGRectGetWidth(self.bounds) - lineWidth) * 0.5f;
    CGRect cirqueRect = CGRectMake(lineWidth * 0.5f, lineWidth * 0.5f, cirqueRadius * 2, cirqueRadius * 2);
    cirque.path = [UIBezierPath bezierPathWithRoundedRect:cirqueRect cornerRadius:cirqueRadius].CGPath;
    cirque.strokeColor = [UIColor whiteColor].CGColor;
    cirque.fillColor = [UIColor clearColor].CGColor;
    cirque.lineWidth = lineWidth;
    cirque.strokeEnd = 1.0f;
    [self.layer addSublayer:cirque];
    
    // 实心圆
    CAShapeLayer *circle = [CAShapeLayer layer];
    CGFloat circleRadius = CGRectGetWidth(self.bounds) * 0.5f - lineWidth - padding ;
    CGRect circleRect = CGRectMake(lineWidth + padding, lineWidth + padding, circleRadius * 2, circleRadius * 2);
    circle.path = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:circleRadius].CGPath;
    circle.strokeColor = nil;
    circle.fillColor = [UIColor whiteColor].CGColor;
    circle.strokeEnd = 1.0f;
    [self.layer addSublayer:circle];
}

- (void)setupCountdownState
{
    CGFloat cirqueRadius = (CGRectGetWidth(self.bounds) - lineWidth) * 0.5f;
    CGRect cirqueRect = CGRectMake(lineWidth * 0.5f, lineWidth * 0.5f, cirqueRadius * 2, cirqueRadius * 2);
    // 背景
    CAShapeLayer *background = [CAShapeLayer layer];
    background.path = [UIBezierPath bezierPathWithRoundedRect:cirqueRect cornerRadius:cirqueRadius].CGPath;
    background.strokeColor = [UIColor lightGrayColor].CGColor;
    background.fillColor = [UIColor clearColor].CGColor;
    background.lineWidth = lineWidth;
    background.strokeEnd = 1.0f;
    [self.layer addSublayer:background];
    // 动态圆环
    CAShapeLayer *cirque = [CAShapeLayer layer];
    cirque.path = [UIBezierPath bezierPathWithRoundedRect:cirqueRect cornerRadius:cirqueRadius].CGPath;
    cirque.strokeColor = [UIColor whiteColor].CGColor;
    cirque.fillColor = [UIColor clearColor].CGColor;
    cirque.lineWidth = lineWidth;
    cirque.strokeEnd = 0.f;
    [self.layer addSublayer:cirque];
    
    static int num = -1;
    
    POPAnimatableProperty *property = [POPAnimatableProperty propertyWithName:@"layerStrokeAnimationValue" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            CGFloat value = values[0];
            [obj setStrokeEnd:value];
            
            self.preValue = self.currentValue;
            self.currentValue = value;
            
            if (self.preValue == self.currentValue) {
                num++;
                if (self.countdownBlock) self.countdownBlock(num);
                if (num == 3) {
                    CAShapeLayer *layer = (CAShapeLayer *)obj;
                    [layer removeFromSuperlayer];
                    self.state = ViewStateNormal;
                    if (self.endBlock) self.endBlock();
                    num = -1;
                    self.preValue = 0.f;
                    self.currentValue = 0.f;
                }
            }
        };
    }];
    
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.duration = 1.0f;
    animation.repeatCount = 3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.property = property;
    [cirque pop_addAnimation:animation forKey:@"layerStrokeAnimation"];
}

- (void)setState:(ViewState)state
{
    _state = state;
    
    self.layer.sublayers = nil;
    
    switch (state) {
        case ViewStateNormal:
            [self setupNormalState];
            break;
        default:
            [self setupCountdownState];
            break;
    }
}

@end
