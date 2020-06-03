//
//  OrviboLockAddUser.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "OrviboLockAddUserCmd.h"

@implementation OrviboLockAddUserCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ORVIBO_LOCK_ADD_USER;
}
-(NSDictionary *)payload
{
    if (self.extAddr.length) {
        [sendDic setObject:self.extAddr forKey:@"extAddr"];
    }
    if (self.userId.length) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    
    [sendDic setObject:@(self.authorizedId) forKey:@"authorizedId"];
    
    if (self.familyId.length) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.name.length) {
        [sendDic setObject:self.name forKey:@"name"];
    }
    if (self.userUpdateTime) {
        [sendDic setObject:@(self.userUpdateTime) forKey:@"userUpdateTime"];
    }
    return sendDic;
}
@end
