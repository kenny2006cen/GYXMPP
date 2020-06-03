//
//  HMOffDelayTimeCmd.m
//  HomeMate
//
//  Created by liuzhicai on 16/3/14.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMOffDelayTimeCmd.h"

@implementation HMOffDelayTimeCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_OD;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:@(self.delayTime) forKey:@"delayTime"];
    [sendDic setObject:@(self.isEnable) forKey:@"isEnable"];
    
    return sendDic;
}

@end
