//
//  CheckSmsCmd.m
//  Vihome
//
//  Created by Air on 15-1-29.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "CheckSmsCmd.h"

@implementation CheckSmsCmd


-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_CSC;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.authCode forKey:@"code"];
    [sendDic setObject:self.phoneNumber forKey:@"phone"];
    if(self.areaCode.length) {
        [sendDic setObject:self.areaCode forKey:@"areaCode"];
    }
    return sendDic;
}
-(NSString *)userName
{
    return nil;
}

@end
