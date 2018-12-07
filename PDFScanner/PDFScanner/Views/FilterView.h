//
//  FilterView.h
//  PDFScanner
//
//  Created by Y on 2018/11/19.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterView : UIView

@property (weak, nonatomic) UISlider *staturationSlider;

@property (weak, nonatomic) UISlider *contrastSlider;

@property (weak, nonatomic) UISlider *brightnessSlider;

@property (copy, nonatomic) void(^staturationValueBlock)(CGFloat value);

@property (copy, nonatomic) void(^contrastValueBlock)(CGFloat value);

@property (copy, nonatomic) void(^brightnessValueBlock)(CGFloat value);

@end
