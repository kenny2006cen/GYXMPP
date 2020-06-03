//
//  GetSmsCmd.m
//  Vihome
//
//  Created by Air on 15-1-29.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "GetSmsCmd.h"

@implementation GetSmsCmd


-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_GSC;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.phoneNumber forKey:@"phone"];
    [sendDic setObject:@(self.type) forKey:@"type"];
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
