//
//  UIViewController+Ext.h
//  PDFScanner
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Ext)

/** 设置返回按钮 */
- (void)setupBackItem;

/** 返回按钮点击响应 */
- (void)backItemOnClick:(UIBarButtonItem *)item;

@end
