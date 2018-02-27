//
//  PaySdkColor.h
//  PaySdkColor
//
//  Created by xuyf on 14-4-23.
//  Copyright (c) 2014年 llyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum LLPayResult {
    kLLPayResultSuccess = 0,      // 支付成功
    kLLPayResultFail = 1,         // 支付失败
    kLLPayResultCancel = 2,       // 支付取消，用户行为
    kLLPayResultInitError,        // 支付初始化错误，订单信息有误，签名失败等
    kLLPayResultInitParamError,   // 支付订单参数有误，无法进行初始化，未传必要信息等
    kLLPayResultUnknow,           // 其他
    kLLPayResultRequestingCancel, // 授权支付后取消(支付请求已发送)
} LLPayResult;

@interface LLTokenPaySDK : NSObject

typedef void(^CompletionHandler)(LLPayResult result, NSDictionary *dic);

/**
 *  单例
 *
 *  @return 返回LLTokenPaySDK的单例对象
 */
+ (LLTokenPaySDK *)sharedSdk;


/**
 支付申请
 
 @param paymentInfo 交易信息
 @param vc 承载支付页面的视图控制器
 @param complete 回调
 */
- (void)payApply:(NSDictionary *)paymentInfo
            inVC:(UIViewController *)vc
        complete: (CompletionHandler)complete;

/**
 签约申请
 
 @param paymentInfo 交易信息
 @param vc 承载签约界面的视图控制器
 @param complete 回调
 */
- (void)signApply: (NSDictionary *)paymentInfo
             inVC: (UIViewController *)vc
         complete: (CompletionHandler)complete;

/**
 *  切换正式、测试服务器（默认不调用是正式环境，请不要随意使用该函数切换至测试环境）
 *
 *  @param isTestServer YES测试环境，NO正式环境
 */
+ (void)switchToTestServer:(BOOL)isTestServer;


/**
 获取SDK当前版本

 @return 版本号
 */
+ (NSString *)getSDKVersion;

@end

