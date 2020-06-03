//
//  HMAPLockAPI.m
//  HomeMateSDK
//
//  Created by liqiang on 2019/2/28.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMAPLockAPI.h"
#import "HMAPConfigAPI.h"
#import "HMDeviceConfig.h"

@implementation HMAPLockAPI
/**
 设置d回调
 
 @param delegate delegate
 */
+ (void)setAPConfigDelegate:(id<VhAPConfigDelegate>)delegate {
    
    [HMDeviceConfig defaultConfig].delegate = delegate;

}
@end
