//
//  SetPowerConfigureSortList.m
//  HomeMate
//
//  Created by liuzhicai on 16/7/27.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "SetPowerConfigureSortList.h"

@implementation SetPowerConfigureSortList

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_POWER_SORT;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceIdList forKey:@"deviceIdList"];
    return sendDic;
}

@end
