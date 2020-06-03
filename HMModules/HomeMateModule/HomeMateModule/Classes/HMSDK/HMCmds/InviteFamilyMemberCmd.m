//
//  InviteFamilyMemberCmd.m
//  HomeMate
//
//  Created by Air on 15/9/9.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "InviteFamilyMemberCmd.h"

@implementation InviteFamilyMemberCmd
@synthesize userName;
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_IFM;
}

-(NSDictionary *)payload
{
    if (self.userName) {
        [sendDic setObject:self.userName forKey:@"userName"];
    }
    if (self.uid) {
        [sendDic setObject:self.uid forKey:@"uid"];
    }
    if (self.inviteType) {
        [sendDic setObject:@(self.inviteType) forKey:@"inviteType"];
    }
    return sendDic;
}


@end
