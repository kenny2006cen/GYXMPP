//
//  TokenReportCmd.m
//  HomeMate
//
//  Created by liuzhicai on 15/8/20.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "TokenReportCmd.h"
#import "HomeMateSDK.h"

@implementation TokenReportCmd

-(NSString *)language
{
    return language();
}

-(NSString *)phoneToken
{
    if (_phoneToken) {
        return _phoneToken;
    }
    return  [HMUserDefaults objectForKey:@"token"];
}

-(NSString *)phoneSystem
{
    return @"iOS";
}

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_TR;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.language forKey:@"language"];
    [sendDic setObject:self.phoneSystem forKey:@"os"];
    if (self.phoneToken) {
        [sendDic setObject:self.phoneToken forKey:@"phoneToken"];
    }
    return sendDic;
}


+ (BOOL)toKenIsNull
{
    if ([HMUserDefaults objectForKey:@"token"]) {
        
        DLog(@"Token存在");
        return NO;
    }
    
    DLog(@"Token为空");
    return YES;
}





@end
