//
//  UserBindCmd.m
//  CloudPlatform
//
//  Created by orvibo on 15/6/16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "UserBindCmd.h"

@implementation UserBindCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_UB;
}

-(NSDictionary *)payload
{
    [sendDic setObject:[NSNumber numberWithInt:self.Type] forKey:@"type"];
    [sendDic setObject:self.Mobile forKey:@"mobile"];
    [sendDic setObject:self.Email forKey:@"email"];
    if(self.areaCode) {
        [sendDic setObject:self.areaCode forKey:@"areaCode"];
    }
    return sendDic;
}


@end
