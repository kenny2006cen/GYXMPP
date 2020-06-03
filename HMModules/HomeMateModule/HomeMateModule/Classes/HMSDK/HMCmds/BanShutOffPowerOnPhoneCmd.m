//
//  BanShutOffPowerOnPhoneCmd.m
//  HomeMate
//
//  Created by liuzhicai on 16/7/27.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "BanShutOffPowerOnPhoneCmd.h"

@implementation BanShutOffPowerOnPhoneCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_POWER_ONOFF;
}

-(NSDictionary *)payload
{
    [sendDic setObject:@(self.isEnable) forKey:@"isEnable"];
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    return sendDic;
}


@end
