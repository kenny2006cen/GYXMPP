//
//  ActiveTimingGroupCmd.m
//  HomeMate
//
//  Created by Air on 16/7/8.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "ActiveTimingGroupCmd.h"

@implementation ActiveTimingGroupCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ACTIVATE_TIMEMODEL;
}
-(NSDictionary *)payload
{
    [sendDic setObject:self.timingGroupId forKey:@"timingGroupId"];
    [sendDic setObject:@(self.isPause) forKey:@"isPause"];
    
    return sendDic;
}

@end
