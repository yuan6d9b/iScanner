//
//  FilterView.m
//  PDFScanner
//
//  Created by Y on 2018/11/19.
//  Copyright © 2018 Y. All rights reserved.
//

#import "FilterView.h"
#import <Masonry.h>
#import "UIColor+Ext.h"

@implementation FilterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // bgm
        self.backgroundColor = [UIColor clearColor];
        
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithHex:0x767676 alpha:0.3];
    [self addSubview:backgroundView];
    [backgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    // 饱和度
    UISlider *staturationSlider = [[UISlider alloc] init];
    self.staturationSlider = staturationSlider;
    staturationSlider.maximumValue = 2.f;
    staturationSlider.minimumValue = 0.f;
    staturationSlider.value = 1.f;
    [staturationSlider addTarget:self action:@selector(staturationSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:staturationSlider];
    [staturationSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [staturationSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(60.f);
        make.right.equalTo(self).offset(-30.f);
        make.bottom.equalTo(self).offset(-20.f);
    }];
    UIImageView *staturationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bh_icon"]];
    [self addSubview:staturationImageView];
    [staturationImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [staturationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(staturationSlider);
        make.right.equalTo(staturationSlider.mas_left).offset(-2.f);
        make.size.mas_equalTo(CGSizeMake(28.f, 28.f));
    }];
    // 对比度
    UISlider *contrastSlider = [[UISlider alloc] init];
    self.contrastSlider = contrastSlider;
    contrastSlider.maximumValue = 4;
    contrastSlider.minimumValue = 0;
    contrastSlider.value = 1;
    [contrastSlider addTarget:self action:@selector(contrastSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:contrastSlider];
    [contrastSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contrastSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(staturationSlider);
        make.right.equalTo(staturationSlider);
        make.bottom.equalTo(staturationSlider.mas_top).offset(-10.f);
        make.width.mas_equalTo(staturationSlider.mas_width);
    }];
    UIImageView *contrastImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contrast_icon"]];
    [self addSubview:contrastImageView];
    [contrastImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contrastImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contrastSlider);
        make.right.equalTo(contrastSlider.mas_left).offset(-2.f);
        make.size.mas_equalTo(CGSizeMake(28.f, 28.f));
    }];
    // 亮度
    UISlider *brightnessSlider = [[UISlider alloc] init];
    self.brightnessSlider = brightnessSlider;
    brightnessSlider.maximumValue = 1.f;
    brightnessSlider.minimumValue = -1.f;
    brightnessSlider.value = 0.f;
    [brightnessSlider addTarget:self action:@selector(brightnessSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:brightnessSlider];
    [brightnessSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [brightnessSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(staturationSlider);
        make.right.equalTo(staturationSlider);
        make.bottom.equalTo(contrastSlider.mas_top).offset(-10.f);
        make.width.mas_equalTo(staturationSlider.mas_width);
    }];
    UIImageView *brightnessImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"brightness_icon"]];
    [self addSubview:brightnessImageView];
    [brightnessImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [brightnessImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(brightnessSlider);
        make.right.equalTo(brightnessSlider.mas_left).offset(-2.f);
        make.size.mas_equalTo(CGSizeMake(28.f, 28.f));
    }];
}

#pragma mark - UISlider

- (void)staturationSliderValueChanged:(UISlider *)sender
{
    if (self.staturationValueBlock) self.staturationValueBlock(sender.value);
}

- (void)contrastSliderValueChanged:(UISlider *)sender
{
    if (self.contrastValueBlock) self.contrastValueBlock(sender.value);
}

- (void)brightnessSliderValueChanged:(UISlider *)sender
{
    if (self.brightnessValueBlock) self.brightnessValueBlock(sender.value);
}

@end
