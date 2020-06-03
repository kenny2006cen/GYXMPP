//
//  HMGroupStatus.h
//  HomeMateSDK
//
//  Created by Feng on 2019/9/27.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMDeviceStatus.h"

@class HMDevice;

@interface HMGroupStatus : HMDeviceStatus

+ (HMGroupStatus *)groupStatusForGroupDevice:(HMDevice *)device;
+ (HMGroupStatus *)groupStatusForGroupDeviceId:(NSString *)deviceId;
@end
