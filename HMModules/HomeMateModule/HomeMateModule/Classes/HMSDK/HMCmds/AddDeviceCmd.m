//
//  AddDeviceCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddDeviceCmd.h"

@implementation AddDeviceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_AD;
}

-(NSDictionary *)payload
{
    [sendDic setObject:[NSNumber numberWithInt:self.deviceType] forKey:@"deviceType"];
    if (self.deviceName) {
        [sendDic setObject:self.deviceName forKey:@"deviceName"];
    }
    
    if (self.roomId) {
        [sendDic setObject:self.roomId forKey:@"roomId"];
    }
    
    if (self.irDeviceId) {
        [sendDic setObject:self.irDeviceId forKey:@"irDeviceId"];
    }
    
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    
    if (self.company) {
        [sendDic setObject:self.company forKey:@"company"];
    }
    
    return sendDic;
}


@end
