//
//  CropViewController.m
//  PDFScanner
//
//  Created by Y on 2018/11/13.
//  Copyright © 2018 Y. All rights reserved.
//

#import "CropViewController.h"
#import "UIView+Frame.h"
#import "UIViewController+Ext.h"
#import "UIBarButtonItem+Ext.h"
#import <Masonry.h>
#import "UIColor+Ext.h"
#import "Macro.h"
#import "CropView.h"
#import "UIImageView+ContentFrame.h"
#import "DocumentManager.h"
#import "UIImage+CropAndWarp.h"
#import "UIImage+Ext.h"

@interface CropViewController ()

@property (weak, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) CropView *cropView;

@property (assign, nonatomic) BOOL isChange;

@property (assign, nonatomic) CGFloat rotateSlider;

@property (assign, nonatomic) CGRect initialRect;

@property (assign, nonatomic) CGRect finalRect;

@end

#define horizontalSpace 20.f
#define verticalSpace 20.f

@implementation CropViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // bgc
    self.view.backgroundColor = [UIColor colorWithHex:0xededed];
    // 设置返回
    [self setupBackItem];
    // 设置title
    self.title = @"Boundingbox";
    // 设置toolbar
    [self setupToolbar];
    // 设置imageview
    [self setupImageView];
    // 设置cropview
    [self setupCropView];
    // 初始化
    self.initialRect = self.imageView.frame;
    self.finalRect = self.imageView.frame;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    // 禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    // 开启返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark - UIToolbar

- (void)setupToolbar
{
    UIBarButtonItem *changeItem = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemDidClick:) image:@"change_icon2"];
    changeItem.tag = 1;
    
    UIBarButtonItem *rotateItem = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemDidClick:) image:@"rotate_icon"];
    rotateItem.tag = 2;
    
    UIBarButtonItem *confirmItem = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemDidClick:) image:@"confirm_icon"];
    confirmItem.tag = 3;
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[flexibleItem, changeItem, flexibleItem, rotateItem, flexibleItem, confirmItem, flexibleItem];
}

#pragma mark - UIBarButtonItem

- (void)backItemOnClick:(UIBarButtonItem *)item
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)barButtonItemDidClick:(UIBarButtonItem *)item
{
    switch (item.tag) {
        case 1: // boundingbox
        {
            self.isChange = !self.isChange;
            if (self.isChange) {
                item.image = [UIImage imageNamed:@"change_icon"];
                [self.cropView drawWithTopLeft:CGPointMake(LineWidth * 0.5, LineWidth * 0.5) topRight:CGPointMake(self.imageView.contentFrame.size.width - LineWidth * 0.5, LineWidth * 0.5) bottomLeft:CGPointMake(LineWidth * 0.5, self.imageView.contentFrame.size.height - LineWidth * 0.5) bottomRight:CGPointMake(self.imageView.contentFrame.size.width - LineWidth * 0.5, self.imageView.contentFrame.size.height - LineWidth * 0.5)];
            }else {
                item.image = [UIImage imageNamed:@"change_icon2"];
                NSString *argPath = [DocumentManager argsPath:self.folderPath];
                NSMutableDictionary *argDict = [NSMutableDictionary dictionaryWithContentsOfFile:argPath];
                NSDictionary *valueDict = argDict[[self.imageName componentsSeparatedByString:@"."].firstObject];
                
                CGPoint topLeft = CGPointFromString(valueDict[@"topLeft"]);
                CGPoint topRight = CGPointFromString(valueDict[@"topRight"]);
                CGPoint bottomLeft = CGPointFromString(valueDict[@"bottomLeft"]);
                CGPoint bottomRight = CGPointFromString(valueDict[@"bottomRight"]);
                
                [self.cropView drawWithTopLeft:[self convertPoint:topLeft] topRight:[self convertPoint:topRight] bottomLeft:[self convertPoint:bottomLeft] bottomRight:[self convertPoint:bottomRight]];
            }
        }
            break;
        case 2:// rotate
        {
            [self rotateEvent];
        }
            break;
        case 3: // confirm
        {
            CGPoint topLeft = [self scalePoint:self.cropView.topLeft];
            CGPoint topRight = [self scalePoint:self.cropView.topRight];
            CGPoint bottomLeft = [self scalePoint:self.cropView.bottomLeft];
            CGPoint bottomRight = [self scalePoint:self.cropView.bottomRight];
            // 获取裁剪图片
            UIImage *warpImage = [UIImage cropAndWarpImage:self.imageView.image :topLeft :topRight :bottomLeft :bottomRight];
            // 获取旋转图片
            UIImage *rotateImage = [UIImage saveRotatedImageWithAngle:self.rotateSlider * M_PI OriginalImage:warpImage];
            // 替换保存的warp图片
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [UIImagePNGRepresentation(rotateImage) writeToFile:[self.folderPath stringByAppendingPathComponent:self.imageName] atomically:YES];
            });
            // 替换定位裁剪区域4个点
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *argPath = [DocumentManager argsPath:self.folderPath];
                NSMutableDictionary *argDict = [NSMutableDictionary dictionaryWithContentsOfFile:argPath];
                NSMutableDictionary *valueDict = argDict[[self.imageName componentsSeparatedByString:@"."].firstObject];
                valueDict[@"topLeft"] = NSStringFromCGPoint(topLeft);
                valueDict[@"topRight"] = NSStringFromCGPoint(topRight);
                valueDict[@"bottomLeft"] = NSStringFromCGPoint(bottomLeft);
                valueDict[@"bottomRight"] = NSStringFromCGPoint(bottomRight);
                [argDict writeToFile:argPath atomically:YES];
            });
            
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.completeBlock) self.completeBlock([self.folderPath stringByAppendingPathComponent:self.imageName]);
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIImageView

