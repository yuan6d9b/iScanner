//
//  ViewController.m
//  PDFScanner
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#import "CameraViewController.h"
#import "Camera.h"
#import "UIView+Frame.h"
#import "RectangleView.h"
#import "RectangleDetector.h"
#import "CVPixelBufferUtils.h"
#import "CaptureView.h"
#import "Macro.h"
#import <Masonry.h>
#import "UIImage+Ext.h"
#import "DocumentManager.h"
#import "UIViewController+Ext.h"
#import "UIImage+CropAndWarp.h"
#import "UIImage+OpenCV.h"
#import "UIColor+Ext.h"
#import "CALayer+Ext.h"

typedef NS_ENUM(uint8_t, MOVRotateDirection){
    MOVRotateDirectionNone = 0,
    MOVRotateDirectionCounterclockwise90,
    MOVRotateDirectionCounterclockwise180,
    MOVRotateDirectionCounterclockwise270,
    MOVRotateDirectionUnknown
};

@interface CameraViewController ()

@property (strong, nonatomic) Camera *camera;

@property (strong, nonatomic) RectangleView *rectangleView;

@property (assign, nonatomic) CGRect cameraFrame;

@property (weak, nonatomic) CaptureView *captureView;

@property (assign, nonatomic) BOOL flag;

@property (assign, nonatomic) CMSampleBufferRef lastSampleBufferRef;

@property (assign, nonatomic) FlashState state;

@property (weak, nonatomic) UIView *coverView;

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置title
    self.title = @"Auto";
    // 设置背景颜色
    self.view.backgroundColor = [UIColor whiteColor];
    // 初始化相机frame
    self.cameraFrame = CGRectMake(0.f, 0.f, self.view.width, self.view.width * 4 / 3);
    // 增加相机
    [self setupCamera];
    // 矩形探测范围显示
    [self setupRectangleView];
    // tip
    [self setupCoverView];
    // 拍照按钮
    [self setupBottomView];
    // 初始化
    self.flag = YES;
    // 设置返回
    [self setupBackItem];
    // 设置闪光灯
    [self setupFlash];
}

- (void)viewWillAppear:(BOOL)animated
{
    // 开启相机
    [self.camera start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 关闭相机
    [self.camera stop];
}

/**
 相机预览画面
 */
- (void)setupCamera
{
    // AVCaptureSessionPresetPhoto模式下预览画面的大小是(height=width*4/3)
    self.camera = [Camera cameraWithPreViewFrame:self.cameraFrame ParentView:self.view.layer];
    
    __weak typeof(self) weakSelf = self;
    
    self.camera.outputBlock = ^(CMSampleBufferRef sampleBuffer, AVCaptureConnection *connection) {
        
        weakSelf.lastSampleBufferRef = sampleBuffer;
        
        CVPixelBufferRef pixelBuffer = [CVPixelBufferUtils rotateBuffer:sampleBuffer withConstant:MOVRotateDirectionCounterclockwise270];
        
        size_t width = CVPixelBufferGetWidth(pixelBuffer);
        size_t height = CVPixelBufferGetHeight(pixelBuffer);
        CGSize size = CGSizeMake(width, height);
        
        if (![RectangleDetector shareDetector].lastObservation) {
            [[RectangleDetector shareDetector] visionImageEdge:pixelBuffer];
        } else {
            [[RectangleDetector shareDetector] visionImageEdge:pixelBuffer lastObservation:nil handler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                if (error) {
                    
                    NSLog(@"跟踪失败...");
                    weakSelf.flag = YES;
                    
                    [RectangleDetector shareDetector].lastObservation = nil;
                    weakSelf.rectangleView.imageSize = CGSizeZero;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.rectangleView setNeedsDisplay];
                        
                        weakSelf.captureView.countdownView.state = ViewStateNormal;
                    });
                } else {
                    VNRectangleObservation * observation = request.results.firstObject;
                    [RectangleDetector shareDetector].lastObservation = observation;
                    
                    NSLog(@"跟踪矩形中");
                    
                    if (weakSelf.flag) {
                        weakSelf.flag = NO;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.captureView.countdownView.state = ViewStateCountdown;
                        });
                    }
                    weakSelf.rectangleView.imageSize = size;
                    weakSelf.rectangleView.boundingBox = observation.boundingBox;
                    [weakSelf.rectangleView drawEdgeWithTopLeft:observation.topLeft topRight:observation.topRight bottomLeft:observation.bottomLeft bottomRight:observation.bottomRight];
                }
            }];
        }
        
        CVBufferRelease(pixelBuffer);
    };
}

/**
 矩形探测范围显示
 */
- (void)setupRectangleView
{
    self.rectangleView = [[RectangleView alloc] initWithFrame:self.cameraFrame];
    [self.view addSubview:self.rectangleView];
}

