//
//  ModifyFamilyUsers.m
//  HomeMateSDK
//
//  Created by user on 17/2/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyFamilyUsersCmd.h"

@implementation ModifyFamilyUsersCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MODIFY_FAMILY_USERS;
}

-(NSDictionary *)payload
{
    if (self.familyUserId) {
        [sendDic setObject:self.familyUserId forKey:@"familyUserId"];
    }
    if (self.nicknameInFamily) {
        [sendDic setObject:self.nicknameInFamily forKey:@"nicknameInFamily"];
    }
    return sendDic;
}


@end
