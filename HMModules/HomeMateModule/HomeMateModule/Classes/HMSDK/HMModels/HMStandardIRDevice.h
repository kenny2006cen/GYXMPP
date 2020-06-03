//
//  VihomeStandardIRDevice.h
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMStandardIRDevice : HMBaseModel

@property (nonatomic, retain)NSString *         irDeviceId;

@property (nonatomic, retain)NSString *         company;

@property (nonatomic, retain)NSString *         model;

@end
