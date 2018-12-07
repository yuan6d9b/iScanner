//
//  DocumentManager.h
//  PDFScanner
//
//  Created by Y on 2018/11/7.
//  Copyright © 2018 Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"

@interface DocumentManager : NSObject

+ (NSString *)getDefaultFolder;

+ (NSString *)getCurrentTime;

+ (NSString *)getCurrentTimeFormat;

+ (NSString *)getConfigPath;

+ (NSString *)argsPath:(NSString *)docPath;

@end
