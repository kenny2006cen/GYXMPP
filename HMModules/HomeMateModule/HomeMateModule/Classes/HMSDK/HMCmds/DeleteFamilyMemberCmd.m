//
//  DeleteFamilyMemberCmd.m
//  HomeMate
//
//  Created by Air on 15/9/9.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "DeleteFamilyMemberCmd.h"

@implementation DeleteFamilyMemberCmd
@synthesize userName;

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DFM;
}

-(NSDictionary *)payload
{
    [sendDic setObject:@(self.inviteType) forKey:@"inviteType"];
    if (_userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }

    return sendDic;
}
@end
