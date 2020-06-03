//
//  ModifyPasswordCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyPasswordCmd.h"

@implementation ModifyPasswordCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MP;
}

-(NSDictionary *)payload
{
    [sendDic setObject:[self.accountName lowercaseString] forKey:@"userName"];
    [sendDic setObject:self.OldPassword forKey:@"oldPassword"];
    [sendDic setObject:self.NewPassword forKey:@"newPassword"];
    
    return sendDic;
}


@end
