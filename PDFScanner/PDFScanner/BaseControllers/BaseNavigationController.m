//
//  BaseNavigationController.m
//  PDFScanner
//
//  Created by Y on 2018/11/5.
//  Copyright © 2018 Y. All rights reserved.
//

#import "BaseNavigationController.h"
#import "UIColor+Ext.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置导航栏是否透明
    [self.navigationBar setTranslucent:NO];
    
    // 设置tabBarItem
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.f],NSForegroundColorAttributeName:[UIColor colorWithHex:0x007dff]} forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithHex:0x4582FB]];
    
    //  设置UINavigationBar风格
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0],NSForegroundColorAttributeName:[UIColor colorWithRed:2.0/255 green:2.0/255 blue:2.0/255 alpha:1.0]}];
    
    // 开启侧滑
    //    self.interactivePopGestureRecognizer.delegate = self;
}

/**
 *  重写这个方法目的：能够拦截所有push进来的控制器
 *
 *  @param viewController 即将push进来的控制器
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) { // 这时push进来的控制器viewController，不是第一个子控制器（不是根控制器）
        /* 自动显示和隐藏tabbar */
        viewController.hidesBottomBarWhenPushed = YES;
        [self hideTabBar];
        
        // 下级页面不需要大标题
        if (@available(iOS 11.0, *)) {
            viewController.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        }
    }
    
    [super pushViewController:viewController animated:animated];
}

/**
 *  隐藏TabBar
 */
- (void)hideTabBar
{
    if (self.tabBarController.tabBar.hidden == YES) return;
    UIView *contentView;
    if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    } else {
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    }
    contentView.frame = CGRectMake(contentView.bounds.origin.x,  contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height + self.tabBarController.tabBar.frame.size.height);
    self.tabBarController.tabBar.hidden = YES;
}

@end
