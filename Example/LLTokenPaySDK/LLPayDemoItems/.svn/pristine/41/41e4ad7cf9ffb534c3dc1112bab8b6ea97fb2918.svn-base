//
//  LLHeaderView.m
//  LianLianPay
//
//  Created by EvenLam on 2017/8/15.
//  Copyright © 2017年 LianLianPay. All rights reserved.
//

#import "LLHeaderView.h"
#import "LLConsts.h"

@interface LLHeaderView ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;

@end

@implementation LLHeaderView

- (instancetype)initWithFrame:(CGRect)frame withName: (NSString *)name andUrl: (NSString *)url {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = kLLNavColor;
        self.name = name;
        self.url = url;
        [self tableHeaderView];
    }
    return self;
}

- (UIView *)tableHeaderView {
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:28];
    label.frame = CGRectMake(10, 15, 200, 30);
    label.text = self.name;
    [self addSubview:label];
    label.userInteractionEnabled = YES;
    if (self.url.length > 0) {
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 200, 20)];
        label2.font = [UIFont systemFontOfSize:12];
        label2.textColor = [UIColor lightGrayColor];
        label2.text = @"查看并下载最新Demo";
        [self addSubview:label2];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadNewDemo)];
        [self addGestureRecognizer:tap];
    }else {
        self.frame = CGRectMake(0, 0, self.frame.size.width, 45);
    }
    return self;
}

- (void)downloadNewDemo {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
}

@end
