//
//  LLUIModel.m
//  LianLianPay
//
//  Created by EvenLam on 2017/8/15.
//  Copyright © 2017年 LianLianPay. All rights reserved.
//

#import "LLUIModel.h"
#import "LLTextField.h"
#import "LLConsts.h"

@implementation LLUIModel

- (instancetype)initWithPlist: (NSString *)name
{
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
        [self setValuesForKeysWithDictionary:dic];
//        [self parseFields];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (NSDictionary *)getFieldsData {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (LLTextField *field in self.textFields) {
        [dic setValue:field.text.length > 0?field.text:nil forKey:field.key];
    }
    return [dic copy];
}

- (NSDictionary *)fieldsDataWithArray: (NSArray *)arr {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (LLTextField *field in self.textFields) {
        if ([arr containsObject:field.key]) {
            [dic setValue:field.text.length > 0?field.text:nil forKey:field.key];
        }
    }
    return [dic copy];
}

- (void)reloadFields {
    for (LLTextField *field in self.textFields) {
        [field reloadField];
    }
}

- (void)parseFields {
    NSMutableArray *merchantFieldsArr = [@[] mutableCopy];
    NSMutableArray *userFieldsArr = [@[] mutableCopy];
    NSMutableArray *textFieldsArr = [@[] mutableCopy];
    for (NSString *key in self.textFields) {
        LLTextFieldModel *model = [[LLTextFieldModel alloc] initWithKey:key];
        LLTextField *field = [[LLTextField alloc] initWithKey:key andTarget:self.target];
        [textFieldsArr addObject:field];
        if ([model.type isEqualToString:@"user"]) {
            [userFieldsArr addObject:field];
        }else {
            [merchantFieldsArr addObject:field];
        }
    }
    self.merchantFields = [merchantFieldsArr copy];
    self.userFields = [userFieldsArr copy];
    self.textFields = [textFieldsArr copy];
}
@end
