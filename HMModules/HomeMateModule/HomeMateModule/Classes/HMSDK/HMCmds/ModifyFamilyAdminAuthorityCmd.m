//
//  ModifyFamilyAdminAuthorityCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/6/16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyFamilyAdminAuthorityCmd.h"

@implementation ModifyFamilyAdminAuthorityCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MODIFY_FAMILY_ADMIN_AUTHORITY;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    [sendDic setObject:@(self.isAdmin) forKey:@"isAdmin"];
    
    return sendDic;
}
@end
