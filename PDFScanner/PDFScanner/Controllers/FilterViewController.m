//
//  FilterViewController.m
//  PDFScanner
//
//  Created by Y on 2018/11/15.
//  Copyright © 2018 Y. All rights reserved.
//

#import "FilterViewController.h"
#import "UIView+Frame.h"
#import "UIViewController+Ext.h"
#import "UIBarButtonItem+Ext.h"
#import <Masonry.h>
#import "UIColor+Ext.h"
#import "Macro.h"
#import "DocumentManager.h"
#import "UIImage+Ext.h"
#import "UIImage+CropAndWarp.h"
#import "UIImage+OpenCV.h"
#import "FilterView.h"

@interface FilterViewController ()

@property (weak, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIImage *originalImage;

@property (strong, nonatomic) UIImage *cropedOriginalImage;

@property (weak, nonatomic) FilterView *filterView;

@property (strong, nonatomic) CIContext *context;

@property (strong, nonatomic) CIImage *inputImage;

@property (strong, nonatomic) CIImage *outputImage;

@property (strong, nonatomic) CIFilter *colorControlsFilter;

@end

@implementation FilterViewController

- (UIImage *)originalImage
{
    if (!_originalImage) {
        NSString *timeStr = [self.imageName componentsSeparatedByString:@"."].firstObject;
        NSString *originalImagePath = [OriginalFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_original.png", timeStr]];
        _originalImage = [UIImage imageWithContentsOfFile:originalImagePath];
    }
    return _originalImage;
}

- (UIImage *)cropedOriginalImage
{
    if (!_cropedOriginalImage) {
        NSString *argPath = [DocumentManager argsPath:self.folderPath];
        NSMutableDictionary *argDict = [NSMutableDictionary dictionaryWithContentsOfFile:argPath];
        NSDictionary *valueDict = argDict[[self.imageName componentsSeparatedByString:@"."].firstObject];
        
        CGPoint topLeft = CGPointFromString(valueDict[@"topLeft"]);
        CGPoint topRight = CGPointFromString(valueDict[@"topRight"]);
        CGPoint bottomLeft = CGPointFromString(valueDict[@"bottomLeft"]);
        CGPoint bottomRight = CGPointFromString(valueDict[@"bottomRight"]);
        UIImage *warpImage = [UIImage cropAndWarpImage:self.originalImage :topLeft :topRight :bottomLeft :bottomRight];
        _cropedOriginalImage = warpImage;
    }
    return _cropedOriginalImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // title
    self.title = @"Filter";
    // 设置背景色
    self.view.backgroundColor = [UIColor colorWithHex:0xededed];
    // 设置返回
    [self setupBackItem];
    // 设置Toolbar
    [self setupToolbar];
    // 设置UIImageView
    [self setupImageView];
    // 设置FilterView
    [self setupFilterView];
    // CIFilter
    [self setupFilter];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
}

#pragma mark - UIToolbar

- (void)setupToolbar
{
    UIBarButtonItem *binaryItem = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemDidClick:) image:@"filter2_icon"];
    binaryItem.tag = 1;
    
    UIBarButtonItem *grayItem = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemDidClick:) image:@"filter3_icon"];
    grayItem.tag = 2;
    
    UIBarButtonItem *originalItem = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemDidClick:) image:@"filter4_icon"];
    originalItem.tag = 3;
    
    UIBarButtonItem *confirmItem = [UIBarButtonItem itemWithTarget:self action:@selector(barButtonItemDidClick:) image:@"confirm_icon"];
    confirmItem.tag = 4;
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[binaryItem, flexibleItem, grayItem, flexibleItem,  originalItem, flexibleItem, confirmItem];
}

#pragma mark - UIBarButtonItem

- (void)backItemOnClick:(UIBarButtonItem *)item
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)barButtonItemDidClick:(UIBarButtonItem *)item
{
    switch (item.tag) {
        case 1: // 黑白
        {
            self.filterView.hidden = YES;
            
            self.imageView.image = self.cropedOriginalImage.sharpening.grayImage.binaryImage;
        }
            break;
        case 2:// 灰度
        {
            self.filterView.hidden = YES;
            
            self.imageView.image = self.cropedOriginalImage.sharpening.grayImage;
        }
            break;
        case 3: // 原图
        {
            self.filterView.hidden = NO;
            self.filterView.staturationSlider.value = 1.f;
            self.filterView.contrastSlider.value = 1.f;
            self.filterView.brightnessSlider.value = 0.f;
            
            self.imageView.image = self.cropedOriginalImage;
        }
            break;
        case 4: // 确认
        {
            self.filterView.hidden = YES;
            
            // 替换保存的warp图片
            NSString *imagePath = [self.folderPath stringByAppendingPathComponent:self.imageName]; dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [UIImagePNGRepresentation(self.imageView.image) writeToFile:imagePath atomically:YES];
            });
            [self dismissViewControllerAnimated:YES completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.doneBlock) self.doneBlock(imagePath);
                });
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIImageView

- (void)setupImageView
{
    NSString *cropPath = [self.folderPath stringByAppendingPathComponent:self.imageName];
    UIImageView *imageView = [[UIImageView alloc] init];
    self.imageView = imageView;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *binaryImage = [UIImage imageWithContentsOfFile:cropPath];
    imageView.image = binaryImage;
    [self.view addSubview:imageView];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10.f);
        make.top.equalTo(self.view.mas_top).offset(10.f);
        make.right.equalTo(self.view.mas_right).offset(-10.f);
        make.bottom.equalTo(self.view.mas_bottom).offset(- ToolbarHeight - 10.f);
    }];
}

#pragma mark - CIFilter

/**
 滤镜处理
 */
- (void)setupFilter
{
    self.context = [CIContext contextWithOptions:nil];
    self.colorControlsFilter = [CIFilter filterWithName:@"CIColorControls"];
    self.inputImage = [CIImage imageWithCGImage:self.cropedOriginalImage.sharpening.CGImage];
    //设置滤镜的输入图片
    [_colorControlsFilter setValue:self.inputImage forKey:@"inputImage"];
}

#pragma mark - FilterView

- (void)setupFilterView
{
    FilterView *filterView = [[FilterView alloc] init];
    self.filterView = filterView;
    filterView.hidden = YES;
    filterView.staturationValueBlock = ^(CGFloat value) {
        // 饱和度
        [self.colorControlsFilter setValue:@(value) forKey:@"inputSaturation"];
        [self setImage];
    };
    filterView.contrastValueBlock = ^(CGFloat value) {
        // 对比度
        [self.colorControlsFilter setValue:@(value) forKey:@"inputContrast"];
        [self setImage];
    };
    filterView.brightnessValueBlock = ^(CGFloat value) {
        // 亮度
        [self.colorControlsFilter setValue:@(value) forKey:@"inputBrightness"];
        [self setImage];
    };
    [self.view addSubview:filterView];
    [filterView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom).offset(-ToolbarHeight);
        make.height.mas_equalTo(150.f);
    }];
}

#pragma mark - 将输出图片设置到UIImageView

- (void)setImage
{
    //取得输出图像
    CIImage *outputImage =  [self.colorControlsFilter outputImage];
    CGImageRef temp = [self.context createCGImage:outputImage fromRect:[outputImage extent]];
    //转化为CGImage显示在界面中
    self.imageView.image = [UIImage imageWithCGImage:temp];
    //释放CGImage对象
    CGImageRelease(temp);
    
}


@end
