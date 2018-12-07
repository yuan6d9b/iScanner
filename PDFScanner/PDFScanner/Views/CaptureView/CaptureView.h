//
//  CaptureView.h
//  ImageHandleFunc
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountdownView.h"

@interface CaptureView : UIView

@property (copy,nonatomic) void(^endBlock)(void);

@property (copy,nonatomic) void(^tapBlock)(void);

@property (weak, nonatomic) CountdownView *countdownView;

@end