- (void)setupCoverView
{
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.width, 72.f)];
    coverView.backgroundColor = [UIColor clearColor];
    UIView *backgroundView = [[UIView alloc] initWithFrame:coverView.bounds];
    backgroundView.backgroundColor = [UIColor colorWithHex:0x666666 alpha:0.4f];
    [coverView addSubview:backgroundView];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.frame= coverView.bounds;
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.text = @"Adapt file to screen size";
    tipLabel.font = [UIFont systemFontOfSize:17.f];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor whiteColor];
    [coverView addSubview:tipLabel];
    
    UIButton *shakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shakeButton setTitle:@"?" forState:UIControlStateNormal];
    shakeButton.backgroundColor = [UIColor whiteColor];
    [shakeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    shakeButton.layer.cornerRadius = 15.f;
    shakeButton.layer.masksToBounds = YES;
    shakeButton.titleLabel.font = [UIFont systemFontOfSize:18.f];
    [shakeButton.layer shake];
    [shakeButton addTarget:self action:@selector(shakeButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [coverView addSubview:shakeButton];
    [shakeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [shakeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(coverView.mas_centerY);
        make.right.equalTo(coverView.mas_right).offset(-20.f);
        make.size.mas_equalTo(CGSizeMake(30.f, 30.f));
    }];
    
    [self.view addSubview:coverView];
}

/**
 闪光灯
 */
- (void)setupFlash
{
    UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    flashButton.frame = CGRectMake(0.f, 0.f, 19.f, 19.f);
    [flashButton setImage:[UIImage imageNamed:@"flashauto_icon"] forState:UIControlStateNormal];
    [flashButton addTarget:self action:@selector(flashButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:flashButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

/**
 bottomView
 */
- (void)setupBottomView
{
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomView];
    [bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(self.view.height - StatusBarHeight - NavigationBarHeight - self.view.width * 4 / 3);
    }];
    CGFloat width = 70.f;
    CGFloat height = 70.f;
    CGFloat x = (self.view.width - width) * 0.5f;
    CGFloat y = (self.view.height - StatusBarHeight - NavigationBarHeight - self.view.width * 4 / 3 - height) * 0.5f;
    CaptureView *capture = [[CaptureView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    self.captureView = capture;
    capture.endBlock = ^{
        [self.camera captureStillImage:^(UIImage *image) {
            
            UIImage *orientationImage = image;
            
            CGPoint tl = [self scalePoint:self.rectangleView.topLeft :orientationImage];
            CGPoint tr = [self scalePoint:self.rectangleView.topRight :orientationImage];
            CGPoint br = [self scalePoint:self.rectangleView.bottomRight :orientationImage];
            CGPoint bl = [self scalePoint:self.rectangleView.bottomLeft :orientationImage];
            
            UIImage *warpImage = [UIImage cropAndWarpImage:image :tl :tr :bl :br];
            
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.cfrom == ControllerFromHome) {
                    [self imageHandlerByControllerFromHome:image :warpImage :tl :tr :bl :br];
                }else if (self.cfrom == ControllerFromPreview) {
                    if (self.completeBlock) self.completeBlock(image, warpImage, tl, tr, bl, br);
                }
            }];
        }];
    };
    [bottomView addSubview:capture];
    
    UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleButton setTitle:@"Cancle" forState:UIControlStateNormal];
    [cancleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancleButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [cancleButton addTarget:self action:@selector(cancleButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cancleButton];
    [cancleButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomView.mas_centerY);
        make.left.equalTo(capture.mas_right).offset(50.f);
        make.height.mas_equalTo(40.f);
    }];
}

- (CGPoint)scalePoint:(CGPoint)point :(UIImage *)image
{
    CGSize imageSize = image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(self.view.bounds) / imageSize.width, CGRectGetHeight(self.view.bounds) / imageSize.height);
    CGFloat scale = imageScale;
    CGFloat x = point.x / scale;
    CGFloat y = point.y / scale;
    return CGPointMake(x, y);
}

- (CGPoint)scalePoint:(CGPoint)point
{
    UIImage *image = [self convertSampleBufferToImage:self.lastSampleBufferRef];
    CGSize imageSize = image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(self.view.bounds) / imageSize.width, CGRectGetHeight(self.view.bounds) / imageSize.height);
    CGFloat scale = imageScale;
    CGFloat x = point.x / scale;
    CGFloat y = point.y / scale;
    return CGPointMake(x, y);
}

- (UIImage *)convertSampleBufferToImage:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef pixelBuffer = [CVPixelBufferUtils rotateBuffer:sampleBuffer withConstant:MOVRotateDirectionCounterclockwise270];
    CIImage* ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext* context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    CGRect rect = CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
    CGImageRef videoImage = [context createCGImage:ciImage fromRect:rect];
    UIImage* image = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    return image;
}

