//
//  InviteUserCmd.m
//  HomeMate
//
//  Created by Air on 16/7/19.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "InviteUserCmd.h"
#import "HMTypes.h"

@implementation InviteUserCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_INVITE_USER;
}

-(NSDictionary *)payload
{
    return sendDic;
}

@end
