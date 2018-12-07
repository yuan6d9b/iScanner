//
//  DocumentManager.m
//  PDFScanner
//
//  Created by Y on 2018/11/7.
//  Copyright © 2018 Y. All rights reserved.
//

#import "DocumentManager.h"

@implementation DocumentManager

+ (NSString *)getDefaultFolder
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *docName;
    // 判断文档名是否存在
    for (int i = 1; ; i++) {
        docName = [NSString stringWithFormat:@"%@, Doc %d", dateStr, i];
        NSArray *subDocs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:HomeFolderPath error:NULL];
        for (NSString *subName in subDocs) {
            if ([docName isEqualToString:subName]) {
                continue;
            }else {
                break;
            }
        }
        NSString *docPath = [HomeFolderPath stringByAppendingPathComponent:docName];
        BOOL isDirectory;
        if (![[NSFileManager defaultManager] fileExistsAtPath:docPath isDirectory:&isDirectory]) {
            BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:nil];
            if (result) {
                break;
            }
        }
    }
    return docName;
}

+ (NSString *)getCurrentTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHmmssSSS"];
    NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
    return timeStr;
}

+ (NSString *)getCurrentTimeFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
    return timeStr;
}

+ (NSString *)getConfigPath
{
    NSString *configPath = [HomeFolderPath stringByAppendingPathComponent:@"config.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
        NSMutableDictionary *rootDic = [NSMutableDictionary dictionary];
        rootDic[@"folders"] = @[];
        [rootDic writeToFile:configPath atomically:YES];
    }
    return configPath;
}


/**
 每张图片的属性 裁剪坐标

 */
+ (NSString *)argsPath:(NSString *)docPath
{
    NSString *argPath = [docPath stringByAppendingPathComponent:@"args.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:argPath]) {
        NSMutableDictionary *argDic = [NSMutableDictionary dictionary];
        [argDic writeToFile:argPath atomically:YES];
    }
    return argPath;
}

@end
