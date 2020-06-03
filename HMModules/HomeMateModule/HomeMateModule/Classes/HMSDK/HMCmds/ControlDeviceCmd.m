//
//  ControlDeviceCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ControlDeviceCmd.h"

@implementation ControlDeviceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_CD;
}

-(NSDictionary *)payload
{
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    
    if (self.order) {
        [sendDic setObject:self.order forKey:@"order"];
    }
    [sendDic setObject:@(self.value1) forKey:@"value1"];
    [sendDic setObject:@(self.value2) forKey:@"value2"];
    [sendDic setObject:@(self.value3) forKey:@"value3"];
    [sendDic setObject:@(self.value4) forKey:@"value4"];
    [sendDic setObject:@(self.delayTime) forKey:@"delayTime"];
    if (self.model) {
        [sendDic setObject:self.model forKey:@"model"];
    }
    if (self.isLevelControl) {
        [sendDic setObject:@(self.qualityOfService) forKey:@"qualityOfService"];
        [sendDic setObject:@(self.defaultResponse) forKey:@"defaultResponse"];
    }
    
    if (self.forWholeDevice) {
        [sendDic setObject:@(self.forWholeDevice) forKey:@"forWholeDevice"];
    }
    
    if ([self.order isEqualToString:@"ir control"]) {
        [sendDic setObject:@(self.freq) forKey:@"freq"];
        if (self.pluseData) {
            [sendDic setObject:self.pluseData forKey:@"pluseData"];
        }
        [sendDic setObject:@(self.pluseNum) forKey:@"pluseNum"];
    }
    
    if (self.addrMode) {
        [sendDic setObject:self.addrMode forKey:@"addrMode"];
    }
    
    if (self.groupId) {
        [sendDic setObject:self.groupId forKey:@"groupId"];
    }
    
    if (self.themeParameter) {
        [sendDic setObject:self.themeParameter forKey:@"themeParameter"];
    }
//    if (self.propertyResponse) { // 默认需要属性报告，默认不传
    [sendDic setObject:@(self.propertyResponse) forKey:@"propertyResponse"];
//    }
    
    if (self.custom) {
        [sendDic setObject:self.custom forKey:@"custom"];
    }
    return sendDic;
}
@end
