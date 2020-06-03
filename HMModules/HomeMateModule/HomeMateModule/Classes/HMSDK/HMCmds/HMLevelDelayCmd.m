//
//  HMLevelDelayCmd.m
//  HomeMate
//
//  Created by liuzhicai on 16/3/14.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMLevelDelayCmd.h"

@implementation HMLevelDelayCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_LD;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:@(self.delayTime) forKey:@"delayTime"];
    [sendDic setObject:@(self.isEnable) forKey:@"isEnable"];
    if (self.paramId) {
        [sendDic setObject:self.paramId forKey:@"paramId"];
    }
    
    return sendDic;
}


@end
