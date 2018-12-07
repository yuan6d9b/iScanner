//
//  PreviewViewController.h
//  PDFScanner
//
//  Created by Y on 2018/11/6.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeFolderModel.h"

@interface PreviewViewController : UIViewController

@property (strong, nonatomic) HomeFolderModel *model;

@property (assign, nonatomic) NSInteger index;

@end

@interface ImageCell : UICollectionViewCell

@property (copy, nonatomic) NSString *imagePath;

@end
