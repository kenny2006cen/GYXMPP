//
//  DeviceBindCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeviceBindCmd.h"
#import "HMConstant.h"

@implementation DeviceBindCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DBD;
}

-(NSDictionary *)payload
{
    if (self.bindUID) {
        [sendDic setObject:self.bindUID forKey:@"uid"];
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    if (self.user.length) { // 萤石摄像头才需要的字段
        
        [dict setObject:self.user forKey:@"user"];
        
        if (self.password.length) {
            [dict setObject:self.password forKey:@"password"];
        }
        
        [dict setObject:@(self.type) forKey:@"type"];
        
        if (self.modelId.length) {
            [dict setObject:self.modelId forKey:@"modelId"];
        }
    }

    if (self.deviceType.length) {
        [sendDic setObject:self.deviceType forKey:@"deviceType"];
        
    }
    
    if (self.irDeviceId.length) {
        [dict setObject:self.irDeviceId forKey:@"irDeviceId"];
        
    }
    
    if (self.accessToken.length) {// 小欧摄像头才需要的字段
        [dict setObject:self.accessToken forKey:@"accessToken"];
        
    }
    
    if (dict) {
        [sendDic setObject:dict forKey:@"payload"];
    }
    
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }else {
        [sendDic setObject:userAccout().familyId forKey:@"familyId"];
    }
    
    if (self.ssid) {
        [sendDic setObject:self.ssid forKey:@"ssid"];
    }
    if (self.deviceBindPayload.count) {
        [sendDic setObject:self.deviceBindPayload forKey:@"payload"];

    }
    return sendDic;
}
-(NSString *)userName
{
    return nil;
}

@end
