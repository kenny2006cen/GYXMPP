//
//  ModifyDeviceAuthorityCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/6/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyDeviceAuthorityCmd.h"

@implementation ModifyDeviceAuthorityCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MODIFY_DEVICE_AUTHORITY;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if (self.deviceList) {
        [sendDic setObject:self.deviceList forKey:@"deviceList"];
    }
    return sendDic;
}
@end
