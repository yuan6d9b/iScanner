//
//  ProgressHUDView.m
//  PDFScanner
//
//  Created by Y on 2018/11/26.
//  Copyright © 2018 Y. All rights reserved.
//

#import "ProgressHUDView.h"

@implementation ProgressHUDView

/** 等待提示，默认文本‘加载中’*/
+ (ProgressHUDView *)showLoading
{
    ProgressHUDView *hud = [ProgressHUDView showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    
    return hud;
}

@end
