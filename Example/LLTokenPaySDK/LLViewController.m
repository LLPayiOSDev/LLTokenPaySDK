//
//  LLViewController.m
//  LLTokenPaySDK
//
//  Created by LLPayiOSDev on 10/12/2017.
//  Copyright (c) 2017 LLPayiOSDev. All rights reserved.
//

#import "LLViewController.h"
#import <LLTokenPaySDK/LLTokenPaySDK.h>


@interface LLViewController () <UIActionSheetDelegate>
@property (nonatomic, getter=isTestServer) BOOL testServer;
@end

@implementation LLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.testServer = YES;
    [self userInterfaceWithPlist:@"LLTokenPayUI"];
    
}

- (void)llPaymentAction {
    [super llPaymentAction];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择支付或签约" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"支付",@"签约", nil];
    [actionSheet showFromRect:self.tableView.tableFooterView.frame inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {//支付
        [self tokenPayAction:NO];
    }else if (buttonIndex == 1) {//签约
        [self tokenPayAction:YES];
    } else {
    }
}

- (void)tokenPayAction: (BOOL)isSign {
    
    self.paymentInfo = [NSMutableDictionary dictionary];
    self.paymentInfo[@"api_version"] = @"1.0";
    self.paymentInfo[@"sign_type"] = @"RSA";
    self.paymentInfo[@"time_stamp"] = [LLPayUtil timeStamp];
    self.paymentInfo[@"busi_partner"] = @"101001";
    self.paymentInfo[@"dt_order"] = [LLPayUtil timeStamp];
    self.paymentInfo[@"risk_item"] = [LLPayUtil jsonStringOfObj:@{@"user_info_dt_register" : @"20131030122130"}];
    [self.paymentInfo addEntriesFromDictionary:[self.tableView fieldsData]];
    
    //加签
    NSMutableArray *arr = [self.paymentInfo.allKeys mutableCopy];
    //    [arr removeObjectsInArray:@[@"id_type"]];
    self.signUtil.signKeyArray = [arr copy];
    NSDictionary *signedOrder = [self.signUtil signedOrderDic:self.paymentInfo andSignKey:kLLTokenPayPrivateKey];
    NSString *paycreatePath = [self pathForCreateBill:isSign];
    NSLog(@"\n👉Token支付创单请求地址： \n%@",paycreatePath);
    NSLog(@"\n👉Token支付请求参数： %@", signedOrder);
    
    __weak typeof(self) weakSelf = self;
    //切换环境
    [LLTokenPaySDK switchToTestServer:self.isTestServer];
    
    [LLPayUtil requestTokenWithDic:signedOrder path:paycreatePath complete:^(NSDictionary *responseDic) {
        //        NSLog(@"👉创单返回：%@",responseDic);
        NSString *token = [responseDic valueForKey:@"token"];
        if (token) {
            NSMutableDictionary *sdkPaymentInfo = [NSMutableDictionary dictionary];
            sdkPaymentInfo[@"oid_partner"] = weakSelf.paymentInfo[@"oid_partner"];
            sdkPaymentInfo[@"user_id"] = weakSelf.paymentInfo[@"user_id"];
            sdkPaymentInfo[@"token"] = token;
            sdkPaymentInfo[@"no_order"] = weakSelf.paymentInfo[@"no_order"];
            sdkPaymentInfo[@"money_order"] = weakSelf.paymentInfo[@"money_order"];
            if (isSign) {
                [weakSelf signWithPaymentInfo:[sdkPaymentInfo copy]];
            }else {
                [weakSelf payWithPaymentInfo:[sdkPaymentInfo copy]];
            }
            
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"👉获取Token失败： %@, %@", responseDic,responseDic[@"ret_msg"]);
                if (responseDic) {
                    [weakSelf llAlertWithMsg:[LLPayUtil jsonStringOfObj:responseDic]];
                }else {
                    [weakSelf llAlertWithMsg:@"SDK提示：获取Token失败, 请重试"];
                }
            });
        }
    }];
    
}

- (NSString *)pathForCreateBill: (BOOL)isSign {
    NSString *testServerUrl = self.isTestServer?@"http://test.yintong.com.cn":@"https://fourelementapi.lianlianpay.com";
    NSString *path = [NSString stringWithFormat:@"%@%@/%@createbill.htm",testServerUrl,self.isTestServer?@"/fourelementapi":@"",isSign?@"sign":@"pay"];
    return path;
}


#pragma mark - pay

- (void)payWithPaymentInfo: (NSDictionary *)paymentInfo {
    [[LLTokenPaySDK sharedSdk] payApply:paymentInfo inVC:self complete:^(LLPayResult result, NSDictionary *dic) {
        if (result == kLLPayResultCancel) {
            return ;
        }
        [self pushInfoVCWithTitle:dic[@"ret_msg"] andDic:dic];
    }];
}

- (void)signWithPaymentInfo: (NSDictionary *)paymentInfo {
    [[LLTokenPaySDK sharedSdk] signApply:paymentInfo inVC:self complete:^(LLPayResult result, NSDictionary *dic) {
        if (result == kLLPayResultCancel) {
            return ;
        }
        [self pushInfoVCWithTitle:dic[@"ret_msg"] andDic:dic];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
