//
//  WiFiAddDevice.m
//  HomeMate
//
//  Created by orvibo on 16/3/30.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "WiFiAddDevice.h"

@implementation WiFiAddDevice

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_WIFIADDDEVICE;
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
