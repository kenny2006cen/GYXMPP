//
//  SetPowerOnStateCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2019/10/15.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import <HomeMateSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface SetPowerOnStateCmd : BaseCmd
@property (nonatomic, strong) NSString * deviceId;
@property (nonatomic, assign) int status;//0 以前状态 1 关 2开 3 翻转
@end

NS_ASSUME_NONNULL_END
