//
//  RectangleDetector.m
//  PDFScanner
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#import "RectangleDetector.h"

@implementation RectangleDetector

+ (instancetype)shareDetector
{
    static RectangleDetector * detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detector = [[RectangleDetector alloc] init];
    });
    
    return detector;
}

- (void)visionImageEdge:(CVPixelBufferRef)image
{
    VNDetectRectanglesRequest * detectRequest = [[VNDetectRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        if (error) {
            NSLog(@"识别矩形出错 ==== %@", error);
            return ;
        }
        if (request.results.count) {
            NSLog(@"识别矩形成功 ----- %ld", request.results.count);
            [self visionImageEdge:image lastObservation:request.results.firstObject handler:nil];
        }else {
//            NSLog(@"未发现边框，请切换至手动模式");
        }
    }];
    
    // [0.0, 1.0], default 0.5
    //    detectRequest.minimumAspectRatio = 0.5;
    // range [0.0, 1.0], default .2
    detectRequest.minimumSize = 0.3;
    // range [0,45], default 30
    //    detectRequest.quadratureTolerance = 30;
    
    VNImageRequestHandler * handler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:image options:@{}];
    [handler performRequests:@[detectRequest] error:nil];
}

- (void)visionImageEdge:(CVPixelBufferRef)image lastObservation:(nullable VNRectangleObservation *)observation handler:(nullable VNRequestCompletionHandler)completionHandler
{
    if (observation) {
        self.lastObservation = observation;
        self.sequenceHandler = nil;
    }
    
    VNTrackRectangleRequest * trackRequest = [[VNTrackRectangleRequest alloc] initWithRectangleObservation:self.lastObservation completionHandler:completionHandler];
    trackRequest.trackingLevel = VNRequestTrackingLevelAccurate;
    
    if (!self.sequenceHandler) {
        self.sequenceHandler = [[VNSequenceRequestHandler alloc] init];
    }
    [self.sequenceHandler performRequests:@[trackRequest] onCVPixelBuffer:image error:nil];
}

@end
