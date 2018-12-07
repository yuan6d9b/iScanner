//
//  ViewController.h
//  PDFScanner
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeFolderModel.h"

typedef NS_ENUM(NSUInteger, ControllerFrom) {
    ControllerFromDefault = 0,
    ControllerFromHome,
    ControllerFromPreview
};

typedef NS_ENUM(NSUInteger, FlashState) {
    FlashStateAuto = 0,
    FlashStateOff,
    FlashStateOn
};

@interface CameraViewController : UIViewController

@property (assign, nonatomic) ControllerFrom cfrom;

@property (copy, nonatomic) void(^completeBlock)(UIImage *image, UIImage *warpImage, CGPoint topLeft, CGPoint topRight, CGPoint bottomLeft, CGPoint bottomRight);

@property (copy, nonatomic) void(^openPreviewBlock)(HomeFolderModel *model);

@end

