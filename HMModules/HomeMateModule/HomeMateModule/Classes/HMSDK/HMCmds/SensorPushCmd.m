//
//  SensorPushCmd.m
//  HomeMate
//
//  Created by Air on 15/10/13.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "SensorPushCmd.h"
#import "HMConstant.h"


@implementation SensorPushCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SP;
}

- (void)setWeek:(int)week {
    _week = week;
    _hasWeekValue = YES;
}

-(NSDictionary *)payload
{
    [super payload];
    
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
    
    if (self.startTime) {
        [sendDic setObject:self.startTime forKey:@"startTime"];
    }else {
        
        // 服务器默认要求填 00：00：00
        [sendDic setObject:@"00:00:00" forKey:@"startTime"];
    }
    
    if (self.endTime) {
        [sendDic setObject:self.endTime forKey:@"endTime"];
    }else {
        [sendDic setObject:@"00:00:00" forKey:@"endTime"];
    }
    
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    
    [sendDic setObject:@(self.authorizedId) forKey:@"authorizedId"];
    [sendDic setObject:@(self.week) forKey:@"week"];
    
    [sendDic setObject:@(self.day) forKey:@"day"];

    
    // 用户没有设week值时，默认填255，表示所有周都生效
    if (!self.hasWeekValue) {
        [sendDic setObject:@(255) forKey:@"week"];
    }
    return sendDic;
}

@end
