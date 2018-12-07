//
//  IAPManager.m
//  Sticker
//
//  Created by Y on 2018/11/21.
//  Copyright © 2018 Y. All rights reserved.
//

#import "IAPManager.h"
#import "RMStore.h"
#import "RMAppReceipt.h"

@implementation IAPManager

/**
 内购管理单例

 @return 内购
 */
+ (IAPManager *)defaultManager
{
    static IAPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[IAPManager alloc] init];
        manager.fullFunctionEnable = NO;
        manager.prices = [NSMutableArray arrayWithArray:@[@"$1.99", @"$6.99", @"$79.99"]];
    });
    return manager;
}

/**
 恢复内购

 @param successBlock 成功
 @param failureBlock 失败
 */
- (void)restoreTransactionsOnSuccess:(void(^)(void))successBlock failure:(void(^)(void))failureBlock
{
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
        [[RMStore defaultStore] refreshReceiptOnSuccess:^{
            RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
            BOOL containActive = NO;
            if (receipt) {
                containActive = [receipt containsActiveAutoRenewableSubscriptionOfProductIdentifier:weekProductId forDate:[NSDate date]] || [receipt containsActiveAutoRenewableSubscriptionOfProductIdentifier:monthProductId forDate:[NSDate date]] || [receipt containsActiveAutoRenewableSubscriptionOfProductIdentifier:yearProductId forDate:[NSDate date]];
            }
            if (containActive) {
                // 有内购
                [IAPManager defaultManager].fullFunctionEnable = YES;
                if (successBlock) successBlock();
            }else {
                // 无内购
                [IAPManager defaultManager].fullFunctionEnable = NO;
                // Unable to restore. Maybe you have no purchases.
                if (failureBlock) failureBlock();
            }
        } failure:^(NSError *error) {
            // An error occurred while trying to restore purchases. Please try again.
            [IAPManager defaultManager].fullFunctionEnable = NO;
            if (failureBlock) failureBlock();
        }];
    } failure:^(NSError *error) {
        // An error occurred while trying to restore purchases. Please try again.
        [IAPManager defaultManager].fullFunctionEnable = NO;
        if (failureBlock) failureBlock();
    }];
}

/**
 请求商品列表
 */
- (void)requestProduct
{
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:@[weekProductId, monthProductId, yearProductId]] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        if (products.count == 0) {
            NSLog(@"--------------没有商品------------------");
            return ;
        }else {
            SKProduct *product = [[RMStore defaultStore] productForIdentifier:weekProductId];
            if (product) {
                [IAPManager defaultManager].prices[0] = [RMStore localizedPriceOfProduct:product];
            }
            product = [[RMStore defaultStore] productForIdentifier:monthProductId];
            if (product) {
                [IAPManager defaultManager].prices[1] = [RMStore localizedPriceOfProduct:product];
            }
            product = [[RMStore defaultStore] productForIdentifier:yearProductId];
            if (product) {
                [IAPManager defaultManager].prices[2] = [RMStore localizedPriceOfProduct:product];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"--------------请求商品失败------------------");
    }];
}

/**
 支付

 @param productID 商品id
 @param successBlock 成功
 @param failureBlock 失败
 */
- (void)addPayment:(NSString *)productID success:(void(^)(void))successBlock
           failure:(void(^)(NSString *error))failureBlock
{
    [[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction) {
        if (successBlock) successBlock();
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        if (failureBlock) failureBlock(error.localizedDescription);
    }];
}

@end
