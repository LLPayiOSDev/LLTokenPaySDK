//
//  LLEnvCtrlView.m
//  DemoPay
//
//  Created by linyf on 16/6/16.
//  Copyright © 2016年 llyt. All rights reserved.
//

#import "LLEnvCtrlView.h"
#import "LLConsts.h"

static CGFloat btnHeight = 40;
static CGFloat margin = 10;
static CGFloat radius = 20;
static NSUInteger rowNumber = 2;
static NSString *testFunctionName = @"";

#define NORMAL_COLOR [UIColor darkTextColor]
#define SELECTED_COLOR [UIColor whiteColor]
#define DISABLED_COLOR [UIColor lightGrayColor]

#define BTN_COLOR [UIColor colorWithWhite:0.72 alpha:0.9]
#define BG_COLOR [UIColor colorWithWhite:1 alpha:0.78]

@interface LLEnvCtrlView () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

/** 正式环境切换按钮 */
@property (nonatomic, strong) UIButton *testEnvBtn;
/** UAT环境切换按钮 */
@property (nonatomic, strong) UIButton *uatBtn;
/** 测试环境地址输入框 */
@property (nonatomic, strong) UITextField *testAddrField;
@property (nonatomic, strong) NSString *selectedAddr;

@property (nonatomic, strong) UIButton *szHostBtn;

/** 请求报文加密 */
@property (nonatomic, strong) UIButton *encRequestMsgBtn;
/** 返回报文加密 */
@property (nonatomic, strong) UIButton *encReturnMsgBtn;

/** userDefault */
@property (nonatomic, strong) NSUserDefaults *userDefault;
/*! 功能测试按钮 */
@property (nonatomic, strong) UIButton *testBtn;

/** btnwidth */
@property (nonatomic, assign) CGFloat btnWidth;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIPickerView *addressPicker;
@property (nonatomic, strong) NSArray *addrArr;

@end


@implementation LLEnvCtrlView

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];

        self.backgroundColor = BG_COLOR;
        
        CGFloat height = margin + rowNumber * (btnHeight + margin);
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 2 * margin;
        CGFloat y = [UIScreen mainScreen].bounds.size.height - margin - height;
        self.frame = CGRectMake(margin, y, width, height);
        self.layer.cornerRadius = radius;
        [self addSubview:self.testEnvBtn];
        [self addSubview:self.uatBtn];
        [self addSubview:self.testAddrField];
        if (rowNumber == 3) {
            [self addSubview:self.testBtn];
        }else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:funcTestKey];
        }
//        if (![self isApplePay]) {
//            [self addSubview:self.szHostBtn];
//        }else {
//            [self addSubview:self.testBtn];
//        }
        
//        [self addSubview:self.encRequestMsgBtn];
//        [self addSubview:self.encReturnMsgBtn];
//        [self addSubview:self.testBtn];
        
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDismiss:)];
        swipe.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:swipe];
    }
    return self;
}

- (void)show: (BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadData];
        [self refreshUI];
    });
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.bgView];
    self.bgView.alpha = 0;
    [window addSubview:self];
    CGRect originFrame = self.frame;
    CGRect frame = originFrame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height;
    self.frame = frame;
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bgView.alpha = 1;
            self.frame = originFrame;
        }];
    }else {
        self.bgView.alpha = 1;
        self.frame = originFrame;
    }

}

