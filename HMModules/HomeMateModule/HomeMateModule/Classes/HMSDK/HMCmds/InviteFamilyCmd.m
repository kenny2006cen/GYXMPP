//
//  InviteFamilyCmd.m
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "InviteFamilyCmd.h"

@implementation InviteFamilyCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_FAMILY_INVITE;
}

-(NSDictionary *)payload
{
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    
    if (self.userName) {
        [sendDic setObject:self.userName forKey:@"userName"];
    }
    [sendDic setObject:@(self.userType) forKey:@"userType"];
    if (self.authority) {
        [sendDic setObject:self.authority forKey:@"authority"];
    }
    
    if (self.extAddr.length) {
        [sendDic setObject:self.extAddr forKey:@"extAddr"];
    }
    
    [sendDic setObject:@(self.authorizedId) forKey:@"authorizedId"];

    
    return sendDic;
}

@end
