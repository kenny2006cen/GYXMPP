//
//  HMCountdownAPI.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/5/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMCountdownAPI.h"
#import "HMCountDownBusiness.h"

@implementation HMCountdownAPI

+ (void)setCountDownWithDeviceId:(NSString *)deviceId uid:(NSString *)uid value1:(int)value1 time:(int)time completion:(commonBlockWithObject)completion {
    [HMCountDownBusiness setCountDownWithDeviceId:deviceId uid:uid value1:value1 time:time completion:completion];
}

+ (void)modifyCountDownObj:(HMCountdownModel *)cdModel value1:(int)value1 time:(int)time completion:(commonBlockWithObject)completion{
    [HMCountDownBusiness modifyCountDownObj:cdModel value1:value1 time:time completion:completion];
}

+ (void)deleteCountDownObj:(HMCountdownModel *)cdModel completion:(commonBlockWithObject)completion {
    [HMCountDownBusiness deleteCountDownObj:cdModel completion:completion];
}


+ (void)activateCountDownObj:(HMCountdownModel *)cdModel isPause:(BOOL)isPause completion:(commonBlockWithObject)completion {
    [HMCountDownBusiness activateCountDownObj:cdModel isPause:isPause completion:completion];
}

@end
