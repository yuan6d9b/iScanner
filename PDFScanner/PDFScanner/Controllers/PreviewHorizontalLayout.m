//
//  PreviewHorizontalLayout.m
//  PDFScanner
//
//  Created by Y on 2018/11/6.
//  Copyright © 2018 Y. All rights reserved.
//

#import "PreviewHorizontalLayout.h"

#define MAXScale 1.f

@interface PreviewHorizontalLayout ()

@property (nonatomic, assign) CGPoint lastOffset;/**<记录上次滑动停止时contentOffset值*/

@end

@implementation PreviewHorizontalLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastOffset = CGPointZero;
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    // space 距离左右边框距离
    CGFloat space = 50.f;
    CGFloat width = CGRectGetWidth(self.collectionView.frame) - space * 2;
    CGFloat height = CGRectGetHeight(self.collectionView.frame) - 40.f - 83.f;
    self.itemSize = CGSizeMake(width,  height);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.sectionInset = UIEdgeInsetsMake(0, space, 0, space);
    self.minimumLineSpacing = 10.f;
}

/**
 * 当collectionView的显示范围发生改变的时候，是否需要重新刷新布局
 * 一旦重新刷新布局，就会重新调用下面的方法：
 1.prepareLayout
 2.layoutAttributesForElementsInRect:方法
 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

/**
 UICollectionViewLayoutAttributes *attrs;
 1.一个cell对应一个UICollectionViewLayoutAttributes对象
 2.UICollectionViewLayoutAttributes对象决定了cell的frame
 
 这个方法的返回值是一个数组（数组里面存放着rect范围内所有元素的布局属性）
 这个方法的返回值决定了rect范围内所有元素的排布（frame）
 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // 获得super已经计算好的布局属性
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    // 计算collectionView最中心点的x值
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    // 在原有布局属性的基础上，进行微调
    for (UICollectionViewLayoutAttributes *attrs in array) {
        // cell的中心点x 和 collectionView最中心点的x值 的间距
        CGFloat delta = ABS(attrs.center.x - centerX);
        
        // 根据间距值 计算 cell的缩放比例
        //        CGFloat scale = 1 - delta / self.collectionView.frame.size.width;
        
        CGFloat scale = MAXScale - 0.1f * delta / self.itemSize.width;
        
        // 设置缩放比例
        attrs.transform = CGAffineTransformMakeScale(scale, scale);
    }
    return array;
}

/**
 * 这个方法的返回值，就决定了collectionView停止滚动时的偏移量
 
 */
//- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
//{
//    // 计算分页步距
//    CGFloat pageSpace = self.itemSize.width + self.minimumLineSpacing;
//
//    CGFloat offsetMax = self.collectionView.contentSize.width - (pageSpace + self.sectionInset.right + self.minimumLineSpacing);
//    CGFloat offsetMin = 0;
//    // 修改之前记录的位置，如果小于最小contentsize或者大于最大contentsize则重置值
//    if (_lastOffset.x < offsetMin) {
//        _lastOffset.x = offsetMin;
//    }else if (_lastOffset.x > offsetMax) {
//        _lastOffset.x = offsetMax;
//    }
//    // 目标位移点距离当前点的距离绝对值
//    CGFloat offsetForCurrentPointX = ABS(proposedContentOffset.x - _lastOffset.x);
//    CGFloat velocityX = velocity.x;
//    // 判断当前滑动方向,手指向左滑动：YES；手指向右滑动：NO
//    BOOL direction = (proposedContentOffset.x - _lastOffset.x) > 0;
//    // 5 滑动距离超过翻页距离的1/5即可翻页
//    if (offsetForCurrentPointX > pageSpace / 5. && _lastOffset.x >= offsetMin && _lastOffset.x <= offsetMax) {
//        // 分页因子，用于计算滑过的cell个数
//        NSInteger pageFactor = 0;
//        if (velocityX != 0) {
//            // 滑动
//            pageFactor = ABS(velocityX);//速率越快，cell滑过数量越多
//        }else {
//            // 拖动 没有速率，则计算：位移差/默认步距=分页因子
//            pageFactor = ABS(offsetForCurrentPointX / pageSpace);
//        }
//
//        // 设置pageFactor上限为2, 防止滑动速率过大，导致翻页过多
//        pageFactor = pageFactor < 1 ? 1 : (pageFactor < 3 ? 1 : 2);
//
//        CGFloat pageOffsetX = pageSpace * pageFactor;
//        proposedContentOffset = CGPointMake(_lastOffset.x + (direction ?pageOffsetX : -pageOffsetX), proposedContentOffset.y);
//    }else {
//        /*滚动距离，小于翻页步距一半，则不进行翻页操作*/
//        proposedContentOffset = CGPointMake(_lastOffset.x, _lastOffset.y);
//    }
//
//    //记录当前最新位置
//    _lastOffset.x = proposedContentOffset.x;
//    return proposedContentOffset;
//}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
        // 计算出最终显示的矩形框
        CGRect rect;
        rect.origin.y = 0;
        rect.origin.x = proposedContentOffset.x;
        rect.size = self.collectionView.frame.size;

        // 获得super已经计算好的布局属性
        NSArray *array = [super layoutAttributesForElementsInRect:rect];

        // 计算collectionView最中心点的x值
        CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;

        // 存放最小的间距值
        CGFloat minDelta = MAXFLOAT;
        for (UICollectionViewLayoutAttributes *attrs in array) {
            if (ABS(minDelta) > ABS(attrs.center.x - centerX)) {
                minDelta = attrs.center.x - centerX;
            }
        }

        // 修改原有的偏移量
        proposedContentOffset.x += minDelta;

        return proposedContentOffset;
}

@end
