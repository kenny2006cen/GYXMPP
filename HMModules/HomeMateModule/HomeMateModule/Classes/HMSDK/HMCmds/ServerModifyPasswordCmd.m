//
//  ServerModifyPassword.m
//  CloudPlatform
//
//  Created by orvibo on 15/6/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ServerModifyPasswordCmd.h"

@implementation ServerModifyPasswordCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MP;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.oldPsd forKey:@"oldPassword"];
    [sendDic setObject:self.myNewPsd forKeyedSubscript:@"newPassword"];
    return sendDic;
}

@end
