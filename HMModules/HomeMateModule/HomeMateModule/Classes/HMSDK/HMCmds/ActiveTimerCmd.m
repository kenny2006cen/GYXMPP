//
//  ActiveTimerCmd.m
//  Vihome
//
//  Created by Ned on 3/25/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ActiveTimerCmd.h"

@implementation ActiveTimerCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ACT;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.timingId forKey:@"timingId"];
    [sendDic setObject:[NSNumber numberWithInt:self.isPause] forKey:@"isPause"];

    return sendDic;
}

@end
