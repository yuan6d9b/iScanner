//
//  HomeFolderModel.m
//  PDFScanner
//
//  Created by Y on 2018/11/8.
//  Copyright © 2018 Y. All rights reserved.
//

#import "HomeFolderModel.h"

@implementation HomeFolderModel

- (instancetype)initWithFolderPath:(NSString *)folderPath createTime:(NSString *)createTime
{
    HomeFolderModel *model = [[HomeFolderModel alloc] init];
    model.folderPath = folderPath;
    model.createTime = createTime;
    return model;
}

@end
