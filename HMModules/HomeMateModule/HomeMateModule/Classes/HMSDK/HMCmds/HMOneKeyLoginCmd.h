//
//  OneKeyLoginCmd.h
//  HomeMateSDK
//
//  Created by wjy on 2020/4/22.
//  Copyright © 2020 orvibo. All rights reserved.
//

#import <HomeMateSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMOneKeyLoginCmd : BaseCmd
@property (nonatomic, strong) NSString * oneKeyToken;//app端SDK获取的一键登录token
@property (nonatomic, strong) NSString * sysVersion;//版本标识
@end

NS_ASSUME_NONNULL_END
