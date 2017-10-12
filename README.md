# LLTokenPaySDK

[![CI Status](http://img.shields.io/travis/LLPayiOSDev/LLTokenPaySDK.svg?style=flat)](https://travis-ci.org/LLPayiOSDev/LLTokenPaySDK)
[![Version](https://img.shields.io/cocoapods/v/LLTokenPaySDK.svg?style=flat)](http://cocoapods.org/pods/LLTokenPaySDK)
[![License](https://img.shields.io/cocoapods/l/LLTokenPaySDK.svg?style=flat)](http://cocoapods.org/pods/LLTokenPaySDK)
[![Platform](https://img.shields.io/cocoapods/p/LLTokenPaySDK.svg?style=flat)](http://cocoapods.org/pods/LLTokenPaySDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

LLTokenPaySDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LLTokenPaySDK'
```

## Author

LLPayiOSDev, iosdev@yintong.com.cn

## 如何调用

1. 导入头文件 #import <LLTokenPaySDK/LLTokenPaySDK.h>
2. 由服务端创单获取到 Token， iOS 客户端使用此Token以及其他必传参数调用SDK
```
NSDictionary *orderParam = @{*****}; // 创建订单
self.sdk = [LLTokenPaySDK sharedSdk]; // 创建SDK
NSMutableDictionary *paymentInfo = [NSMutableDictionary dictionary]; //包含Token字段的字典
//组织paymentInfo
[[LLTokenPaySDK sharedSdk] payApply:self.currentPaymentInfo
inVC:self
completion:^(LLPayResult result, NSDictionary *dic) {
//根据result和dic作出不同处理
}];
```

### LLTokenPaySDK可配置部分
---

> iOS SDK可以通过修改资源bundle进行定制， 因为是在bundle里面，请在修改好以后 **clean proj**，这样才会生效。

1. 图片的替换，在内部的图片可以替换修改为自己的样式
2. 颜色等的修改，可以修改default.css文件，支持#abcdef，123,123,123两种颜色表示, 连连的主色调是#00a0e9 , 如需更换可替换成商户自己的主色调
3. 修改值意义列表

|修改的对象    |修改方法|
|--------    |-------|
|导航栏颜色    |替换ll_nav_bg3.png文件，以及修改css文件中NavBar字段（后面只表示字段，都是在default.css文件中）中的background-color|
|标题|CusTitle字段， 暂时只能定义首次支付界面与Alert标题|



4. 参数字段部分
- 参数说明在demo中有，可以参考。字段名和wap不一致，请参考Demo中的参数说明，参数中的user_id 不是商户号，是商户自己体系中的用户编号，前置卡输入时，no_agree是通过API查询得到的绑卡序号

5. 使用部分
- Demo中的输入项，是用来测试各种支付条件，包括认证支付（输入姓名，身份证），前置支付（输入卡号，协议号）。不是必须，请根据自己的支付方式测试。
- 支持银行数量，是根据支付类型以及商户来，可以配置，请联系运营。

## License

LLTokenPaySDK is available under the MIT license. See the LICENSE file for more info.
