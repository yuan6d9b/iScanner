//
//  MagnifierView.h
//  ImageHandleFunc
//
//  Created by Y on 2018/10/25.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MagnifierView : UIWindow

@property (strong, nonatomic) UIView *renderView;

@property (assign, nonatomic) CGPoint renderPoint;

@end
