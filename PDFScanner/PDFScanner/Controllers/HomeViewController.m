//
//  HomeViewController.m
//  PDFScanner
//
//  Created by Y on 2018/11/7.
//  Copyright © 2018 Y. All rights reserved.
//

#import "HomeViewController.h"
#import "Macro.h"
#import "UIBarButtonItem+Ext.h"
#import "CameraViewController.h"
#import "BaseNavigationController.h"
#import "UIView+Frame.h"
#import <Masonry.h>
#import "UIColor+Ext.h"
#import "DocumentManager.h"
#import "PreviewViewController.h"

@interface HomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *dataSource;

@end

@implementation HomeViewController

static NSString *const reuseIdentifier = @"cell";

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    
    [self.collectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 设置背景色
    self.view.backgroundColor = [UIColor whiteColor];
    // 设置title
    self.title = @"Documents";
    // 大标题
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = true;
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    }
    // UIBarButtonItem
//    UIBarButtonItem *rightItem = [UIBarButtonItem itemWithTarget:self action:@selector(selectItemDidClick) title:@"Select"];
//    self.navigationItem.rightBarButtonItem = rightItem;
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFolders) name:@"AddSuccess" object:nil];
    
    [self setupCollectionView];
    
    [self setupAddButton];
    
    [self.collectionView registerClass:[FolderCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // 加载数据源
    [self getAllFolders];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UICollectionView

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor colorWithHex:0xEDEDED];
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupAddButton
{
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[UIImage imageNamed:@"addButton_icon"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(selectItemDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    [addButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-34.f - 15.f);
        make.size.mas_equalTo(CGSizeMake(76.f, 76.f));
    }];
}

#pragma mark - UIBarButtonItem

- (void)selectItemDidClick
{
    CameraViewController *controller = [[CameraViewController alloc] init];
    controller.cfrom = ControllerFromHome;
    controller.openPreviewBlock = ^(HomeFolderModel *model) {
        PreviewViewController *controller = [[PreviewViewController alloc] init];
        
        for (HomeFolderModel *fm in self.dataSource) {
            if ([fm.folderPath isEqualToString:model.folderPath]) {
                controller.model = fm;
                controller.index = [self.dataSource indexOfObject:fm];
                break;
            }
        }
        [self.navigationController pushViewController:controller animated:YES];
    };
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Documents

- (void)getAllFolders
{
    NSMutableDictionary *rootDict = [NSMutableDictionary dictionaryWithContentsOfFile:[DocumentManager getConfigPath]];
    NSMutableArray *folderArray = rootDict[@"folders"];
    NSMutableArray *temp = [NSMutableArray array];
    for (NSDictionary *dict in folderArray) {
        HomeFolderModel *model = [[HomeFolderModel alloc] initWithFolderPath:dict[@"folderPath"] createTime:dict[@"createTime"]];
        [temp addObject:model];
    }
    self.dataSource = [temp copy];
    
    
//    NSArray *folders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:HomeFolderPath error:NULL];
    
}

#pragma mark - NSNotificationCenter

- (void)refreshFolders
{
    [self getAllFolders];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FolderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    PreviewViewController *controller = [[PreviewViewController alloc] init];
    HomeFolderModel *model = self.dataSource[indexPath.item];
    controller.model = model;
    controller.index = indexPath.item;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat space = 10.f;
    CGFloat width = (self.view.width - 4 * space) / 3;
    CGFloat height = width * 1.77f;
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f);;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.f;
}

@end

@interface FolderCell ()

@property (weak, nonatomic) UIImageView *folderImageView;

@property (weak, nonatomic) UILabel *timeLabel;

@property (weak, nonatomic) UILabel *nameLabel;

@end

@implementation FolderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    UIImageView *folderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"folder_icon"]];
    self.folderImageView = folderImageView;
    folderImageView.contentMode = UIViewContentModeScaleAspectFit;
    folderImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:folderImageView];
    [folderImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [folderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom).offset(-40.f);
    }];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:8.f];
    timeLabel.textColor = [UIColor grayColor];
    [self addSubview:timeLabel];
    [timeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(folderImageView).offset(5.f);
        make.right.equalTo(folderImageView);
        make.bottom.equalTo(self.mas_bottom).offset(-2.f);
        make.height.mas_equalTo(10.f);
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:11.f];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.numberOfLines = 0;
    [self addSubview:nameLabel];
    [nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(folderImageView).offset(5.f);
        make.right.equalTo(folderImageView);
        make.top.equalTo(folderImageView.mas_bottom);
        make.bottom.equalTo(timeLabel.mas_top);
    }];
}

- (void)setModel:(HomeFolderModel *)model
{
    _model = model;
    
    self.nameLabel.text = model.folderPath;
    
    self.timeLabel.text = model.createTime;
}

@end
