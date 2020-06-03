//
//  VHAPDevice.m
//  HomeMate
//
//  Created by Orvibo on 15/8/11.
//  Copyright © 2017年 Orvibo. All rights reserved.
//

#import "HMAPDevice.h"

@implementation HMAPDevice


- (instancetype)init {
    if (self == [super init]) {
        self.deviceState = -1;
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"deviceName:%@ mac:%@ protocolVersion:%@ softwareVersion:%@ hardwareVersion:%@ modelId:%@",self.deviceName,self.mac,self.protocolVersion,self.softwareVersion,self.hardwareVersion,self.modelId];
}

@end