- (void)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(horizontalSpace, verticalSpace, self.view.width - horizontalSpace * 2, self.view.height - StatusBarHeight - NavigationBarHeight - ToolbarHeight - verticalSpace * 2)];
    self.imageView = imageView;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    NSString *timeStr = [self.imageName componentsSeparatedByString:@"."].firstObject;
    NSString *originalImagePath = [OriginalFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_original.png", timeStr]];
    imageView.image = [UIImage imageWithContentsOfFile:originalImagePath];
    [self.view addSubview:imageView];
}

- (void)setupCropView
{
    CGRect frame = CGRectMake(self.imageView.contentFrame.origin.x + horizontalSpace, self.imageView.contentFrame.origin.y + verticalSpace, self.imageView.contentFrame.size.width, self.imageView.contentFrame.size.height);
    self.cropView = [[CropView alloc] initWithFrame:frame];
    
    NSString *argPath = [DocumentManager argsPath:self.folderPath];
    NSMutableDictionary *argDict = [NSMutableDictionary dictionaryWithContentsOfFile:argPath];
    NSDictionary *valueDict = argDict[[self.imageName componentsSeparatedByString:@"."].firstObject];
    
    CGPoint topLeft = CGPointFromString(valueDict[@"topLeft"]);
    CGPoint topRight = CGPointFromString(valueDict[@"topRight"]);
    CGPoint bottomLeft = CGPointFromString(valueDict[@"bottomLeft"]);
    CGPoint bottomRight = CGPointFromString(valueDict[@"bottomRight"]);
    
    [self.cropView drawWithTopLeft:[self convertPoint:topLeft] topRight:[self convertPoint:topRight] bottomLeft:[self convertPoint:bottomLeft] bottomRight:[self convertPoint:bottomRight]];
    
    [self.view addSubview:self.cropView];
}

/**
 原图上点 -> imageView点
 
 */
- (CGPoint)convertPoint:(CGPoint)point
{
    CGFloat x = point.x * self.imageView.contentScale;
    CGFloat y = point.y * self.imageView.contentScale;
    return CGPointMake(x, y);
}

/**
 imageView点 -> 原图上点
 
 */
- (CGPoint)scalePoint:(CGPoint)point
{
    CGFloat scale = self.imageView.contentScale;
    CGFloat x = point.x / scale;
    CGFloat y = point.y / scale;
    return CGPointMake(x, y);
}

#pragma mark - 旋转方法

- (void)rotateEvent
{
    CGFloat value = (int)floorf((self.rotateSlider + 1) * 2) - 1;
    
    if(value > 4) {
        value -= 4;
    }
    self.rotateSlider = value / 2 - 1;
    [UIView animateWithDuration:0.5 animations:^{
        [self rotateStateDidChange];
    }];
}

- (void)rotateStateDidChange
{
    CATransform3D transform = [self rotateTransform:CATransform3DIdentity clockwise:YES];
    CGFloat arg = self.rotateSlider * M_PI;
    CGFloat Wnew = fabs(self.initialRect.size.width * cos(arg)) + fabs(self.initialRect.size.height * sin(arg));
    CGFloat Hnew = fabs(self.initialRect.size.width * sin(arg)) + fabs(self.initialRect.size.height * cos(arg));
    
    CGFloat Rw = self.finalRect.size.width / Wnew;
    CGFloat Rh = self.finalRect.size.height / Hnew;
    CGFloat scale = MIN(Rw, Rh) * 1;
    transform = CATransform3DScale(transform, scale, scale, 1);
    self.imageView.layer.transform = transform;
    self.cropView.layer.transform = transform;
}

- (CATransform3D)rotateTransform:(CATransform3D)initialTransform clockwise:(BOOL)clockwise
{
    CGFloat arg = self.rotateSlider * M_PI;
    if(!clockwise){
        arg *= -1;
    }
    
    CATransform3D transform = initialTransform;
    transform = CATransform3DRotate(transform, arg, 0, 0, 1);
    transform = CATransform3DRotate(transform, 0 * M_PI, 0, 1, 0);
    transform = CATransform3DRotate(transform, 0 * M_PI, 1, 0, 0);
    
    return transform;
}

@end