- (UIImage *)clipImageWithImage:(UIImage *)image :(CGPoint)pointA :(CGPoint)pointB :(CGPoint)pointC :(CGPoint)pointD
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, pointA.x, pointA.y);
    CGContextAddLineToPoint(context, pointB.x, pointB.y);
    CGContextAddLineToPoint(context, pointC.x, pointC.y);
    CGContextAddLineToPoint(context, pointD.x, pointD.y);
    CGContextClosePath(context);
    CGContextClip(context);
    CGRect myRect = CGRectMake(0 , 0, image.size.width ,  image.size.height);
    [image drawInRect:myRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - Documents

- (NSString *)getHomeFolderPath
{
    NSString *homePath = HomeFolderPath;
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (![manager fileExistsAtPath:homePath isDirectory:&isDirectory]) {
        // 创建HomeFolder
        BOOL result = [manager createDirectoryAtPath:homePath withIntermediateDirectories:YES attributes:nil error:nil];
        // 创建config配置文件
        if (result) {
            [DocumentManager getConfigPath];
        }
    }
    return homePath;
}

- (NSString *)getOriginalFolderPath
{
    NSString *originalPath = OriginalFolderPath;
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (![manager fileExistsAtPath:originalPath isDirectory:&isDirectory]) {
        // 创建存放原图文件夹
        [manager createDirectoryAtPath:originalPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return OriginalFolderPath;
}

#pragma mark - UIBarButtonItem

- (void)backItemOnClick:(UIBarButtonItem *)item
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIButton

- (void)flashButtonEvent:(UIButton *)button
{
    // 修改当前状态
    if (self.state == FlashStateAuto) {
        self.state = FlashStateOff;
    }else if (self.state == FlashStateOff) {
        self.state = FlashStateOn;
    }else {
        self.state = FlashStateAuto;
    }
    // 根据状态修改样式与功能
    switch (self.state) {
        case FlashStateOff:
        {
            [button setImage:[UIImage imageNamed:@"flash_icon"] forState:UIControlStateNormal];
            if ([self.camera.device hasFlash] && [self.camera.device hasTorch]) {
                // 如果系统有闪光灯
                [self.camera.device lockForConfiguration:nil];
                [self.camera.device setTorchMode:AVCaptureTorchModeOff];
                [self.camera.device setFlashMode:AVCaptureFlashModeOff];
                [self.camera.device unlockForConfiguration];
            }
        }
            break;
        case FlashStateOn:
        {
            [button setImage:[UIImage imageNamed:@"flashon_icon"] forState:UIControlStateNormal];
            if ([self.camera.device hasFlash] && [self.camera.device hasTorch]) {
                // 如果系统有闪光灯
                [self.camera.device lockForConfiguration:nil];
                [self.camera.device setTorchMode:AVCaptureTorchModeOn];
                [self.camera.device setFlashMode:AVCaptureFlashModeOn];
                [self.camera.device unlockForConfiguration];
            }
        }
            break;
        case FlashStateAuto:
        {
            [button setImage:[UIImage imageNamed:@"flashauto_icon"] forState:UIControlStateNormal];
            if ([self.camera.device hasFlash] && [self.camera.device hasTorch]) {
                // 如果系统有闪光灯
                [self.camera.device lockForConfiguration:nil];
                [self.camera.device setTorchMode:AVCaptureTorchModeAuto];
                [self.camera.device setFlashMode:AVCaptureFlashModeAuto];
                [self.camera.device unlockForConfiguration];
            }
        }
            break;
        default:
            break;
    }
}

- (void)cancleButtonDidClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shakeButtonDidClick
{
    UIView *coverView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    self.coverView = coverView;
    coverView.backgroundColor = [UIColor clearColor];
    [self.navigationController.view addSubview:coverView];
    
    UIView *bgView = [[UIView alloc] initWithFrame:coverView.bounds];
    bgView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.3f];
    [coverView addSubview:bgView];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor colorWithHex:0x216EB4];
    contentView.layer.cornerRadius = 5.f;
    contentView.layer.masksToBounds = YES;
    [coverView addSubview:contentView];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(coverView);
        make.size.mas_equalTo(CGSizeMake(270.f, 360.f));
    }];
    
    UIButton *knowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    knowButton.backgroundColor = [UIColor colorWithHex:0x2BA0E6];
    [knowButton setTitle:@"Okay, I understand" forState:UIControlStateNormal];
    knowButton.titleLabel.font = [UIFont systemFontOfSize:20.f];
    [knowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    knowButton.layer.cornerRadius = 20.f;
    knowButton.layer.masksToBounds = YES;
    [knowButton addTarget:self action:@selector(knowButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:knowButton];
    [knowButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [knowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView.mas_left).offset(25.f);
        make.right.equalTo(contentView.mas_right).offset(-25.f);
        make.bottom.equalTo(contentView.mas_bottom).offset(-15.f);
        make.height.mas_equalTo(40.f);
    }];
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"Unable to capture file?";
    tipLabel.font = [UIFont systemFontOfSize:20.f];
    tipLabel.textColor = [UIColor whiteColor];
    [contentView addSubview:tipLabel];
    [tipLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView.mas_centerX);
        make.top.equalTo(contentView.mas_top).offset(30.f);
    }];
    UILabel *tipLabel2 = [[UILabel alloc] init];
    tipLabel2.text = @"Please follow the instructions:";
    tipLabel2.font = [UIFont systemFontOfSize:17.f];
    tipLabel2.textColor = [UIColor whiteColor];
    tipLabel2.numberOfLines = 0;
    [contentView addSubview:tipLabel2];
    [tipLabel2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView.mas_centerX);
        make.top.equalTo(tipLabel.mas_bottom).offset(20.f);
    }];
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = @"1.Make sure the edges of the file are clearly presented on the screen.\n\n2.Put the file on a more contrasting background.\n\n3.Move the device back and forth slightly toward the file until the square appears.";
    contentLabel.font = [UIFont systemFontOfSize:15.f];
    contentLabel.textColor = [UIColor whiteColor];
    contentLabel.numberOfLines = 0.f;
    [contentView addSubview:contentLabel];
    [contentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView.mas_left).offset(20.f);
        make.right.equalTo(contentView.mas_right).offset(-20.f);
        make.bottom.equalTo(knowButton.mas_top).offset(-20.f);
        make.top.equalTo(tipLabel2.mas_bottom).offset(5.f);
    }];
}

