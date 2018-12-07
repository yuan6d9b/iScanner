//
//  ProgressHUDView.h
//  PDFScanner
//
//  Created by Y on 2018/11/26.
//  Copyright © 2018 Y. All rights reserved.
//

#import "MBProgressHUD.h"

@interface ProgressHUDView : MBProgressHUD

/** 等待提示，默认文本‘加载中’*/
+ (ProgressHUDView *)showLoading;

@end
