//
//  StoreViewController.m
//  PDFScanner
//
//  Created by Y on 2018/11/26.
//  Copyright © 2018 Y. All rights reserved.
//

#import "StoreViewController.h"
#import "UIView+Frame.h"
#import "Macro.h"
#import <Masonry.h>
#import "UIColor+Ext.h"
#import "NSString+Ext.h"
#import "ProgressHUDView.h"
#import "IAPManager.h"

@interface StoreViewController ()

@property (weak, nonatomic) UIScrollView *scrollView;

@end

@implementation StoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSubviews];
}

- (void)setupSubviews
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView = scrollView;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    
    UIImageView *bgcImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"store_bgc"]];
    bgcImageView.frame = CGRectMake(0.f, StatusBarHeight, self.view.width, 180.f);
    [scrollView addSubview:bgcImageView];
    
    UIImageView *logoImageViwe = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"store_logo"]];
    logoImageViwe.frame = CGRectMake((self.view.width - 100.f) * 0.5f, (180.f - 100.f) * 0.5f, 100.f, 100.f);
    [scrollView addSubview:logoImageViwe];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"store_close"] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(15.f, 15.f, 35.f, 35.f);
    [closeButton addTarget:self action:@selector(closeButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:closeButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Try Pro Version";
    titleLabel.font = [UIFont systemFontOfSize:20.f weight:UIFontWeightBold];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:titleLabel];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(scrollView.mas_centerX);
        make.top.equalTo(bgcImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(self.view.width - 60.f, 30.f));
    }];
    
    UILabel *funcLabel1 = [[UILabel alloc] init];
    funcLabel1.textAlignment = NSTextAlignmentCenter;
    funcLabel1.text = @"Unlimaited documents";
    funcLabel1.font = [UIFont systemFontOfSize:16.f];
    [scrollView addSubview:funcLabel1];
    [funcLabel1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [funcLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(scrollView.mas_centerX).offset(15.f);
        make.top.equalTo(titleLabel.mas_bottom);
        make.height.mas_equalTo(30.f);
    }];
    UIImageView *funcImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"]];
    [scrollView addSubview:funcImageView1];
    [funcImageView1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [funcImageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(funcLabel1);
        make.right.equalTo(funcLabel1.mas_left).offset(-5.f);
        make.size.mas_equalTo(CGSizeMake(20.f, 20.f));
    }];
    
    UILabel *funcLabel2 = [[UILabel alloc] init];
    funcLabel2.textAlignment = NSTextAlignmentCenter;
    funcLabel2.text = @"No ads";
    funcLabel2.font = [UIFont systemFontOfSize:16.f];
    [scrollView addSubview:funcLabel2];
    [funcLabel2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [funcLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(funcLabel1.mas_left);
        make.top.equalTo(funcLabel1.mas_bottom);
        make.height.mas_equalTo(30.f);
    }];
    UIImageView *funcImageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"]];
    [scrollView addSubview:funcImageView2];
    [funcImageView2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [funcImageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(funcLabel2);
        make.right.equalTo(funcLabel2.mas_left).offset(-5.f);
        make.size.mas_equalTo(CGSizeMake(20.f, 20.f));
    }];
    
    UILabel *funcLabel3 = [[UILabel alloc] init];
    funcLabel3.textAlignment = NSTextAlignmentCenter;
    funcLabel3.text = @"No watermarks";
    funcLabel3.font = [UIFont systemFontOfSize:16.f];
    [scrollView addSubview:funcLabel3];
    [funcLabel3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [funcLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(funcLabel1.mas_left);
        make.top.equalTo(funcLabel2.mas_bottom);
        make.height.mas_equalTo(30.f);
    }];
    UIImageView *funcImageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"confirm_icon"]];
    [scrollView addSubview:funcImageView3];
    [funcImageView3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [funcImageView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(funcLabel3);
        make.right.equalTo(funcLabel3.mas_left).offset(-5.f);
        make.size.mas_equalTo(CGSizeMake(20.f, 20.f));
    }];
    
    UIView *priceView1 = [[UIView alloc] init];
    priceView1.layer.cornerRadius = 30.f;
    priceView1.layer.masksToBounds = YES;
    priceView1.layer.borderColor = [UIColor colorWithHex:0x007dff].CGColor;
    priceView1.layer.borderWidth = 0.5f;
    priceView1.backgroundColor = [UIColor colorWithHex:0x007dff];
    [scrollView addSubview:priceView1];
    [priceView1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [priceView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(funcLabel3.mas_bottom).offset(30.f);
        make.left.equalTo(scrollView.mas_left).offset(40.f);
        make.size.mas_equalTo(CGSizeMake(self.view.width - 80.f, 60.f));
    }];
    UILabel *priceLabel1 = [[UILabel alloc] init];
    priceLabel1.text = @"3 day Free Trial";
    priceLabel1.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightBold];
    priceLabel1.textColor = [UIColor whiteColor];
    [priceView1 addSubview:priceLabel1];
    [priceLabel1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [priceLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceView1.mas_left).offset(20.f);
        make.bottom.equalTo(priceView1.mas_centerY);
    }];
    UILabel *tipLabel1 = [[UILabel alloc] init];
    tipLabel1.text = @"then $1.99/week";
    tipLabel1.font = [UIFont systemFontOfSize:15.f];
    tipLabel1.textColor = [UIColor whiteColor];
    [priceView1 addSubview:tipLabel1];
    [tipLabel1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceView1.mas_left).offset(20.f);
        make.top.equalTo(priceView1.mas_centerY);
    }];
    UILabel *payLabel = [[UILabel alloc] init];
    payLabel.text = @"START";
    payLabel.textColor = [UIColor colorWithHex:0x007dff];
    payLabel.backgroundColor = [UIColor whiteColor];
    payLabel.layer.cornerRadius = 25.f;
    payLabel.layer.masksToBounds = YES;
    payLabel.textAlignment = NSTextAlignmentCenter;
    payLabel.font = [UIFont systemFontOfSize:19.f weight:UIFontWeightBold];
    [priceView1 addSubview:payLabel];
    [payLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [payLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(priceView1.mas_right).offset(-5.f);
        make.centerY.equalTo(priceView1);
        make.size.mas_equalTo(CGSizeMake(110.f, 50.f));
    }];
    UIButton *payButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    payButton1.backgroundColor = [UIColor clearColor];
    [payButton1 addTarget:self action:@selector(payButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    payButton1.tag = 1;
    [priceView1 addSubview:payButton1];
    [payButton1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [payButton1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(priceView1);
    }];
    
    UIView *priceView2 = [[UIView alloc] init];
    priceView2.layer.cornerRadius = 30.f;
    priceView2.layer.masksToBounds = YES;
    priceView2.layer.borderColor = [UIColor colorWithHex:0x007dff].CGColor;
    priceView2.layer.borderWidth = 0.5f;
    [scrollView addSubview:priceView2];
    [priceView2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [priceView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(priceView1.mas_bottom).offset(15.f);
        make.left.equalTo(scrollView.mas_left).offset(40.f);
        make.size.mas_equalTo(CGSizeMake(self.view.width - 80.f, 60.f));
    }];
    UILabel *priceLabel2 = [[UILabel alloc] init];
    priceLabel2.text = @"$1.99/week";
    priceLabel2.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightBold];
    priceLabel2.textColor = [UIColor colorWithHex:0x007dff];
    [priceView2 addSubview:priceLabel2];
    [priceLabel2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [priceLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceView2.mas_left).offset(20.f);
        make.bottom.equalTo(priceView2.mas_centerY);
    }];
    UILabel *tipLabel2 = [[UILabel alloc] init];
    tipLabel2.text = @"BILLED MONTHLY";
    tipLabel2.font = [UIFont systemFontOfSize:15.f];
    tipLabel2.textColor = [UIColor colorWithHex:0x007dff];
    [priceView2 addSubview:tipLabel2];
    [tipLabel2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceView2.mas_left).offset(20.f);
        make.top.equalTo(priceView2.mas_centerY);
    }];
    UIView *payView2 = [[UIView alloc] init];
    payView2.backgroundColor = [UIColor colorWithHex:0x007dff];
    payView2.layer.cornerRadius = 25.f;
    payView2.layer.masksToBounds = YES;
    [priceView2 addSubview:payView2];
    [payView2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [payView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(priceView2.mas_right).offset(-5.f);
        make.centerY.equalTo(priceView2);
        make.size.mas_equalTo(CGSizeMake(110.f, 50.f));
    }];
    UILabel *goLabel1 = [[UILabel alloc] init];
    goLabel1.text = @"GO";
    goLabel1.textColor = [UIColor whiteColor];
    goLabel1.textAlignment = NSTextAlignmentCenter;
    goLabel1.font = [UIFont systemFontOfSize:19.f weight:UIFontWeightBold];
    [payView2 addSubview:goLabel1];
    [goLabel1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [goLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(payView2);
        make.bottom.equalTo(payView2.mas_centerY);
    }];
    UILabel *monthLabel = [[UILabel alloc] init];
    monthLabel.text = @"$6.99/month";
    monthLabel.textColor = [UIColor whiteColor];
    monthLabel.textAlignment = NSTextAlignmentCenter;
    monthLabel.font = [UIFont systemFontOfSize:15.f];
    [payView2 addSubview:monthLabel];
    [monthLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(payView2);
        make.top.equalTo(payView2.mas_centerY);
    }];
    UIButton *payButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    payButton2.backgroundColor = [UIColor clearColor];
    [payButton2 addTarget:self action:@selector(payButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    payButton2.tag = 2;
    [priceView2 addSubview:payButton2];
    [payButton2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [payButton2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(priceView2);
    }];
    
    UIView *priceView3 = [[UIView alloc] init];
    priceView3.layer.cornerRadius = 30.f;
    priceView3.layer.masksToBounds = YES;
    priceView3.layer.borderColor = [UIColor colorWithHex:0x007dff].CGColor;
    priceView3.layer.borderWidth = 0.5f;
    [scrollView addSubview:priceView3];
    [priceView3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [priceView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(priceView2.mas_bottom).offset(15.f);
        make.left.equalTo(scrollView.mas_left).offset(40.f);
        make.size.mas_equalTo(CGSizeMake(self.view.width - 80.f, 60.f));
    }];
    UILabel *priceLabel3 = [[UILabel alloc] init];
    priceLabel3.text = @"$6.99/month";
    priceLabel3.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightBold];
    priceLabel3.textColor = [UIColor colorWithHex:0x007dff];
    [priceView3 addSubview:priceLabel3];
    [priceLabel3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [priceLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceView3.mas_left).offset(20.f);
        make.bottom.equalTo(priceView3.mas_centerY);
    }];
    UILabel *tipLabel3 = [[UILabel alloc] init];
    tipLabel3.text = @"BILLED YEARLY";
    tipLabel3.font = [UIFont systemFontOfSize:15.f];
    tipLabel3.textColor = [UIColor colorWithHex:0x007dff];
    [priceView3 addSubview:tipLabel3];
    [tipLabel3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tipLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceView3.mas_left).offset(20.f);
        make.top.equalTo(priceView3.mas_centerY);
    }];
    UIView *payView3 = [[UIView alloc] init];
    payView3.backgroundColor = [UIColor colorWithHex:0x007dff];
    payView3.layer.cornerRadius = 25.f;
    payView3.layer.masksToBounds = YES;
    [priceView3 addSubview:payView3];
    [payView3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [payView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(priceView3.mas_right).offset(-5.f);
        make.centerY.equalTo(priceView3);
        make.size.mas_equalTo(CGSizeMake(110.f, 50.f));
    }];
    UILabel *goLabel2 = [[UILabel alloc] init];
    goLabel2.text = @"GO";
    goLabel2.textColor = [UIColor whiteColor];
    goLabel2.textAlignment = NSTextAlignmentCenter;
    goLabel2.font = [UIFont systemFontOfSize:19.f weight:UIFontWeightBold];
    [payView3 addSubview:goLabel2];
    [goLabel2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [goLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(payView3);
        make.bottom.equalTo(payView3.mas_centerY);
    }];
    UILabel *yearLabel = [[UILabel alloc] init];
    yearLabel.text = @"$79.99/year";
    yearLabel.textColor = [UIColor whiteColor];
    yearLabel.textAlignment = NSTextAlignmentCenter;
    yearLabel.font = [UIFont systemFontOfSize:15.f];
    [payView3 addSubview:yearLabel];
    [yearLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [yearLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(payView3);
        make.top.equalTo(payView3.mas_centerY);
    }];
    UIButton *payButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    payButton3.backgroundColor = [UIColor clearColor];
    [payButton3 addTarget:self action:@selector(payButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    payButton3.tag = 3;
    [priceView3 addSubview:payButton3];
    [payButton3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [payButton3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(priceView3);
    }];
    
    UIButton *restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [restoreButton setTitle:@"RESTORE" forState:UIControlStateNormal];
    [restoreButton setImage:[UIImage imageNamed:@"restore"] forState:UIControlStateNormal];
    [restoreButton setTitleColor:[UIColor colorWithHex:0x007dff] forState:UIControlStateNormal];
    restoreButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [restoreButton setTitleEdgeInsets:UIEdgeInsetsMake(0.f, 10.f, 0.f, 0.f)];
    [restoreButton addTarget:self action:@selector(restoreButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:restoreButton];
    [restoreButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [restoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(priceView3.mas_bottom);
        make.centerX.equalTo(scrollView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(100.f, 40.f));
    }];
    
    UILabel *desLabel = [[UILabel alloc] init];
    desLabel.numberOfLines = 0;
    desLabel.font = [UIFont systemFontOfSize:15.f];
    desLabel.textColor = [UIColor colorWithHex:0x9D9D9D];
    NSString *text = @"Premium Plan is available with a weekly or monthly or annual subscription ($1.99/weekly or $6.99/month or $79.99/year). Of cause you can free trial for 3 days. You can subscribe and pay through your iTunes account. Payment will be charged to iTunes account at confirmation of purchase. Your subscription will automatically renew unless cancelled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. Subscriptions may be managed by the user and auto-renew may be turned off after purchase by going to the ‘Manage Subscription’ page in settings. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable. The subscription will renew at the same cost.";
    desLabel.text = text;
    [scrollView addSubview:desLabel];
    CGFloat height = [text sizeWithFont:[UIFont systemFontOfSize:15.f] maxW:self.view.width - 80.f].height;
    [desLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(scrollView.mas_centerX);
        make.top.equalTo(restoreButton.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(self.view.width - 80.f, height));
    }];
    
    scrollView.contentSize = CGSizeMake(self.view.width, 610.f + height);
}

#pragma mark - UIButton

- (void)closeButtonDidClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payButtonDidClick:(UIButton *)sender
{
    [self closeButtonDidClick];
    if (self.payBlock) self.payBlock(sender.tag);
}

- (void)restoreButtonDidClick
{
    ProgressHUDView *hudView = [ProgressHUDView showLoading];
    [[IAPManager defaultManager] restoreTransactionsOnSuccess:^{
        dismissAlert(@"restore success");
        [hudView hide:YES];
    } failure:^{
        dismissAlert(@"Unable to restore. Maybe you have no purchases");
        [hudView hide:YES];
    }];
}

@end
