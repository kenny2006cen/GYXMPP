//
//  HMCountDownBusiness.h
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/5/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseBusiness.h"

@interface HMCountDownBusiness : HMBaseBusiness

+ (void)setCountDownWithDeviceId:(NSString *)deviceId uid:(NSString *)uid value1:(int)value1 time:(int)time completion:(commonBlockWithObject)completion;

+ (void)modifyCountDownObj:(HMCountdownModel *)cdModel value1:(int)value1 time:(int)time completion:(commonBlockWithObject)completion;

+ (void)deleteCountDownObj:(HMCountdownModel *)cdModel completion:(commonBlockWithObject)completion;

+ (void)activateCountDownObj:(HMCountdownModel *)cdModel isPause:(BOOL)isPause completion:(commonBlockWithObject)completion;

@end
