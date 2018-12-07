//
//  CropView.h
//  ImageHandleFunc
//
//  Created by Y on 2018/10/25.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CircleWidth 25.f
#define MagnifierWidth 100.f
#define LineWidth 2.f

@interface CropView : UIView

@property (assign, nonatomic) CGPoint topLeft;

@property (assign, nonatomic) CGPoint topRight;

@property (assign, nonatomic) CGPoint bottomLeft;

@property (assign, nonatomic) CGPoint bottomRight;

- (void)drawWithTopLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight;

@end
