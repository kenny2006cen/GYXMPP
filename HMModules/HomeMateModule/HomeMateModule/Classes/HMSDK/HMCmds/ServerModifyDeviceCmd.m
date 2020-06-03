//
//  ServerModifyDevice.m
//  CloudPlatform
//
//  Created by orvibo on 15/6/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ServerModifyDeviceCmd.h"

@implementation ServerModifyDeviceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MODIFYDEVICE;
}

-(BOOL)sendToServer{
    
    return YES;
}
-(NSDictionary *)payload
{
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    if (self.deviceName) {
        [sendDic setObject:self.deviceName forKey:@"deviceName"];
    }
    if (self.roomId) {
        [sendDic setObject:self.roomId forKey:@"roomId"];
    }
    if (self.irDeviceId) {
        [sendDic setObject:self.irDeviceId forKey:@"irDeviceId"];
    }
    [sendDic setObject:@(self.isPreset) forKey:@"isPreset"];
    [sendDic setObject:@(self.deviceType) forKey:@"deviceType"];
    
    return sendDic;
}


@end
