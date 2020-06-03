//
//  OrviboLockEditUserCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/17.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "OrviboLockEditUserCmd.h"

@implementation OrviboLockEditUserCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ORVIBO_LOCK_EDIT_USER;
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
    if (self.pwd2) {
        [sendDic setObject:self.pwd2 forKey:@"pwd2"];
    }
    if (self.pwd1) {
        [sendDic setObject:self.pwd1 forKey:@"pwd1"];
    }
    if (self.fp1) {
        [sendDic setObject:self.fp1 forKey:@"fp1"];
    }
    if (self.fp2) {
        [sendDic setObject:self.fp2 forKey:@"fp2"];
    }
    if (self.fp3) {
        [sendDic setObject:self.fp3 forKey:@"fp3"];
    }
    if (self.fp4) {
        [sendDic setObject:self.fp4 forKey:@"fp4"];
    }
    if (self.rf1) {
        [sendDic setObject:self.rf1 forKey:@"rf1"];
    }
    if (self.rf2) {
        [sendDic setObject:self.rf2 forKey:@"rf2"];
    }
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if (self.userUpdateTime) {
        [sendDic setObject:@(self.userUpdateTime) forKey:@"userUpdateTime"];
    }
    [sendDic setObject:@(self.delFlag) forKey:@"delFlag"];

    return sendDic;
}
@end
