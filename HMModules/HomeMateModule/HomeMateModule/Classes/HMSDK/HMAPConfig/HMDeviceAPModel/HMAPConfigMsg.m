//
//  VhAPConfigMsg.m
//  HomeMateSDK
//
//  Created by Orvibo on 15/8/6.
//  Copyright © 2017年 Orvibo. All rights reserved.
//

#import "HMAPConfigMsg.h"
#import "HMDeviceConfig.h"

@implementation HMAPConfigMsg

- (void)doTimeout {

    [[HMDeviceConfig defaultConfig] onTimeout:self];
}

/**
 *	@brief	设置超时起始时间
 */
-(void)startTimeout
{
    self.startTimestamp = [NSDate date];
}

/**
 *	@brief	获得超时起始时间
 *
 *	@return 起始时间
 */
-(NSDate*)getStartTime
{
    return _startTimestamp;
}
/**
 *	@brief	获得设定的超时时间
 *
 *	@return	超时时间
 */
-(NSInteger)getTimeoutTime
{
    return self.timeoutSeconds;
}
@end
