//
//  FilterViewController.h
//  PDFScanner
//
//  Created by Y on 2018/11/15.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterViewController : UIViewController

@property (copy, nonatomic) NSString *imageName;

@property (copy, nonatomic) NSString *folderPath;

@property (copy, nonatomic) void(^doneBlock)(NSString *imagePath);

@end
