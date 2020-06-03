//
//  DeleteTimerCmd.m
//  Vihome
//
//  Created by Ned on 3/25/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeleteTimerCmd.h"

@implementation DeleteTimerCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DT;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:self.timingId forKey:@"timingId"];
    return sendDic;
}

@end
