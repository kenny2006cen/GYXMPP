//
//  OrviboLockDeleteUser.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/17.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "OrviboLockDeleteUserCmd.h"

@implementation OrviboLockDeleteUserCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ORVIBO_LOCK_DELETE_USER;
}
-(NSDictionary *)payload
{
    if (self.extAddr.length) {
        [sendDic setObject:self.extAddr forKey:@"extAddr"];
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
