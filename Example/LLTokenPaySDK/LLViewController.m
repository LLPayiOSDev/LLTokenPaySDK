//
//  LLViewController.m
//  LLTokenPaySDK
//
//  Created by LLPayiOSDev on 10/12/2017.
//  Copyright (c) 2017 LLPayiOSDev. All rights reserved.
//

#import "LLViewController.h"
#import <LLTokenPaySDK/LLTokenPaySDK.h>
#import "ServerSimulator.h"

@interface LLViewController ()

@property (weak, nonatomic) IBOutlet UITextField* nameField;
@property (weak, nonatomic) IBOutlet UITextField* idnoField;
@property (weak, nonatomic) IBOutlet UITextField* cardNoField;
@property (weak, nonatomic) IBOutlet UITextField* mobField;
@property (nonatomic, strong) ServerSimulator* server;

@end

@implementation LLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.server = [ServerSimulator new];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}
#pragma mark - ACTION

- (IBAction)checkVersion:(id)sender
{
    [self alertWithMsg:[LLTokenPaySDK getSDKVersion]];
}

- (IBAction)signAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self.server requestSignTokenWithParams:[self userInfo]
                                   complete:^(BOOL success, NSDictionary* dic) {
                                       if (success) {
                                           [weakSelf signWithPaymentInfo:dic];
                                       } else {
                                           [weakSelf alertWithMsg:dic[@"ret_msg"]];
                                       }
                                   }];
}

- (IBAction)payAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self.server requestPaymentTokenWithParams:[self userInfo]
                                      complete:^(BOOL success, NSDictionary* dic) {
                                          if (success) {
                                              [weakSelf payWithPaymentInfo:dic];
                                          } else {
                                              [weakSelf alertWithMsg:dic[@"ret_msg"]];
                                          }
                                      }];
}

- (void)payWithPaymentInfo:(NSDictionary*)paymentInfo
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [[LLTokenPaySDK sharedSdk] payApply:paymentInfo
                                   inVC:self
                               complete:^(LLPayResult result, NSDictionary* dic) {

                                   [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
                                   [self alertWithMsg:dic[@"ret_msg"]];
                               }];
}

- (void)signWithPaymentInfo:(NSDictionary*)paymentInfo
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [[LLTokenPaySDK sharedSdk] signApply:paymentInfo
                                    inVC:self
                                complete:^(LLPayResult result, NSDictionary* dic) {
                                    
                                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
                                    
                                    [self alertWithMsg:dic[@"ret_msg"]];
                                }];
}

#pragma mark - private

- (NSDictionary*)userInfo
{
    NSMutableDictionary* params = @{}.mutableCopy;
    params[@"id_no"] = [self textForField:self.idnoField];
    params[@"acct_name"] = [self textForField:self.nameField];
    params[@"card_no"] = [self textForField:self.cardNoField];
    params[@"bind_mob"] = [self textForField:self.mobField];
    return [params copy];
}

- (void)alertWithMsg:(NSString*)msg
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    [self.view endEditing:YES];
}

- (NSString*)textForField:(UITextField*)field
{
    return field.text.length > 0 ? field.text : nil;
}

@end
