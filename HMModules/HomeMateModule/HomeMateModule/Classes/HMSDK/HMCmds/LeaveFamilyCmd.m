//
//  LeaveFamilyCmd.m
//  HomeMateSDK
//
//  Created by user on 17/2/9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "LeaveFamilyCmd.h"

@implementation LeaveFamilyCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_LEAVE_FAMILY;
}

-(NSDictionary *)payload
{
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    return sendDic;
}

@end