- (void)hide:(BOOL)animated {
    [self saveData];
    
    CGRect frame = self.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height;
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bgView.alpha = 0;
            self.frame = frame;
        } completion:^(BOOL finished) {
            [self.bgView removeFromSuperview];
            [self removeFromSuperview];
        }];
    }else {
        self.bgView.alpha = 0;
        [self.bgView removeFromSuperview];
        self.frame = frame;
        [self removeFromSuperview];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardShow: (NSNotification *)notification {
    NSDictionary *dictionary = notification.userInfo;
    CGRect frame = self.frame;
    CGRect keyboardEndFrame = [dictionary[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    frame.origin.y = keyboardEndFrame.origin.y - frame.size.height - margin;
    NSTimeInterval duration = [dictionary[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [dictionary[UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.frame = frame;
    } completion:nil];
}

- (void)keyboardHide: (NSNotification *)notification {
    NSDictionary *dictionary = notification.userInfo;
    CGRect frame = self.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - margin - self.frame.size.height;
    NSTimeInterval duration = [dictionary[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [dictionary[UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.frame = frame;
    } completion:nil];
}

- (CGRect)frameWithLine: (NSUInteger)line andRow: (NSUInteger)row andIsLongBtn: (BOOL)longBtn {
    CGFloat x = longBtn?margin:(margin + row *(margin + self.btnWidth));
    CGFloat y = margin + line * (margin + btnHeight);
    CGRect newFrame = CGRectMake(x, y, self.btnWidth + (longBtn?(self.btnWidth + margin):0), btnHeight);
    return newFrame;
}

- (void)selectRange: (NSUInteger)index {
    
    NSString *addrStr = [self.addrArr objectAtIndex:index];
    NSInteger lastLength = [addrStr componentsSeparatedByString:@"."].lastObject.length;
    NSArray<NSString *> *arr = [[addrStr componentsSeparatedByString:@"."].lastObject componentsSeparatedByString:@":"];
    if (arr.count == 1 || [addrStr componentsSeparatedByString:@"."].count == 1) {
        return;
    }
    NSInteger length = arr.firstObject.length;
    NSRange range = NSMakeRange(addrStr.length - lastLength, length);
    UITextPosition* beginning = self.testAddrField.beginningOfDocument;
    UITextPosition* startPosition = [self.testAddrField positionFromPosition:beginning offset:range.location];
    UITextPosition* endPosition = [self.testAddrField positionFromPosition:beginning offset:range.location + range.length];
    UITextRange* selectionRange = [self.testAddrField textRangeFromPosition:startPosition toPosition:endPosition];
    [self.testAddrField setSelectedTextRange:selectionRange];
}

#pragma mark - 懒加载

- (NSUserDefaults *)userDefault {
    if (!_userDefault) {
        _userDefault = [NSUserDefaults standardUserDefaults];
    }
    return _userDefault;
}

- (CGFloat)btnWidth {
    return (self.frame.size.width - 3 * margin)/2;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.accessibilityIdentifier = @"bgView";
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismiss:)];
        [_bgView addGestureRecognizer:tap];
    }
    _bgView.frame = [UIScreen mainScreen].bounds;
    return _bgView;
}

- (UIButton *)testEnvBtn {
    if (!_testEnvBtn) {
        _testEnvBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _testEnvBtn.selected = [self.userDefault boolForKey:testEnvKey];
        _testEnvBtn.backgroundColor = BTN_COLOR;
        _testEnvBtn.layer.cornerRadius = radius;
        _testEnvBtn.frame = [self frameWithLine:0 andRow:0 andIsLongBtn:NO];
        [_testEnvBtn setTitleColor:SELECTED_COLOR forState:UIControlStateNormal];
        [_testEnvBtn setTitleColor:DISABLED_COLOR forState:UIControlStateDisabled];
        [_testEnvBtn setTitleColor:NORMAL_COLOR forState:UIControlStateSelected];
        [_testEnvBtn setTitle:@"环境: 正式" forState:UIControlStateNormal];
        [_testEnvBtn setTitle:@"环境: 测试" forState:UIControlStateSelected];
        [_testEnvBtn addTarget:self action:@selector(testEnvBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _testEnvBtn;
}

- (UIButton *)uatBtn {
    if (!_uatBtn) {
        _uatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _uatBtn.backgroundColor = BTN_COLOR;
        _uatBtn.layer.cornerRadius = radius;
        _uatBtn.frame = [self frameWithLine:0 andRow:1 andIsLongBtn:NO];
        [_uatBtn setTitleColor:NORMAL_COLOR forState:UIControlStateNormal];
        [_uatBtn setTitleColor:SELECTED_COLOR forState:UIControlStateSelected];
        [_uatBtn setTitleColor:DISABLED_COLOR forState:UIControlStateDisabled];
        [_uatBtn setTitle:@"UAT: 关闭" forState:UIControlStateNormal];
        [_uatBtn setTitle:@"UAT: 开启" forState:UIControlStateSelected];
        [_uatBtn addTarget:self action:@selector(uatBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _uatBtn;
}

- (NSString *)selectedAddr {
    if (!_selectedAddr) {
        NSString *testAddress = [self.userDefault stringForKey:testAddressKey];
        if ([testAddress isEqualToString:@"测试环境地址不可用"]) {
            testAddress = self.addrArr.firstObject;
        }
        _selectedAddr = testAddress?testAddress:self.addrArr.firstObject;
        
    }
    return _selectedAddr;
}

- (UITextField *)testAddrField {
    if (!_testAddrField) {
        _testAddrField = [[UITextField alloc] init];
        _testAddrField.accessibilityIdentifier = @"testAddrField";
        _testAddrField.backgroundColor = BTN_COLOR;
        _testAddrField.placeholder = @"请输入测试环境地址";
        _testAddrField.textColor = NORMAL_COLOR;
        _testAddrField.inputView = self.addressPicker;
        _testAddrField.delegate = self;
        _testAddrField.layer.cornerRadius = radius;
        _testAddrField.borderStyle = UITextBorderStyleNone;
        _testAddrField.keyboardType = UIKeyboardTypeURL;
        _testAddrField.frame = [self frameWithLine:1 andRow:0 andIsLongBtn:YES];
        _testAddrField.textAlignment = NSTextAlignmentCenter;
        _testAddrField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _testAddrField;
}

- (UIButton *)szHostBtn {
    if (!_szHostBtn) {
        _szHostBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _szHostBtn.backgroundColor = BTN_COLOR;
        [_szHostBtn setTitle:@"使用杭州环境" forState:UIControlStateNormal];
        [_szHostBtn setTitle:@"使用苏州环境" forState:UIControlStateSelected];
        [_szHostBtn setTitle:@"使用测试环境" forState:UIControlStateDisabled];
        [_szHostBtn setTitleColor:NORMAL_COLOR forState:UIControlStateNormal];
        [_szHostBtn setTitleColor:SELECTED_COLOR forState:UIControlStateSelected];
        [_szHostBtn setTitleColor:DISABLED_COLOR forState:UIControlStateDisabled];
        _szHostBtn.layer.cornerRadius = radius;
        _szHostBtn.frame = [self frameWithLine:2 andRow:0 andIsLongBtn:YES];
        [_szHostBtn addTarget:self action:@selector(encRequestMsgBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _szHostBtn;
}

- (UIButton *)encRequestMsgBtn {
    if (!_encRequestMsgBtn) {
        _encRequestMsgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _encRequestMsgBtn.backgroundColor = BTN_COLOR;
        [_encRequestMsgBtn setTitle:@"请求不加密" forState:UIControlStateNormal];
        [_encRequestMsgBtn setTitle:@"请求加密" forState:UIControlStateSelected];
        [_encRequestMsgBtn setTitleColor:NORMAL_COLOR forState:UIControlStateNormal];
        [_encRequestMsgBtn setTitleColor:SELECTED_COLOR forState:UIControlStateSelected];
        [_encRequestMsgBtn setTitleColor:DISABLED_COLOR forState:UIControlStateDisabled];
        _encRequestMsgBtn.layer.cornerRadius = radius;
        _encRequestMsgBtn.frame = [self frameWithLine:2 andRow:0 andIsLongBtn:NO];
        [_encRequestMsgBtn addTarget:self action:@selector(encRequestMsgBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _encRequestMsgBtn;
}

- (UIButton *)encReturnMsgBtn {
    if (!_encReturnMsgBtn) {
        _encReturnMsgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _encReturnMsgBtn.backgroundColor = BTN_COLOR;
        [_encReturnMsgBtn setTitle:@"返回不加密" forState:UIControlStateNormal];
        [_encReturnMsgBtn setTitle:@"返回加密" forState:UIControlStateSelected];
        [_encReturnMsgBtn setTitleColor:NORMAL_COLOR forState:UIControlStateNormal];
        [_encReturnMsgBtn setTitleColor:SELECTED_COLOR forState:UIControlStateSelected];
        [_encReturnMsgBtn setTitleColor:DISABLED_COLOR forState:UIControlStateDisabled];
        _encReturnMsgBtn.layer.cornerRadius = radius;
        _encReturnMsgBtn.frame = [self frameWithLine:2 andRow:1 andIsLongBtn:NO];
        [_encReturnMsgBtn addTarget:self action:@selector(encReturnMsgBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _encReturnMsgBtn;
}

- (UIButton *)testBtn {
    if (!_testBtn) {
        _testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _testBtn.backgroundColor = BTN_COLOR;
        [_testBtn setTitle:[NSString stringWithFormat:@"TEST.%@：关",testFunctionName] forState:UIControlStateNormal];
        [_testBtn setTitle:[NSString stringWithFormat:@"TEST.%@：开",testFunctionName] forState:UIControlStateSelected];
        [_testBtn setTitleColor:NORMAL_COLOR forState:UIControlStateNormal];
        [_testBtn setTitleColor:SELECTED_COLOR forState:UIControlStateSelected];
        [_testBtn setTitleColor:DISABLED_COLOR forState:UIControlStateDisabled];
        _testBtn.layer.cornerRadius = radius;
        _testBtn.frame = [self frameWithLine:2 andRow:0 andIsLongBtn:YES];
        [_testBtn addTarget:self action:@selector(testBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _testBtn;
}

- (UIPickerView *)addressPicker {
    if (!_addressPicker) {
        _addressPicker = [[UIPickerView alloc] init];
        _addressPicker.delegate = self;
        _addressPicker.dataSource = self;
        if ([self.addrArr containsObject:self.selectedAddr]) {
            NSInteger index = [self.addrArr indexOfObject:self.selectedAddr];
            [_addressPicker selectRow:index inComponent:0 animated:YES];
        }
    }
    return _addressPicker;
}

- (NSArray *)addrArr {
    if (!_addrArr) {
        _addrArr = @[@"http://test.yintong.com.cn",@"http://dev2.lianlianpay.com",@"http://192.168.110.69:8080",@"http://192.168.110.12:8080",@"http://192.168.110.13:8080",@"http://192.168.10.113:8080",@"http://10.20.102.24:8080",@"http://"];
    }
    return _addrArr;
}
#pragma mark - 点击方法

- (void)tapToDismiss: (UITapGestureRecognizer *)tap {
    [self hide:YES];
}

- (void)swipeToDismiss: (UISwipeGestureRecognizer *)swipe {
    [self hide:YES];
}

- (void)testEnvBtnTouched: (UIButton *)sender {
    if (sender.isSelected) {
        self.selectedAddr = self.testAddrField.text;
    }
    sender.selected = !sender.selected;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshUI];
    });
}

- (void)uatBtnTouched: (UIButton *)sender {
    sender.selected = !sender.selected;
}

- (void)encRequestMsgBtnTouched: (UIButton *)sender {
    sender.selected = !sender.selected;
}

- (void)encReturnMsgBtnTouched: (UIButton *)sender {
    sender.selected = !sender.selected;
}

- (void)testBtnTouched: (UIButton *)sender {
    sender.selected = !sender.selected;
}

#pragma mark - Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.testAddrField.inputView = self.addressPicker;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.testAddrField.inputView = self.addressPicker;
    [textField resignFirstResponder];
}

#pragma mark -- PickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.addrArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.addrArr objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.testAddrField.text = [self.addrArr objectAtIndex:row];
    self.selectedAddr = self.testAddrField.text;
    [self.testAddrField resignFirstResponder];
    self.testAddrField.inputView = nil;
    [self.testAddrField becomeFirstResponder];
    [self selectRange:row];
//    if (row != self.addrArr.count-1 && row > 1) {
//    }
}

#pragma mark - 数据存储

- (void)saveData {
    [self.userDefault setBool:self.testEnvBtn.selected forKey:testEnvKey];
    [self.userDefault setBool:self.uatBtn.selected forKey:uatKey];
    if (self.testEnvBtn.selected) {
        [self.userDefault setValue:self.testAddrField.text forKey:testAddressKey];
    }
    [self.userDefault setBool:self.szHostBtn.isSelected forKey:szHostKey];
    [self.userDefault setObject:self.encRequestMsgBtn.selected?@"enable":@"disable" forKey:encRequestMsgKey];
    [self.userDefault setObject:self.encReturnMsgBtn.selected?@"enable":@"disable" forKey:encReturnMsgKey];
    
    [self.userDefault setBool:self.testBtn.selected forKey:funcTestKey];
    [self.userDefault synchronize];
}

- (void)loadData {
    self.testEnvBtn.selected = [self.userDefault boolForKey:testEnvKey];
    self.uatBtn.selected = self.testEnvBtn.selected?NO:[self.userDefault boolForKey:uatKey];
    
    self.szHostBtn.selected = [self.userDefault boolForKey:szHostKey];
    
    NSString *str = [self.userDefault stringForKey:encRequestMsgKey];
    self.encRequestMsgBtn.selected = str?[str isEqualToString:@"enable"]:YES;
    
    NSString *str2 = [self.userDefault stringForKey:encReturnMsgKey];
    self.encReturnMsgBtn.selected = str2?[str2 isEqualToString:@"enable"]:YES;
    
    self.testBtn.selected = [self.userDefault boolForKey:funcTestKey];
}

- (void)refreshUI {
//    测试环境
    if (self.testEnvBtn.isSelected) {
        self.uatBtn.selected = NO;
        self.szHostBtn.selected = NO;
        self.testAddrField.text = self.selectedAddr;
        self.testAddrField.textColor = NORMAL_COLOR;
    }
//    正式环境
    else {
        self.uatBtn.selected = [self.userDefault boolForKey:uatKey];
        self.testAddrField.text = @"测试环境地址不可用";
        self.testAddrField.textColor = DISABLED_COLOR;
    }
    
    self.uatBtn.enabled = !self.testEnvBtn.isSelected;
    self.szHostBtn.enabled = !self.testEnvBtn.isSelected;
    self.testAddrField.enabled = self.testEnvBtn.isSelected;

}

#pragma mark - 类方法

+ (BOOL)isDebug {
#ifdef DEBUG
    return YES;
#endif
    return NO;
}

+ (BOOL)isTestEnv {
    return [LLEnvCtrlView isDebug]?[[NSUserDefaults standardUserDefaults] boolForKey:testEnvKey]:NO;
}

+ (void)show: (BOOL)animated {
    [[[self alloc] init] show:animated];
}

@end
