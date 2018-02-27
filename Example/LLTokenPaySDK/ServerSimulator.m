//
//  ServerSimulator.m
//  LLTokenPaySDK_Example
//
//  Created by EvenLam on 2018/2/27.
//  Copyright © 2018年 LLPayiOSDev. All rights reserved.
//

#import "ServerSimulator.h"
#import "LLPayUtil.h"

@implementation ServerSimulator

- (void)requestPaymentTokenWithParams:(NSDictionary*)params complete:(ServerBlock)complete
{
    NSString* path = [self pathForCreateBill:NO];
    NSMutableDictionary* paymentInfo = [NSMutableDictionary dictionaryWithDictionary:params];
    [paymentInfo addEntriesFromDictionary:[self commonParams]];
    paymentInfo[@"busi_partner"] = @"101001";
    paymentInfo[@"name_goods"] = @"连连iOS测试商品";
    paymentInfo[@"info_order"] = nil;
    paymentInfo[@"money_order"] = @"0.01";
    paymentInfo[@"valid_order"] = @"10080";
    paymentInfo[@"shareing_data"] = nil;
    paymentInfo[@"no_agree"] = nil;
    LLPayUtil* util = [LLPayUtil new];
    util.signKeyArray = paymentInfo.allKeys;
    paymentInfo = [util signedOrderDic:[paymentInfo copy] andSignKey:kLLOidPartnerRSAKey].mutableCopy;

    [LLPayUtil requestTokenWithDic:[paymentInfo copy]
                              path:path
                          complete:^(NSDictionary* responseDic) {
                              NSString* token = responseDic[@"token"];
                              if (token.length > 0) {
                                  NSMutableDictionary *dic = @{}.mutableCopy;
                                  dic[@"token"] = token;
                                  dic[@"oid_partner"] = responseDic[@"oid_partner"];
                                  dic[@"user_id"] = responseDic[@"user_id"];
                                  dic[@"no_order"] = responseDic[@"no_order"];
                                  dic[@"money_order"] = responseDic[@"money_order"];
                                  complete(YES, [dic copy]);
                              } else {
                                  complete(NO, responseDic);
                              }
                          }];
}

- (void)requestSignTokenWithParams:(NSDictionary*)params complete:(ServerBlock)complete
{
    NSString* path = [self pathForCreateBill:YES];
    NSMutableDictionary* paymentInfo = [NSMutableDictionary dictionaryWithDictionary:params];
    [paymentInfo addEntriesFromDictionary:[self commonParams]];
    LLPayUtil* util = [LLPayUtil new];
    util.signKeyArray = paymentInfo.allKeys;
    paymentInfo = [util signedOrderDic:[paymentInfo copy] andSignKey:kLLOidPartnerRSAKey].mutableCopy;
    [LLPayUtil requestTokenWithDic:[paymentInfo copy]
                              path:path
                          complete:^(NSDictionary* responseDic) {
                              NSString* token = responseDic[@"token"];
                              if (token.length > 0) {
                                  NSMutableDictionary *dic = @{}.mutableCopy;
                                  dic[@"token"] = token;
                                  dic[@"oid_partner"] = responseDic[@"oid_partner"];
                                  dic[@"user_id"] = responseDic[@"user_id"];
                                  dic[@"no_order"] = responseDic[@"no_order"];
                                  complete(YES, [dic copy]);
                              } else {
                                  complete(NO, responseDic);
                              }
                          }];
}

- (NSDictionary*)commonParams
{
    NSString* timeStamp = [LLPayUtil timeStamp];
    NSMutableDictionary* params = @{}.mutableCopy;
    params[@"api_version"] = @"1.0";
    params[@"sign_type"] = @"RSA";
    params[@"time_stamp"] = timeStamp;
    params[@"platform"] = nil;
    params[@"oid_partner"] = kLLReleaseOidPartner;
    params[@"user_id"] = [@"User" stringByAppendingString:timeStamp];
    params[@"no_order"] = [@"DemoDD" stringByAppendingString:timeStamp];
    params[@"dt_order"] = timeStamp;
    params[@"notify_url"] = @"https://www.lianlianpay.com/notifyurl";
    params[@"url_return"] = nil;
    params[@"back_url"] = nil;
    params[@"risk_item"] = [LLPayUtil jsonStringOfObj:@{ @"user_info_dt_register" : @"20131030122130" }];
    params[@"flag_pay_product"] = flagPayProduct;
    params[@"flag_chnl"] = @"1";
    params[@"id_type"] = nil;

    return [params copy];
}

- (NSString*)pathForCreateBill:(BOOL)isSign
{
    NSString* serverURL = @"https://payserverapi.lianlianpay.com";
    NSString* path = [NSString stringWithFormat:@"%@/%@createbill.htm", serverURL, isSign ? @"sign" : @"pay"];
    return path;
}

@end
