//
//  AuthorizedUnlockCmd.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "AuthorizedUnlockCmd.h"

@implementation AuthorizedUnlockCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_AUU;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    if (self.phone) {
        [sendDic setObject:self.phone forKey:@"phone"];
    }
    if(self.time > 0){
        [sendDic setObject:@(self.time) forKey:@"time"];
    }
    if(self.endTime > 0) {
        [sendDic setObject:@(self.endTime) forKey:@"endTime"];
    }
    
    [sendDic setObject:@(self.type) forKey:@"type"];
    [sendDic setObject:@(self.number) forKey:@"number"];
    // 开锁消息提醒开关，默认打开
    if (self.isPush) {
        [sendDic setObject:@([self.isPush intValue]) forKey:@"isPush"];
    }
    return sendDic;
}
@end
