//
//  LLConsts.h
//  DemoPay
//
//  Created by EvenLam on 2017/7/21.
//  Copyright © 2017年 LianLianPay. All rights reserved.
//

#ifndef LLConsts_h
#define LLConsts_h


#endif /* LLConsts_h */


@import UIKit;

#define kRatioH(h) ((h)*kWindowH/(2*667))
#define kRatioW(w) ((w)*kWindowW/(2*375))
#define kWindowW [UIScreen mainScreen].bounds.size.width
#define kWindowH [UIScreen mainScreen].bounds.size.height

#define LLHexColor(rgbValue)[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define LLColor LLHexColor(0x00a0e9)
#define kLLNavColor LLHexColor(0xffffff)//f6f6f6
