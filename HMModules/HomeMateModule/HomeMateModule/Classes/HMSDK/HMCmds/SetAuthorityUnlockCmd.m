//
//  SetAuthorityUnlockCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/23.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "SetAuthorityUnlockCmd.h"

@implementation SetAuthorityUnlockCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SET_AUTHORITY_UNLOCK;
}
-(NSDictionary *)payload
{
    if (self.deviceId.length) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    //if(self.startTime > 0){
        [sendDic setObject:@(self.startTime) forKey:@"startTime"];
    //}
    if (self.effectTime > 0) {
        [sendDic setObject:@(self.effectTime) forKey:@"effectTime"];
    }
    //if(self.endTime > 0) {
        [sendDic setObject:@(self.endTime) forKey:@"endTime"];
    //}
    [sendDic setObject:@(self.type) forKey:@"type"];

    [sendDic setObject:@(self.number) forKey:@"number"];
    
    if (self.authorityUserName.length) {
        [sendDic setObject:self.authorityUserName forKey:@"userName"];
    }
    if (self.phone) {
        [sendDic setObject:self.phone forKey:@"phone"];
    }
    
    if (self.unencryptedPassword) {
        [sendDic setObject:self.unencryptedPassword forKey:@"unencryptedPassword"];
    }
    
    if (self.day) {
        [sendDic setObject:self.day forKey:@"day"];
    }
    
    [sendDic setObject:@(self.pwdGenerateType) forKey:@"pwdGenerateType"];
    
    if (self.password) {
        [sendDic setObject:self.password forKey:@"password"];
    }
    
    // 开锁消息提醒开关，默认打开
    if (self.isPush) {
        [sendDic setObject:@([self.isPush intValue]) forKey:@"isPush"];
    }
    
    [sendDic setObject:@(self.pwdUseType) forKey:@"pwdUseType"];
    
    [sendDic setObject:@(self.system) forKey:@"system"];
    
    return sendDic;
}
@end
