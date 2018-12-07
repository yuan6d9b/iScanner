//
//  PreviewViewController.m
//  PDFScanner
//
//  Created by Y on 2018/11/6.
//  Copyright © 2018 Y. All rights reserved.
//

#import "PreviewViewController.h"
#import "Macro.h"
#import "PreviewHorizontalLayout.h"
#import "UIView+Frame.h"
#import <Masonry.h>
#import "UIColor+Ext.h"
#import "DocumentManager.h"
#import "UIViewController+Ext.h"
#import "UIBarButtonItem+Ext.h"
#import "CameraViewController.h"
#import "BaseNavigationController.h"
#import "CropViewController.h"
#import "UIImage+Ext.h"
#import "UIImage+OpenCV.h"
#import "FilterViewController.h"
#import "PDFConvertTool.h"
#import "IAPManager.h"
#import "StoreViewController.h"

@interface PreviewViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (weak, nonatomic) PreviewHorizontalLayout *horizontalLayout;

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (weak, nonatomic) UILabel *indexLabel;

@end

static NSString *reuseIdentifier = @"cell";

@implementation PreviewViewController

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置背景色
    self.view.backgroundColor = [UIColor colorWithHex:0xededed];
    // 设置title
    self.title = self.model.folderPath;
    // 设置返回
    [self setupBackItem];
    // 设置CollectionView
    [self setupCollectionView];
    // 注册cell
    [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:reuseIdentifier];
    // 加载数据
    [self getAllImages];
    
    [self setupToolbar];
    
    [self setupIndexView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
}

#pragma mark - dataSource

- (void)getAllImages
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *docPath = [HomeFolderPath stringByAppendingPathComponent:self.model.folderPath];
    NSArray *imageNames = [manager contentsOfDirectoryAtPath:docPath error:nil];
    NSMutableArray *temp = [NSMutableArray array];
    for (NSString *name in imageNames) {
        if ([name containsString:@"plist"]) {
            continue;
        }else {
            [temp addObject:name];
        }
    }
    // 按日期升序
    NSArray *sortedArray = [temp sortedArrayUsingSelector:@selector(compare:)];
    [self.dataSource addObjectsFromArray:sortedArray];;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView

- (void)setupCollectionView
{
    PreviewHorizontalLayout *horizontalLayout = [[PreviewHorizontalLayout alloc] init];
    self.horizontalLayout = horizontalLayout;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:horizontalLayout];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.collectionView.backgroundColor = [UIColor colorWithHex:0xededed];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = NO;
    }
    [self.view addSubview:self.collectionView];
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - ToolBar

- (void)setupToolbar
{
    UIBarButtonItem *addItem = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemDidClick:) image:@"add_icon"];
    addItem.tag = 1;
    
    UIBarButtonItem *clipItem = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemDidClick:) image:@"clip_icon"];
    clipItem.tag = 2;
    
    UIBarButtonItem *filterItem = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemDidClick:) image:@"filter_icon"];
    filterItem.tag = 3;
    
    UIBarButtonItem *deleteItem = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemDidClick:) image:@"delete_icon"];
    deleteItem.tag = 4;
    
    UIBarButtonItem *moreItem = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemDidClick:) image:@"more_icon"];
    moreItem.tag = 5;
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[addItem, flexibleItem, clipItem, flexibleItem, filterItem, flexibleItem, deleteItem, flexibleItem, moreItem];
}

#pragma mark - IndexShow

- (void)setupIndexView
{
    UILabel *indexLabel = [[UILabel alloc] init];
    self.indexLabel = indexLabel;
    indexLabel.text = [NSString stringWithFormat:@"1 / %ld", self.dataSource.count];
    [self.view addSubview:indexLabel];
    [indexLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.collectionView);
        make.bottom.equalTo(self.view.mas_bottom).offset(-self.navigationController.toolbar.frame.size.height - 10);
        make.height.mas_equalTo(30.f);
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imagePath = [[HomeFolderPath stringByAppendingPathComponent:self.model.folderPath] stringByAppendingPathComponent:self.dataSource[indexPath.item]];
    return cell;
}

#pragma makr - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self filterHandler];
}

#pragma mark - UIScrollView

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateIndex];
}

#pragma mark - UIBarButtonItem

