//
//  SearchUnbindDevicesCmd.m
//  HomeMate
//
//  Created by Air on 15/11/3.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "SearchUnbindDevicesCmd.h"

@implementation SearchUnbindDevicesCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_UBD;
}

-(NSDictionary *)payload
{
    if (self.deviceType) {
        [sendDic setObject:self.deviceType forKey:@"deviceType"];
    }
    if (self.ssid) {
        [sendDic setObject:self.ssid forKey:@"ssid"];
    }
    
    return sendDic;
}

@end
