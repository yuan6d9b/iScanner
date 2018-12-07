//
//  PDFConvertTool.h
//  PDFScanner
//
//  Created by Y on 2018/11/12.
//  Copyright © 2018 Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PDFConvertTool : NSObject

+ (BOOL)convertPDFWithImages:(NSArray<UIImage *>*)images fileName:(NSString *)fileName;

+ (NSString *)saveDirectory:(NSString *)fileName;

@end
