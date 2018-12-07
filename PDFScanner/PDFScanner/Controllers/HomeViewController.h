//
//  HomeViewController.h
//  PDFScanner
//
//  Created by Y on 2018/11/7.
//  Copyright © 2018 Y. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeFolderModel.h"

@interface HomeViewController : UIViewController

@end

@interface FolderCell : UICollectionViewCell

@property (strong, nonatomic) HomeFolderModel *model;

@end

