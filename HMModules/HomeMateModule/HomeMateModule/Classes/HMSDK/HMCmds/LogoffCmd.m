//
//  LogoffCmd.m
//  Vihome
//
//  Created by Air on 15-3-16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "LogoffCmd.h"

@implementation LogoffCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_LO;
}

-(NSDictionary *)payload
{
    if (self.token) {
        [sendDic setObject:self.token forKey:@"token"];
    }
    [sendDic setObject:@(self.type) forKey:@"type"];
    
    return sendDic;
}

@end
