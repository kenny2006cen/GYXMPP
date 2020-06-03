//
//  SetGenaralGateCmd.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/9/7.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "SetGenaralGateCmd.h"

@implementation SetGenaralGateCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SET_GENERAL_GATE;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:self.generalGate forKey:@"generalGate"];
    return sendDic;
}

@end
