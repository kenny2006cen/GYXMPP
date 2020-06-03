//
//  ThirdAccountRegisterCmd.m
//  HomeMate
//
//  Created by orvibo on 16/3/31.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "ThirdAccountRegisterCmd.h"

@implementation ThirdAccountRegisterCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_THIRD_REG;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.phone?:@"" forKey:@"phone"];
    [sendDic setObject:self.country forKey:@"country"];
    [sendDic setObject:self.state forKey:@"state"];
    [sendDic setObject:self.city forKey:@"city"];
    [sendDic setObject:self.thirdId forKey:@"thirdId"];
    [sendDic setObject:self.thirdUserName forKey:@"thirdUserName"];
    [sendDic setObject:self.token forKey:@"token"];
    [sendDic setObject:@(self.registerType) forKey:@"registerType"];
    [sendDic setObject:self.file forKey:@"file"];
    
    return sendDic;
}

@end
