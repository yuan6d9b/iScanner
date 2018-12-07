//
//  HomeFolderModel.h
//  PDFScanner
//
//  Created by Y on 2018/11/8.
//  Copyright © 2018 Y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeFolderModel : NSObject

@property (copy, nonatomic) NSString *folderPath;

@property (copy, nonatomic) NSString *createTime;

- (instancetype)initWithFolderPath:(NSString *)folderPath createTime:(NSString *)createTime;

@end
