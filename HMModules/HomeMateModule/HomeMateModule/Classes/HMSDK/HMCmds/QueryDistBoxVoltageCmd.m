//
//  QueryDistBoxVoltageCmd.m
//  HomeMateSDK
//
//  Created by liuzhicai on 17/2/9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryDistBoxVoltageCmd.h"

@implementation QueryDistBoxVoltageCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_POWERCONFIG_DEVICE;
}

-(NSDictionary *)payload
{
    if (self.extAddr) {
        [sendDic setObject:self.extAddr forKey:@"extAddr"];
    }
    return sendDic;
}

@end
