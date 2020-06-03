//
//  gatewayBindCmd.m
//  Vihome
//
//  Created by Air on 15-1-29.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "gatewayBindCmd.h"

@implementation gatewayBindCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_GB;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.password forKey:@"password"];
    [sendDic setObject:self.phone forKey:@"phone"];
    [sendDic setObject:self.email forKey:@"email"];
    [sendDic setObject:self.userId forKey:@"userId"];
    [sendDic setObject:self.familyId forKey:@"familyId"];
    [sendDic setObject:[NSNumber numberWithInt:self.userType] forKey:@"userType"];
    [sendDic setObject:[NSNumber numberWithInt:self.registerType] forKey:@"registerType"];
    [sendDic setObject:self.language forKey:@"language"];
    [sendDic setObject:@(self.utcTime) forKey:@"utcTime"];
    [sendDic setObject:@(self.zoneOffset) forKey:@"zoneOffset"];
    [sendDic setObject:@(self.dstOffset) forKey:@"dstOffset"];
    return sendDic;
}

@end
