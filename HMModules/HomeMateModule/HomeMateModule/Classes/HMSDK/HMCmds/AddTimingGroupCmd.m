//
//  AddTimingGroupCmd.m
//  HomeMate
//
//  Created by Air on 16/7/8.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "AddTimingGroupCmd.h"

@implementation AddTimingGroupCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ADD_TIMEMODEL;
}
-(NSDictionary *)payload
{
    if (self.timingGroup) {
        [sendDic setObject:self.timingGroup forKey:@"timingGroup"];
    }
    if (self.timingList) {
        [sendDic setObject:self.timingList forKey:@"timingList"];
    }
    
    return sendDic;
}

@end
