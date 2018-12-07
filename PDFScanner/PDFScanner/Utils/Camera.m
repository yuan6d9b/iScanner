//
//  CSCamera.m
//  CamScanner
//
//  Created by Y on 2018/9/28.
//  Copyright © 2018 Y. All rights reserved.
//

#import "Camera.h"
#import <CoreImage/CoreImage.h>
#import "UIImage+Ext.h"

@interface Camera () <AVCaptureVideoDataOutputSampleBufferDelegate>

@end

@implementation Camera

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupCamera];
    }
    return self;
}

/**
 初始化相机
 */
- (void)setupCamera
{
    // 1.创建会话
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    // 2.创建输入设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 3.1创建输入
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    // 3.2.1创建静态图片输出
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    
    // 3.2.2创建实时图片输出
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
    [self.videoOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
    [self.videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL)];
    
    // 4.连接输入与会话
    if ([self.captureSession canAddInput:self.input]) {
        [self.captureSession addInput:self.input];
    }
    // 5.1连接静态图片输出与会话
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    // 5.2连接视频输出输出与会话
    if ([self.captureSession canAddOutput:self.videoOutput]) {
        [self.captureSession addOutput:self.videoOutput];
    }
    // 6.预览画面
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
}

/**
 根据前后置位置拿到相应的摄像头
 AVCaptureDevicePositionBack  后置摄像头
 AVCaptureDevicePositionFront 前置摄像头
 
 @param position 前后摄像头
 @return 前后摄像头
 */
- (nullable AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position){
            return device;
        }
    }
    return nil;
}

/**
 释放
 */
- (void)dealloc
{
    [self.captureSession stopRunning];
    self.previewLayer = nil;
    self.captureSession = nil;
    self.imageOutput = nil;
    self.videoOutput = nil;
}

/**
 创建camera对象
 
 @param rect 位置大小
 @param parent 父视图
 @return 相机对象
 */
+ (Camera *)cameraWithPreViewFrame:(CGRect)rect ParentView:(CALayer *)parent
{
    Camera *camera = [[Camera alloc] init];
    camera.previewLayer.frame = rect;
    [parent addSublayer:camera.previewLayer];
    return camera;
}

/**
 设备取景开始
 */
- (void)start
{
    [self.captureSession startRunning];
}

/**
 设备取景结束
 */
- (void)stop
{
    [self.captureSession stopRunning];
}

/**
  拍照取得image后续处理
 
 @param imageHandler 获取到image后处理
 */
- (void)captureStillImage:(void(^)(UIImage *image))imageHandler
{
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) return ;
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (error || imageDataSampleBuffer == nil) return ;
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        if (imageHandler) imageHandler([UIImage imageCompress:[UIImage imageWithRightOrientation:image]]);
    }];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        if (self.outputBlock) self.outputBlock(sampleBuffer, connection);
    }
}

@end
