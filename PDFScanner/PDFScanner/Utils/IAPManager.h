//
//  IAPManager.h
//  Sticker
//
//  Created by Y on 2018/11/21.
//  Copyright © 2018 Y. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  weekProductId @"com.iap.pdfsanner_week_premium"
#define  monthProductId @"com.iap.pdfsanner_monthly_premium"
#define  yearProductId @"com.iap.pdfsanner_yearly_premium"

@interface IAPManager : NSObject

@property (nonatomic) BOOL fullFunctionEnable;

@property (nonatomic, strong) NSMutableArray *prices;

/** 内购管理单例 */
+ (IAPManager *)defaultManager;

/** 恢复购买 */
- (void)restoreTransactionsOnSuccess:(void(^)(void))successBlock failure:(void(^)(void))failureBlock;

/** 请求商品列表 */
- (void)requestProduct;

/** 支付 */
- (void)addPayment:(NSString *)productID success:(void(^)(void))successBlock
           failure:(void(^)(NSString *error))failureBlock;

@end