- (void)barButtonItemDidClick:(UIBarButtonItem *)item
{
    switch (item.tag) {
        case 1: // 增加
        {
            CameraViewController *controller = [[CameraViewController alloc] init];
            controller.cfrom = ControllerFromPreview;
            controller.completeBlock = ^(UIImage *image, UIImage *warpImage, CGPoint topLeft, CGPoint topRight, CGPoint bottomLeft, CGPoint bottomRight) {
                if (self.dataSource.count >= 5) {
                    StoreViewController *controller = [[StoreViewController alloc] init];
                    controller.payBlock = ^(NSInteger index) {
                        NSArray *productids = @[weekProductId, monthProductId, yearProductId];
                        [[IAPManager defaultManager] addPayment:productids[index - 1] success:^{
                            [self addImageHandler:image :warpImage :topLeft :topRight :bottomLeft :bottomRight];
                        } failure:^(NSString *error) {
                            
                        }];
                    };
                    [self presentViewController:controller animated:YES completion:nil];
                }else {
                    [self addImageHandler:image :warpImage :topLeft :topRight :bottomLeft :bottomRight];
                }
            };
            BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:controller];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        case 2:// 裁剪
        {
            CropViewController *controller = [[CropViewController alloc] init];
            controller.imageName = self.dataSource[[self getIndex]];
            controller.folderPath = [HomeFolderPath stringByAppendingPathComponent:self.model.folderPath];
            controller.completeBlock = ^(NSString *imagePath) {
                ImageCell *cell = (ImageCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self getIndex] inSection:0]];
                cell.imagePath = imagePath;
            };
            BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:controller];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        case 3:// 滤镜
        {
            [self filterHandler];
        }
            break;
        case 4: // 删除
        {
            [self deleteHandler];
        }
            break;
        case 5: // 更多
        {
            [self moreHandler];
        }
            break;
        default:
            break;
    }
}

- (void)filterHandler
{
    FilterViewController *controller = [[FilterViewController alloc] init];
    controller.imageName = self.dataSource[[self getIndex]];
    controller.folderPath = [HomeFolderPath stringByAppendingPathComponent:self.model.folderPath];
    controller.doneBlock = ^(NSString *imagePath) {
        ImageCell *cell = (ImageCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self getIndex] inSection:0]];
        cell.imagePath = imagePath;
    };
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - ToolBarHandler

/**
 删除当前图片
 */
- (void)deleteHandler
{
    int index = (int)(self.collectionView.contentOffset.x / (self.horizontalLayout.itemSize.width + self.horizontalLayout.minimumLineSpacing));
    // 图片名
    NSString *currentImagePath = self.dataSource[index];
    // 图片文件夹路径
    NSString *docPath = [HomeFolderPath stringByAppendingPathComponent:self.model.folderPath];
    // 图片路径
    NSString *warpPath = [docPath stringByAppendingPathComponent:currentImagePath];
    // 原图路径
    NSString *originalPath = [OriginalFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_original.%@", [currentImagePath componentsSeparatedByString:@"."].firstObject, [currentImagePath componentsSeparatedByString:@"."].lastObject]];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:warpPath]) {
        // 删除文件
        BOOL result1 = [manager removeItemAtPath:warpPath error:nil];
        // 删除原文件
        BOOL result2 = [manager removeItemAtPath:originalPath error:nil];
        // 删除图片对应的属性文件
        NSString *argPath = [DocumentManager argsPath:docPath];
        NSMutableDictionary *argDict = [NSMutableDictionary dictionaryWithContentsOfFile:argPath];
        [argDict removeObjectForKey:[currentImagePath componentsSeparatedByString:@"."].firstObject];
        [argDict writeToFile:argPath atomically:YES];
        // 如果只有一张图片 删除文件夹
        if (self.dataSource.count == 1 && result1 == YES && result2 == YES) {
            BOOL result3 = [manager removeItemAtPath:docPath error:nil];
            if (result3) {
                //  删除config.plist对应文件夹
                NSMutableDictionary *rootDict = [NSMutableDictionary dictionaryWithContentsOfFile:[DocumentManager getConfigPath]];
                NSMutableArray *folderArray = rootDict[@"folders"];
                [folderArray removeObjectAtIndex:self.index];
                [rootDict writeToFile:[DocumentManager getConfigPath] atomically:YES];
                // pop
                [self.navigationController popViewControllerAnimated:YES];
                // 通知刷新文件夹
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddSuccess" object:nil];
            }
        }else if (self.dataSource.count > 1 && result1 == YES && result2 == YES) {
            NSInteger index = (NSInteger)self.collectionView.contentOffset.x / (self.horizontalLayout.itemSize.width + self.horizontalLayout.minimumLineSpacing);
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [self.dataSource removeObjectAtIndex:indexPath.item];
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            } completion:^(BOOL finished) {
                [self updateIndex];
            }];
        }
    }
}

