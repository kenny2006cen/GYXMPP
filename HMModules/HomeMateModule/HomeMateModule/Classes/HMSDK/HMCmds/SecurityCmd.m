//
//  SecurityCmd.m
//  HomeMate
//
//  Created by orvibo on 16/3/7.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "SecurityCmd.h"

@implementation SecurityCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SCR;
}

-(NSDictionary *)payload
{
    if (self.securityId) {
        [sendDic setObject:self.securityId forKey:@"securityId"];
    }
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    [sendDic setObject:@(self.isArm) forKey:@"isArm"];
    [sendDic setObject:@(self.delay) forKey:@"delay"];
    [sendDic setObject:@(self.checkOnline) forKey:@"checkOnline"];
    return sendDic;
}


@end
