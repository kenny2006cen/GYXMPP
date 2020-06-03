//
//  LoginCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "LoginCmd.h"

@implementation LoginCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_CL;
}

-(NSDictionary *)payload
{
    if (self.password) {
        [sendDic setObject:self.password forKey:@"password"];
    }
    
    // 只有 type = 3 时的登录方式需要填写familyId
    if (self.familyId && (self.type == 3)) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    [sendDic setObject:@(self.type) forKey:@"type"];
    
    return sendDic;
}

@end
