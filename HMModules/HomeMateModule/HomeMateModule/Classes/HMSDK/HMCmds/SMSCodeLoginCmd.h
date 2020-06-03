//
//  SMSCodeLoginCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2020/4/23.
//  Copyright © 2020 orvibo. All rights reserved.
//

#import <HomeMateSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMSCodeLoginCmd : BaseCmd
//手机号码
@property(nonatomic,copy)NSString * phone;
//国家区号
@property(nonatomic,copy)NSString * areaCode;
//短信验证码
@property(nonatomic,copy)NSString * code;
@end

NS_ASSUME_NONNULL_END
