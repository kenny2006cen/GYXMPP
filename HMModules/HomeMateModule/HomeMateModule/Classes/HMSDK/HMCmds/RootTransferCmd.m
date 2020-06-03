//
//  RootTransferCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "RootTransferCmd.h"

@implementation RootTransferCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DB;
}

-(NSDictionary *)payload
{
    [sendDic setObject:[self.accountName lowercaseString] forKey:@"userName"];
    [sendDic setObject:self.password forKey:@"password"];
    [sendDic setObject:self.phone forKey:@"phone"];
    [sendDic setObject:self.email forKey:@"email"];
    [sendDic setObject:[NSNumber numberWithInt:self.userType] forKey:@"userType"];
    [sendDic setObject:[NSNumber numberWithInt:self.registerType] forKey:@"registerType"];
    
    
    return sendDic;
}

@end
