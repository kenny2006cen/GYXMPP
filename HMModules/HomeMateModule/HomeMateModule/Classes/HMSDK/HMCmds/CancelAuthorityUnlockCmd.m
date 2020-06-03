//
//  CancelAuthorityUnlockCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/23.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "CancelAuthorityUnlockCmd.h"

@implementation CancelAuthorityUnlockCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_CANCEL_AUTHORITY_UNLOCK;
}
-(NSDictionary *)payload
{
    if (self.deviceId.length) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    
    [sendDic setObject:@(self.userId) forKey:@"userId"];
    
    return sendDic;
}
@end
