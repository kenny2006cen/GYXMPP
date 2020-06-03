//
//  ModifyDeviceCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyDeviceCmd.h"

@implementation ModifyDeviceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MD;
}

-(NSDictionary *)payload
{
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    
    if (self.extAddr) {
        [sendDic setObject:self.extAddr forKey:@"extAddr"];
    }
    
    if (self.deviceName) {
        [sendDic setObject:self.deviceName forKey:@"deviceName"];
    }
    
    [sendDic setObject:[NSNumber numberWithInt:self.deviceType] forKey:@"deviceType"];
    if(self.roomId){
        [sendDic setObject:self.roomId forKey:@"roomId"];
    }
    
    if (self.irDeviceId) {
        [sendDic setObject:self.irDeviceId forKey:@"irDeviceId"];
    }
    if (self.uid) {
        [sendDic setValue:self.uid forKey:@"uid"];
    }
    return sendDic;
}
-(BOOL)sendToServer{
    
    return YES;
}

@end
