//
//  RecoverFamilyCmd.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/12/19.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "RecoverFamilyCmd.h"

@implementation RecoverFamilyCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_RESTORE_FAMILY_DELETED;
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
