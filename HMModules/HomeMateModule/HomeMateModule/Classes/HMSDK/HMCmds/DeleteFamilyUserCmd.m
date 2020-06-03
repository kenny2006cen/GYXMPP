//
//  DeleteFamilyUserCmd.m
//  HomeMateSDK
//
//  Created by user on 17/2/9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeleteFamilyUserCmd.h"

@implementation DeleteFamilyUserCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DELETE_FAMILY_USERS;
}

-(NSDictionary *)payload
{
    if (self.familyUserId) {
        [sendDic setObject:self.familyUserId forKey:@"familyUserId"];
    }
    return sendDic;
}

@end