/**
 增加图片
 */
- (void)addImageHandler:(UIImage *)image :(UIImage *)warpImage :(CGPoint)topLeft :(CGPoint)topRight :(CGPoint)bottomLeft :(CGPoint)bottomRight
{
    NSString *timeStr = [DocumentManager getCurrentTime];
    
    // 图片文件夹路径
    NSString *docPath = [HomeFolderPath stringByAppendingPathComponent:self.model.folderPath];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 配置保存图片属性
        NSString *argPath = [DocumentManager argsPath:docPath];
        NSMutableDictionary *argDict = [NSMutableDictionary dictionaryWithContentsOfFile:argPath];
        argDict[timeStr] = @{
                             @"topLeft" : NSStringFromCGPoint(topLeft),
                             @"topRight" : NSStringFromCGPoint(topRight),
                             @"bottomLeft" : NSStringFromCGPoint(bottomLeft),
                             @"bottomRight" : NSStringFromCGPoint(bottomRight)
                             };
        [argDict writeToFile:argPath atomically:YES];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 图片名
        NSString *warpImageName = [NSString stringWithFormat:@"%@.png", timeStr];
        // 裁剪图片路径
        NSString *warpImagePath = [docPath stringByAppendingPathComponent:warpImageName];
        // 锐化
        UIImage *sharpeningImage = warpImage.sharpening;
        // 黑白
        UIImage *binaryImage = sharpeningImage.binaryImage;
        // 保存裁剪后锐化黑白图片
        [UIImagePNGRepresentation(binaryImage) writeToFile:warpImagePath atomically:YES];
        if ([[NSFileManager defaultManager] fileExistsAtPath:warpImagePath]) {
            [self.dataSource addObject:warpImageName];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.dataSource.count - 1 inSection:0];
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
                } completion:^(BOOL finished) {
                    // 移到最后位置
                    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                    // 修改索引
                    self.indexLabel.text = [NSString stringWithFormat:@"%ld / %ld", indexPath.item + 1, self.dataSource.count];
                }];
                
            });
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 原图路径
        NSString *originalImagePath = [OriginalFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_original.png", timeStr]];
        // 保存原图
        [UIImagePNGRepresentation(image) writeToFile:originalImagePath atomically:YES];
    });
}

/**
 更多操作 到处pdf ocr识别
 */
- (void)moreHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *pdfAction = [UIAlertAction actionWithTitle:@"PDF" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        StoreViewController *controller = [[StoreViewController alloc] init];
        controller.payBlock = ^(NSInteger index) {
            NSArray *productids = @[weekProductId, monthProductId, yearProductId];
            [[IAPManager defaultManager] addPayment:productids[index - 1] success:^{
                [self createPDF];
            } failure:^(NSString *error) {
                
            }];
        };
        [self presentViewController:controller animated:YES completion:nil];
    }];
    UIAlertAction *ocrAction = [UIAlertAction actionWithTitle:@"OCR" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alert addAction:pdfAction];
//    [alert addAction:ocrAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 导出PDF

- (void)createPDF
{
    NSString *pdfName = [[DocumentManager getCurrentTime] stringByAppendingPathExtension:@"pdf"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *imageName in self.dataSource) {
        NSString *path = [[HomeFolderPath stringByAppendingPathComponent:self.model.folderPath] stringByAppendingPathComponent:imageName];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        [array addObject:image];
    }
    BOOL result = [PDFConvertTool convertPDFWithImages:array fileName:pdfName];
    if (result) {
        NSString *pdfPath = [PDFConvertTool saveDirectory:pdfName];
        NSURL *pdfURL = [NSURL fileURLWithPath:pdfPath];
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[pdfURL] applicationActivities:nil];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - 修改索引

- (void)updateIndex
{
    // 修改索引
    self.indexLabel.text = [NSString stringWithFormat:@"%ld / %ld", [self getIndex] + 1, self.dataSource.count];
}

- (NSInteger)getIndex
{
    return (NSInteger)(self.collectionView.contentOffset.x / (self.horizontalLayout.itemSize.width + self.horizontalLayout.minimumLineSpacing));
}

@end

@interface ImageCell ()

@property (weak, nonatomic) UIImageView *imageview;

@end

@implementation ImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    UIImageView *imageview = [[UIImageView alloc] init];
    self.imageview = imageview;
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageview];
    [imageview setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setImagePath:(NSString *)imagePath
{
    _imagePath = imagePath;
    
    self.imageview.image = [UIImage imageWithContentsOfFile:imagePath];
}

@end
