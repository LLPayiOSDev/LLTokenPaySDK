//
//  LLPayResultInfoVC.h
//  DemoPay
//
//  Created by linyf on 2016/12/19.
//  Copyright © 2016年 LianLianPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLPayResultInfoVC : UIViewController

- (instancetype)initWithInfoDic: (NSDictionary *)dic;

@property (nonatomic, strong) NSString *payResultStr;

@end
