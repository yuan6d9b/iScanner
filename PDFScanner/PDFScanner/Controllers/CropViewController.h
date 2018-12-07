//
//  CropViewController.h
//  PDFScanner
//
//  Created by Y on 2018/11/13.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CropViewController : UIViewController

@property (copy, nonatomic) NSString *imageName;

@property (copy, nonatomic) NSString *folderPath;

@property (copy, nonatomic) void(^completeBlock)(NSString *imagePath);

@end
