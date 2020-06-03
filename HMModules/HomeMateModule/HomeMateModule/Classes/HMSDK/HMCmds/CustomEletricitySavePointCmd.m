//
//  CustomEletricitySavePointCmd.m
//  HomeMate
//
//  Created by liuzhicai on 16/7/27.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "CustomEletricitySavePointCmd.h"

@implementation CustomEletricitySavePointCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_POWER_CUR;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:@(self.isEnable) forKey:@"isEnable"];
    [sendDic setObject:@(self.protectVal) forKey:@"protectVal"];
    [sendDic setObject:@(self.protectTime) forKey:@"protectTime"];
    return sendDic;
}


@end
