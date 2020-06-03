//
//  HMQueryNotificationAuthorityCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2018/9/5.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMQueryNotificationAuthorityCmd.h"

@implementation HMQueryNotificationAuthorityCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_NOTIFI_AUTHORITY;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.familyId forKey:@"familyId"];
    [sendDic setObject:@(self.authorityType) forKey:@"authorityType"];
    if (self.objId) {
        [sendDic setObject:self.objId forKey:@"objId"];
    }
    return sendDic;
}

@end

