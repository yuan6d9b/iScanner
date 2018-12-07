//
//  CountdownView.h
//  ImageHandleFunc
//
//  Created by Y on 2018/11/2.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ViewState) {
    ViewStateNormal = 0,
    ViewStateCountdown
};

@interface CountdownView : UIView

@property (copy,nonatomic) void(^endBlock)(void);

@property (copy,nonatomic) void(^countdownBlock)(int num);

@property (assign, nonatomic) ViewState state;

@end
