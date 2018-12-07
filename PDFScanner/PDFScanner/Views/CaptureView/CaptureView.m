//
//  CaptureView.m
//  ImageHandleFunc
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#import "CaptureView.h"

@interface CaptureView ()

@property (strong, nonatomic) UILabel *countdownLabel;

@end

@implementation CaptureView

- (UILabel *)countdownLabel
{
    if (!_countdownLabel) {
        _countdownLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _countdownLabel.textAlignment = NSTextAlignmentCenter;
        _countdownLabel.textColor = [UIColor whiteColor];
        _countdownLabel.font = [UIFont systemFontOfSize:20.f];
        _countdownLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_countdownLabel];
    }
    return _countdownLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCountdownView];
        [self addTapGesture];
    }
    return self;
}

- (void)setupCountdownView
{
    CountdownView *countdownView = [[CountdownView alloc] initWithFrame:self.bounds];
    self.countdownView = countdownView;
    countdownView.state = ViewStateNormal;
    countdownView.countdownBlock = ^(int num) {
        self.countdownLabel.text = [NSString stringWithFormat:@"%d", 3 - num];
    };
    countdownView.endBlock = ^{
        self.countdownLabel.text = @"";
        if (self.endBlock) self.endBlock();
    };
    [self addSubview:countdownView];
}

- (void)addTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureEvent:)];
    [self addGestureRecognizer:tap];
}

- (void)tapGestureEvent:(UITapGestureRecognizer *)tap
{
    if (self.countdownView.state == ViewStateNormal) {
        if (self.tapBlock) self.tapBlock();
    }
}

@end
