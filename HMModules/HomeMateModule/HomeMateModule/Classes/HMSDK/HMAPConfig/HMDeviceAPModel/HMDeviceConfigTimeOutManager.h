//
//  HmTimeOutManager.h
//  HomeMate
//
//  Created by Orvibo on 15/8/19.
//  Copyright © 2017年 Orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMAPConfigMsg.h"

@interface HMDeviceConfigTimeOutManager : NSObject
+ (HMDeviceConfigTimeOutManager *)getTimeOutManager;
- (void)addVhAPConfigMsg:(HMAPConfigMsg *)msg;
- (NSTimeInterval)removeMsg:(HMAPConfigMsg *)msg;
- (void)removAllMsg;
@end
