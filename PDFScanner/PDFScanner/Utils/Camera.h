//
//  CSCamera.h
//  CamScanner
//
//  Created by Y on 2018/9/28.
//  Copyright © 2018 Y. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface Camera : NSObject

// 捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, strong) AVCaptureDevice *device;

// AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput *input;

// 用于捕捉静态图片
@property (nonatomic ,strong) AVCaptureStillImageOutput *imageOutput;

// 原始视频帧，用于获取实时图像以及视频录制
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoOutput;

// 由session把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong) AVCaptureSession *captureSession;

// 图像预览层，实时显示捕获的图像
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;

/** 创建camera */
+ (Camera *)cameraWithPreViewFrame:(CGRect)rect ParentView:(CALayer *)parent;

/** 设备取景开始 */
- (void)start;

/** 设备取景结束 */
- (void)stop;

/** 拍照 */
- (void)captureStillImage:(void(^)(UIImage *image))imageHandler;

/** 视频流 */
@property (copy, nonatomic) void(^outputBlock)(CMSampleBufferRef sampleBuffer, AVCaptureConnection *connection);

@end

