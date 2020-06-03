//
//  FamilyMemberResponseCmd.m
//  HomeMate
//
//  Created by Air on 15/9/9.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "FamilyMemberResponseCmd.h"

@implementation FamilyMemberResponseCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_FMR;
}

-(NSDictionary *)payload
{
    [sendDic setObject:[NSNumber numberWithInt:self.type] forKey:@"type"];
    [sendDic setObject:self.inviteId forKey:@"inviteId"];
    
    return sendDic;
}

@end
