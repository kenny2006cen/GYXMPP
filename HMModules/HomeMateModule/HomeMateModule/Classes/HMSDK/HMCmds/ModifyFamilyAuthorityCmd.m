//
//  ModifyFamilyAuthorityCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/6/16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyFamilyAuthorityCmd.h"

@implementation ModifyFamilyAuthorityCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MODIFY_FAMILY_AUTHORITYNEW;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.roomList) {
        [sendDic setObject:self.roomList forKey:@"roomList"];
    }
    if (self.deviceList) {
        [sendDic setObject:self.deviceList forKey:@"deviceList"];
    }
    return sendDic;
}
@end
