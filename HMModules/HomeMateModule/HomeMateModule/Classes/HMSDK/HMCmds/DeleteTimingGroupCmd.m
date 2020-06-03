//
//  DeleteTimingGroupCmd.m
//  HomeMate
//
//  Created by Air on 16/7/8.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "DeleteTimingGroupCmd.h"

@implementation DeleteTimingGroupCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DELETE_TIMEMODEL;
}
-(NSDictionary *)payload
{
    [sendDic setObject:self.timingGroupId forKey:@"timingGroupId"];
    
    return sendDic;
}

@end
