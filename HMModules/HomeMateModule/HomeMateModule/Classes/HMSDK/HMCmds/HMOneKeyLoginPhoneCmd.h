//
//  OneKeyLoginPhoneCmd.h
//  HomeMateSDK
//
//  Created by wjy on 2020/4/26.
//  Copyright © 2020 orvibo. All rights reserved.
//

#import <HomeMateSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMOneKeyLoginPhoneCmd : BaseCmd
@property (nonatomic, strong) NSString * oneKeyToken;//app端SDK获取的一键登录token
@property (nonatomic, strong) NSString * phone;//手机号码
@property (nonatomic, strong) NSString * sysVersion;//版本标识
@end

NS_ASSUME_NONNULL_END
