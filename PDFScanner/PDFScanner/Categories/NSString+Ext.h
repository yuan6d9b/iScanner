//
//  NSString+Ext.h
//  PDFScanner
//
//  Created by Y on 2018/11/26.
//  Copyright © 2018 Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Ext)

/** 计算size */
-(CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW;

@end
