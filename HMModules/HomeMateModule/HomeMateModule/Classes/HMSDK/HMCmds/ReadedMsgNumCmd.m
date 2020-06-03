//
//  ReadedMsgNumCmd.m
//  HomeMate
//
//  Created by liuzhicai on 15/8/20.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "ReadedMsgNumCmd.h"
#import "HMTypes.h"
#import "HomeMateSDK.h"

@implementation ReadedMsgNumCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_RMN;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.phoneToken forKey:@"phoneToken"];
    [sendDic setObject:@(self.num) forKey:@"num"];
    return sendDic;
}

- (NSString *)phoneToken
{
    return [HMUserDefaults objectForKey:@"token"];
}

+ (BOOL)toKenIsNull
{
    DLog(@"%@",[HMUserDefaults objectForKey:@"token"]);
    if ([HMUserDefaults objectForKey:@"token"]) {
        return NO;
    }
    return YES;
}

@end
