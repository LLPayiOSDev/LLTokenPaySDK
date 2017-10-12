//
//  LLHeaderView.h
//  LianLianPay
//
//  Created by EvenLam on 2017/8/15.
//  Copyright © 2017年 LianLianPay. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat kLLHeaderViewHeight = 65;

@interface LLHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame withName: (NSString *)name andUrl: (NSString *)url;

@end
