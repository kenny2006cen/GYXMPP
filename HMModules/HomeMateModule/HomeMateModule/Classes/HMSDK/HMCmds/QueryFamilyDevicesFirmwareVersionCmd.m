//
//  QueryFamilyDevicesFirmwareVersionCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2018/9/6.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "QueryFamilyDevicesFirmwareVersionCmd.h"

@implementation QueryFamilyDevicesFirmwareVersionCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_FAMILY_DEVICE_VERSION;
}

-(NSDictionary *)payload
{
    if (self.familyId.length) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.deviceVersionArray) {
        [sendDic setObject:self.deviceVersionArray forKey:@"deviceVersionArray"];
    }
    return sendDic;
}

@end
