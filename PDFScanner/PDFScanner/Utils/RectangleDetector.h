//
//  RectangleDetector.h
//  PDFScanner
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Vision/Vision.h>

@interface RectangleDetector : NSObject

@property (nonatomic, strong, nullable) VNRectangleObservation * lastObservation;

@property (nonatomic, strong, nullable) VNSequenceRequestHandler * sequenceHandler;

+ (instancetype)shareDetector;

- (void)visionImageEdge:(CVPixelBufferRef)image;

- (void)visionImageEdge:(CVPixelBufferRef)image lastObservation:(nullable VNRectangleObservation *)observation handler:(nullable VNRequestCompletionHandler)completionHandler;

@end
