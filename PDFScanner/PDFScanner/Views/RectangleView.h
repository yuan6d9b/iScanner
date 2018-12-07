//
//  RectangleView.h
//  PDFScanner
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RectangleView : UIView

@property (assign, nonatomic) CGPoint topLeft;

@property (assign, nonatomic) CGPoint topRight;

@property (assign, nonatomic) CGPoint bottomLeft;

@property (assign, nonatomic) CGPoint bottomRight;

@property (assign, nonatomic) CGRect boundingBox;

@property (assign, nonatomic) CGSize imageSize;

- (void)drawEdgeWithTopLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight;

@end
