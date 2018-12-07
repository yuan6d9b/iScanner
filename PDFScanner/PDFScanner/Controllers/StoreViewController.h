//
//  StoreViewController.h
//  PDFScanner
//
//  Created by Y on 2018/11/26.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreViewController : UIViewController

@property (copy, nonatomic) void(^payBlock)(NSInteger index);

@property (copy, nonatomic) void(^restoreBlock)(void);

@end
