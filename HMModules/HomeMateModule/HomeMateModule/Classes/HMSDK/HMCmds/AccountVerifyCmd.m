//
//  AccountVerifyCmd.m
//  HomeMate
//
//  Created by orvibo on 16/4/1.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "AccountVerifyCmd.h"

@implementation AccountVerifyCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_THIRD_VERIFY;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.thirdId forKey:@"thirdId"];
    [sendDic setObject:@(self.registerType) forKey:@"registerType"];

    return sendDic;
}


@end
