//
//  JoinFamilyAsAdminCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/6/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "JoinFamilyAsAdminCmd.h"

@implementation JoinFamilyAsAdminCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_JOIN_FAMILY_AS_ADMIN;
}

-(NSDictionary *)payload
{
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    
    return sendDic;
}
@end
