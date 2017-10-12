//
//  LLDemoBaseViewController.h
//  LLTokenPay
//
//  Created by EvenLam on 2017/9/21.
//  Copyright © 2017年 LianLianPay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLDemoTable.h"
#import "LLPayUtil.h"
#import "LLConsts.h"
#import "LLEnvCtrlView.h"
#import "LLPayResultInfoVC.h"

@interface LLDemoBaseViewController : UIViewController

@property (nonatomic, strong) LLDemoTable *tableView;
@property (nonatomic, strong) LLPayUtil *signUtil;
@property (nonatomic, strong) NSMutableDictionary *paymentInfo;

- (void)userInterfaceWithPlist: (NSString *)plist;
- (void)llPaymentAction;
- (void)pushInfoVCWithTitle: (NSString *)title andDic: (NSDictionary *)dic;
- (void)llAlertWithMsg: (NSString *)msg;

@end
