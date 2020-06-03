//
//  InviteFamilyResponseCmd.m
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "InviteFamilyResponseCmd.h"

@implementation InviteFamilyResponseCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_FAMILY_INVITE_RESPONSE;
}

-(NSDictionary *)payload
{
    if (self.familyInviteId) {
        [sendDic setObject:self.familyInviteId forKey:@"familyInviteId"];
    }
    
    [sendDic setObject:@(self.type) forKey:@"type"];
    
    return sendDic;
}


@end