- (void)knowButtonDidClick
{
    [self.coverView removeFromSuperview];
}

#pragma mark - ImageHandler

/**
 image处理 源 -> home

 @param image 相机输出静态图片 旋转90修正+压缩
 */
- (void)imageHandlerByControllerFromHome:(UIImage *)image :(UIImage *)warpImage :(CGPoint)topLeft :(CGPoint)topRight :(CGPoint)bottomLeft :(CGPoint)bottomRight
{
    // 创建HomeFolder
    NSString *homePath = [self getHomeFolderPath];
    
    // 新建文件夹
    NSString *docName = [DocumentManager getDefaultFolder];
    // 配置config
    NSString *createTime = [DocumentManager getCurrentTimeFormat];
    NSDictionary *configDic = @{
                                @"folderPath" : docName,
                                @"createTime" : createTime
                                };
    NSMutableDictionary *rootDict = [NSMutableDictionary dictionaryWithContentsOfFile:[DocumentManager getConfigPath]];
    NSMutableArray *folderArray = rootDict[@"folders"];
    [folderArray addObject:configDic];
    [rootDict writeToFile:[DocumentManager getConfigPath] atomically:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddSuccess" object:nil];
    
    NSString *timeStr = [DocumentManager getCurrentTime];
    
    NSString *docPath = [homePath stringByAppendingPathComponent:docName];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 配置保存图片属性
        NSString *argPath = [DocumentManager argsPath:docPath];
        NSMutableDictionary *argDict = [NSMutableDictionary dictionaryWithContentsOfFile:argPath];
        argDict[timeStr] = @{
                             @"topLeft" : NSStringFromCGPoint(topLeft),
                             @"topRight" : NSStringFromCGPoint(topRight),
                             @"bottomLeft" : NSStringFromCGPoint(bottomLeft),
                             @"bottomRight" : NSStringFromCGPoint(bottomRight)
                             };
        [argDict writeToFile:argPath atomically:YES];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 保存裁剪后图片
        NSString *warpImagePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", timeStr]];
        // 锐化
        UIImage *sharpeningImage = warpImage.sharpening;
        // 灰度
        UIImage *grayImage = sharpeningImage.grayImage;
        // 黑白
        UIImage *binaryImage = grayImage.binaryImage;
        [UIImagePNGRepresentation(binaryImage) writeToFile:warpImagePath atomically:YES];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 保存原图
        NSString *originalFolder = [self getOriginalFolderPath];
        NSString *originalImagePath = [originalFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_original.png", timeStr]];
        [UIImagePNGRepresentation(image) writeToFile:originalImagePath atomically:YES];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        HomeFolderModel *model = [[HomeFolderModel alloc] init];
        model.folderPath = docName;
        model.createTime = createTime;
        if (self.openPreviewBlock) self.openPreviewBlock(model);
    });
}

@end
