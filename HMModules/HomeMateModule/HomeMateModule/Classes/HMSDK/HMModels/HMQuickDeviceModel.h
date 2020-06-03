//
//  HMQuickDeviceModel.h
//  HomeMateSDK
//
//  Created by Feng on 2019/8/12.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMQuickDeviceModel : HMBaseModel
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * deviceId;
@property (nonatomic, strong) NSString * deviceName;
@property (nonatomic, strong) NSString * timestamp;
@property (nonatomic, assign) int weight;
@end
