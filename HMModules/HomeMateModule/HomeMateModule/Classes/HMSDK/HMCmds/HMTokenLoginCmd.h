//
//  HMTokenLoginCmd.h
//  HomeMateSDK
//
//  Created by Alic on 2020/4/23.
//  Copyright © 2020 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface HMTokenLoginCmd : BaseCmd

/// 自动登录的token
@property (nonatomic, strong) NSString * accessToken;

@end
