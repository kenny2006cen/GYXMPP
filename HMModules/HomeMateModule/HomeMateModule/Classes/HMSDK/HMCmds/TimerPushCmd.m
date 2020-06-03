//
//  TimerPushCmd.m
//  HomeMate
//
//  Created by liuzhicai on 15/8/24.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "TimerPushCmd.h"

@implementation TimerPushCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_TP;
}

-(NSDictionary *)payload
{
    [sendDic setObject:@(self.type) forKey:@"type"];
    [sendDic setObject:@(self.isPush) forKey:@"isPush"];
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    return sendDic;
}

@end
