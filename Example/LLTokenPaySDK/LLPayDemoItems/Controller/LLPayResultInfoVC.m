//
//  LLPayResultInfoVC.m
//  DemoPay
//
//  Created by linyf on 2016/12/19.
//  Copyright © 2016年 LianLianPay. All rights reserved.
//

#import "LLPayResultInfoVC.h"
#import "LLConsts.h"

@interface LLPayResultInfoVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSDictionary *resultDic;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation LLPayResultInfoVC

- (instancetype)initWithInfoDic: (NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.resultDic = dic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"商户结果页";
    [self tableView];
    
}

- (UIView *)showView {
    CGFloat kWidth = [UIScreen mainScreen].bounds.size.width;
    UIView *showingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 100)];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, kWidth-40, 50)];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = LLHexColor(0x028ad7);
    infoLabel.text = self.payResultStr?:@"";
    infoLabel.font = [UIFont boldSystemFontOfSize:20];
    infoLabel.adjustsFontSizeToFitWidth = YES;
    [showingView addSubview:infoLabel];
    UIImage *logoImage = [UIImage imageNamed:@"LianLianPay_LOGO"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:logoImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(70, 10, kWidth - 140, 50);
    [showingView addSubview:imageView];
    
    UILabel *finalMoneyLb = [[UILabel alloc] init];
    finalMoneyLb.frame = CGRectMake(0, 100, kWidth, 50);
    finalMoneyLb.textColor = [UIColor darkTextColor];
    finalMoneyLb.backgroundColor = [UIColor whiteColor];
    finalMoneyLb.textAlignment = NSTextAlignmentCenter;
    finalMoneyLb.font = [UIFont boldSystemFontOfSize:28];
    [showingView addSubview:finalMoneyLb];
    
    if (self.resultDic[@"money_order"]) {
        if (!self.resultDic[@"discountAmt"]) {
            finalMoneyLb.text = [NSString stringWithFormat:@"￥ %@",self.resultDic[@"money_order"]];
            showingView.frame = CGRectMake(0, 0, kWidth, 150);
        }else {
            finalMoneyLb.text = [NSString stringWithFormat:@"￥ %@",[self finalPayMoney]];
            showingView.frame = CGRectMake(0, 0, kWidth, 230);
            
            UILabel *moneyOrderLb = [[UILabel alloc] init];
            moneyOrderLb.frame = CGRectMake(0, 150, kWidth, 40);
            moneyOrderLb.textColor = [UIColor lightTextColor];
            moneyOrderLb.backgroundColor = [UIColor whiteColor];
            moneyOrderLb.textAlignment = NSTextAlignmentCenter;
            moneyOrderLb.font = [UIFont systemFontOfSize:18];
            [showingView addSubview:moneyOrderLb];
            
            NSString *moneyOrder = [NSString stringWithFormat:@"￥ %@",self.resultDic[@"money_order"]];
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:moneyOrder];
            [attri addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, moneyOrder.length)];
            [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, moneyOrder.length)];
            [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor darkTextColor] range:NSMakeRange(0, moneyOrder.length)];
            [moneyOrderLb setAttributedText:attri];
            
            UILabel *discountLb = [[UILabel alloc] init];
            discountLb.frame = CGRectMake(0, 150 + 40, kWidth, 40);
            discountLb.textColor = [UIColor redColor];
            discountLb.backgroundColor = [UIColor whiteColor];
            discountLb.textAlignment = NSTextAlignmentCenter;
            discountLb.font = [UIFont systemFontOfSize:14];
            [showingView addSubview:discountLb];
            discountLb.text = [NSString stringWithFormat:@"云闪付立减优惠: ￥%@",self.resultDic[@"discountAmt"]];
        }
    }else {
        [finalMoneyLb removeFromSuperview];
    }
    
    return showingView;
}

- (UIView *)tableFooterView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.backgroundColor = LLColor;
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回支付页面" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPay) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(15, 10, self.view.frame.size.width - 30, 40);
    backBtn.layer.cornerRadius = 20.0;
    backBtn.layer.masksToBounds = YES;
    [view addSubview:backBtn];
    return view;
}

- (void)backToPay {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)finalPayMoney {
    NSDecimalNumber *moneyOrder = [NSDecimalNumber decimalNumberWithString:self.resultDic[@"money_order"]];
    NSDecimalNumber *discountAmt = [NSDecimalNumber decimalNumberWithString:self.resultDic[@"discountAmt"]];
    NSDecimalNumber *finalMoney = [moneyOrder decimalNumberBySubtracting:discountAmt];
    return finalMoney.stringValue;
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.resultDic.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.resultDic.allKeys[indexPath.row] stringByAppendingString:@":"];
    cell.textLabel.textColor = [UIColor colorWithRed:0 green:146/255.0 blue:209/255.0 alpha:1];
    cell.detailTextLabel.text = self.resultDic.allValues[indexPath.row];
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"详情" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [tableView setEditing:NO animated:YES];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.resultDic.allKeys[indexPath.row] message:self.resultDic.allValues[indexPath.row] preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    UITableViewRowAction *pasteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"复制" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIPasteboard *paste = [UIPasteboard generalPasteboard];
        paste.string = self.resultDic.allValues[indexPath.row];
        [tableView setEditing:NO animated:YES];
    }];
    return @[action, pasteAction];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowW, kWindowH- (self.navigationController.navigationBar.translucent?0:64)) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.tableHeaderView = [self showView];
        _tableView.tableFooterView = [self tableFooterView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
