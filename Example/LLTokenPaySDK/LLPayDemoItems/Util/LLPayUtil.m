//
//  LLPayUtil.m
//  DemoPay
//
//  Created by xuyf on 15/4/16.
//  Copyright (c) 2015年 llyt. All rights reserved.
//

#import "LLPayUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#define kLLPayUtilNeedRSASign

#ifdef kLLPayUtilNeedRSASign

@protocol LLPDataSigner

- (NSString *)algorithmName;
- (NSString *)signString:(NSString *)string;

@end

id<LLPDataSigner> LLPCreateRSADataSigner(NSString *privateKey);

#endif

@interface LLPayUtil()

@property (nonatomic, assign) LLPaySignMethod signMethod;

@property (nonatomic, retain) NSString *signKey;
@property (nonatomic, retain) NSString *rsaPrivateKey;

@end

@implementation LLPayUtil

+ (NSString *)timeStamp {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *simOrder = [dateFormater stringFromDate:[NSDate date]];
    return simOrder;
}

+ (NSString *)generateOrderNO {
    return [NSString stringWithFormat:@"LL%@",[self timeStamp]];
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}
+ (void)requestTokenWithDic: (NSDictionary *)paramDic path: (NSString *)path complete: (void(^)(NSDictionary *responseDic))complete {
    __block NSDictionary *jsonObject = nil;
    
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSString *param = [LLPayUtil jsonStringOfObj:paramDic];
    
    request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
    request.timeoutInterval = 30;
    
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURLSessionDataTask *task =
    
    [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error || !data) {
            NSLog(@"创单请求出错：%@",error.description);
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(@{@"ret_code":@"LE9001",@"ret_msg":@"创单请求错误"});
            });
            return;
        }
        
        jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(jsonObject);
        });
    }];
    
    [task resume];
}

- (NSDictionary*)signedOrderDic:(NSDictionary*)orderDic
                     andSignKey:(NSString*)signKey
{
    self.signKey = signKey;
    
    NSMutableDictionary* signedOrder = [NSMutableDictionary dictionaryWithDictionary:orderDic];
    NSString *signString = [self partnerSignOrder:orderDic];
    
    
    // 请求签名	sign	是	String	MD5（除了sign的所有请求参数+MD5key）
    signedOrder[self.keySign?:@"sign"] = signString;
    
    return signedOrder;
}

- (NSString*)partnerSignOrder:(NSDictionary*)paramDic
{
    // 所有参与订单签名的字段，这些字段以外不参与签名
    NSArray *keyArray = @[@"busi_partner",@"dt_order",@"info_order",
                          @"money_order",@"name_goods",@"no_order",
                          @"notify_url",@"oid_partner",@"",@"risk_item",
                          @"sign_type",@"valid_order",@"repayment_plan",@"repayment_no",@"sms_param",@"fund_name",@"fund_attach",@"fund_no",@"trans_type",@"settle_date"];
    
    if (self.signKeyArray != nil){
        keyArray = self.signKeyArray;
    }
    NSString *paramString = [self signOriginStringForSignKeyArray:keyArray andParamDic:paramDic];
    NSString *signType = self.keySignType?:@"sign_type";
    BOOL bMd5Sign = [paramDic[signType] isEqualToString:@"MD5"];
    BOOL bHmacSign = [paramDic[signType] isEqualToString:@"HMAC"];
    BOOL bSHA256Sign = [paramDic[signType] isEqualToString:@"SHA256"];
    
    NSString *signString = nil;
    if (bMd5Sign)
    {
        signString = [self signMD5String:paramString];
    }
    else if (bHmacSign){
        signString = [LLPayUtil signHmacString:paramString withKey:self.signKey];
    }
    else if (bSHA256Sign) {
        signString = [self signSHA256String:paramString];
    }
    else{
#ifdef kLLPayUtilNeedRSASign
        id<LLPDataSigner> signer = LLPCreateRSADataSigner(self.signKey);
        signString = [signer signString:paramString];
#endif
    }
    
    
    return signString;
}

- (NSString *)signOriginStringForSignKeyArray: (NSArray *)signKeyArray andParamDic: (NSDictionary *)paramDic {
    
    // 对字段进行字母序排序
    NSMutableArray *sortedKeyArray = [NSMutableArray arrayWithArray:signKeyArray];
    
    [sortedKeyArray sortUsingComparator:^NSComparisonResult(NSString* key1, NSString* key2) {
        return [key1 compare:key2];
    }];
    
    NSMutableString *paramString = [NSMutableString stringWithString:@""];
    
    // 拼接成 A=B&X=Y
    for (NSString *key in sortedKeyArray)
    {
        if ([paramDic[key] length] != 0)
        {
            [paramString appendFormat:@"&%@=%@", key, paramDic[key]];
        }
    }
    
    if ([paramString length] > 1)
    {
        [paramString deleteCharactersInRange:NSMakeRange(0, 1)];    // remove first '&'
    }
    NSString *signType = self.keySignType?:@"sign_type";
    BOOL bMd5Sign = [paramDic[signType] isEqualToString:@"MD5"];
//    BOOL bHmacSign = [paramDic[signType] isEqualToString:@"HMAC"];
//    BOOL bSHA256Sign = [paramDic[signType] isEqualToString:@"SHA256"];
    
    if (bMd5Sign)
    {
        // MD5签名，在最后加上key， 变成 A=B&X=Y&key=1234
        [paramString appendFormat:@"&key=%@", self.signKey];
    }
    else{
        // RSA HMAC
    }
    return paramString;
    
}

- (NSString *)signMD5String:(NSString*)origString
{
    const char *original_str = [origString UTF8String];
    unsigned char result[32];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);//调用md5
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++){
        [hash appendFormat:@"%02x", result[i]];
    }
    
    return hash;
}

- (NSString *)signSHA256String:(NSString*)origString {
    const char *original_str = [origString UTF8String];
    uint8_t result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(original_str, (CC_LONG)strlen(original_str), result);//调用SHA256
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++){
        [hash appendFormat:@"%02x", result[i]];
    }
    
    return hash;
}

+ (NSString *)signHmacString:(NSString*)text withKey:(NSString*)key
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    //NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    
    NSString *hash;
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", cHMAC[i]];
    }
    
    hash = output;
    
    return hash;
}



+ (NSString*)jsonStringOfObj:(NSDictionary*)dic{
    NSError *err = nil;
    
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:dic 
                                                         options:0
                                                           error:&err];
    
    NSString *str = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    
    return str;
}

+ (NSString *)LLURLEncodedString:(NSString*)str
{
#if __has_feature(objc_arc)
    NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                    (__bridge CFStringRef)str,
                                                                                    NULL,
                                                                                    CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                    kCFStringEncodingUTF8);
#else
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)str,
                                                                           NULL,
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
#endif
    return result;
}

+ (NSString *)LLURLDecodedString:(NSString*)str
{
    NSString *result = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return result;
}
@end
