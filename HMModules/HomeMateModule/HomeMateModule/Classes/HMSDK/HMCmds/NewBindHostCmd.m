//
//  NewBindHostCmd.m
//  HomeMateSDK
//
//  Created by liuzhicai on 17/3/9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "NewBindHostCmd.h"

@implementation NewBindHostCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_BIND_HOST;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    [sendDic setObject:self.language forKey:@"language"];
    [sendDic setObject:@(self.zoneOffset) forKey:@"zoneOffset"];
    [sendDic setObject:@(self.dstOffset) forKey:@"dstOffset"];
    return sendDic;
}

@end
