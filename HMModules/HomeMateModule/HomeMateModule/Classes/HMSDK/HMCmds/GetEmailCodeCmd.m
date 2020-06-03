//
//  GetEmailCodeCmd.m
//  CloudPlatform
//
//  Created by orvibo on 15/6/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "GetEmailCodeCmd.h"

@implementation GetEmailCodeCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_GETEMAILCODE;
}

-(NSDictionary *)payload
{
    if (self.email) {
        
        // 修复bug 9193，将email转小写
        [sendDic setObject:self.email.lowercaseString forKey:@"email"];
    }
    [sendDic setObject:@(self.type) forKey:@"type"];
    return sendDic;
}

@end
