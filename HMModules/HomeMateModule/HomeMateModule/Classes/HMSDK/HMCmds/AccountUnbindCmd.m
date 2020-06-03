//
//  AccountUnbindCmd.m
//  HomeMate
//
//  Created by orvibo on 16/4/28.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "AccountUnbindCmd.h"

@implementation AccountUnbindCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ACCOUNT_UNBIND;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.thirdAccountId forKey:@"thirdAccountId"];

    return sendDic;
}

@end
