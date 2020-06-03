//
//  ThirdBindCmd.m
//  HomeMate
//
//  Created by orvibo on 16/4/5.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "ThirdBindCmd.h"

@implementation ThirdBindCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_THIRD_BIND;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.phone?:@"" forKey:@"phone"];
    [sendDic setObject:self.userId forKey:@"userId"];
    [sendDic setObject:self.thirdId forKey:@"thirdId"];
    [sendDic setObject:self.thirdUserName forKey:@"thirdUserName"];
    [sendDic setObject:self.token forKey:@"token"];
    [sendDic setObject:@(self.registerType) forKey:@"registerType"];
    [sendDic setObject:self.file forKey:@"file"];
    
    return sendDic;
}

@end
