//
//  ServerSimulator.h
//  LLTokenPaySDK_Example
//
//  Created by EvenLam on 2018/2/27.
//  Copyright © 2018年 LLPayiOSDev. All rights reserved.
//  模拟商户客户端请求服务端

#import <Foundation/Foundation.h>

///测试环境商户号
static NSString *kLLTestOidPartner = @"201307232000003510";

///正式环境商户号， 可更换成商户的商户号
static NSString *kLLReleaseOidPartner = @"201306031000001013";

///正式环境商户密钥， 可更换成商户的密钥
static NSString *kLLOidPartnerRSAKey = @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAMlGNh/WsyZSYnQcHd9t5qUkhcOhuQmozrAY9DM4+7fhpbJenmYee4chREW4RB3m95+vsz9DqCq61/dIOoLK940/XmhKkuVjfPqHJpoyHJsHcMYy2bXCd2fI++rERdXtYm0Yj2lFbq1aEAckciutyVZcAIHQoZsFwF8l6oS6DmZRAgMBAAECgYAApq1+JN+nfBS9c2nVUzGvzxJvs5I5qcYhY7NGhySpT52NmijBA9A6e60Q3Ku7vQeICLV3uuxMVxZjwmQOEEIEvXqauyYUYTPgqGGcwYXQFVI7raHa0fNMfVWLMHgtTScoKVXRoU3re6HaXB2z5nUR//NE2OLdGCv0ApaJWEJMwQJBAPWoD/Cm/2LpZdfh7oXkCH+JQ9LoSWGpBDEKkTTzIqU9USNHOKjth9vWagsR55aAn2ImG+EPS+wa9xFTVDk/+WUCQQDRv8B/lYZD43KPi8AJuQxUzibDhpzqUrAcu5Xr3KMvcM4Us7QVzXqP7sFc7FJjZSTWgn3mQqJg1X0pqpdkQSB9AkBFs2jKbGe8BeM6rMVDwh7TKPxQhE4F4rHoxEnND0t+PPafnt6pt7O7oYu3Fl5yao5Oh+eTJQbyt/fwN4eHMuqtAkBx/ ob+UCNyjhDbFxa9sgaTqJ7EsUpix6HTW9f1IirGQ8ac1bXQC6bKxvXsLLvyLSxCMRV/qUNa4Wxu0roI0KR5AkAZqsY48Uf/XsacJqRgIvwODstC03fgbml890R0LIdhnwAvE4sGnC9LKySRKmEMo8PuDhI0dTzaV0AbvXnsfDfp";

//认证支付:1    分期付：8
static NSString *flagPayProduct = @"1";

typedef void(^ServerBlock)(BOOL success,NSDictionary *dic);

@interface ServerSimulator : NSObject


/**
 模拟请求服务端获取支付Token

 @param params 参数
 @param complete 回调
 */
- (void)requestPaymentTokenWithParams: (NSDictionary *)params complete: (ServerBlock)complete;

/**
 模拟请求服务端获取签约Token
 
 @param params 参数
 @param complete 回调
 */
- (void)requestSignTokenWithParams:(NSDictionary*)params complete:(ServerBlock)complete;

@end
