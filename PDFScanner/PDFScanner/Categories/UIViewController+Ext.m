//
//  UIViewController+Ext.m
//  PDFScanner
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#import "UIViewController+Ext.h"

@implementation UIViewController (Ext)

/** 设置返回按钮 */
- (void)setupBackItem
{
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backItemOnClick:)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

/** 返回按钮点击响应 */
- (void)backItemOnClick:(UIBarButtonItem *)item
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
