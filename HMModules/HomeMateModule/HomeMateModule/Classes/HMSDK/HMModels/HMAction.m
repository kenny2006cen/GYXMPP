//
//  VihomeAction.m
//  Vihome
//
//  Created by Ned on 4/21/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAction.h"
#import "HMConstant.h"

@implementation HMAction

- (void)copyValueFromCommonObject:(id<OrderProtocol>)object
{
    self.value1 = object.value1;
    self.value2 = object.value2;
    self.value3 = object.value3;
    self.value4 = object.value4;
    self.bindOrder = object.bindOrder;
    
    if ([(NSObject *)object respondsToSelector:@selector(actionName)]) {
        if (object.actionName) {
            self.actionName = object.actionName;
        }
    }

    if ([(NSObject *)object respondsToSelector:@selector(deviceId)]) {
        if (object.deviceId) {
            self.deviceId = object.deviceId;
        }
    }
    
    if ([(NSObject *)object respondsToSelector:@selector(themeId)]) {
        if (object.themeId) {
            self.themeId = object.themeId;
        }
    }

    // 背景音乐专用
    if ([(NSObject *)object respondsToSelector:@selector(deviceType)]) {
        if (object.deviceType == KDeviceTypeHopeBackgroundMusic
            || object.deviceType == KDeviceTypeSBKBGMusic
            || object.deviceType == KDeviceTypeMixPad) {
            self.deviceType = object.deviceType;
        }
    }
    
    if ([(NSObject *)object respondsToSelector:@selector(pluseData)]) {
        if (object.pluseData) {
            self.pluseData = object.pluseData;
        }
    }
    
    // 晾衣架使用此字段表示设备动作类型
    if ([(NSObject *)object respondsToSelector:@selector(pluseNum)]) {
        self.pluseNum = object.pluseNum;
    }
}

- (void)fillValueToCommonObject:(id<OrderProtocol>)object
{
    DLog(@"HMAction__self.value2 = %d",self.value2);
    
    object.value1 = self.value1;
    object.value2 = self.value2;
    object.value3 = self.value3;
    object.value4 = self.value4;
    object.bindOrder = self.bindOrder;
    
    if ([(NSObject *)object respondsToSelector:@selector(actionName)]) {
        object.actionName = self.actionName;
    }
    DLog(@"\nHMAction__object.value2 = %d",object.value2);
    if ([(NSObject *)object respondsToSelector:@selector(deviceId)]) {
        if (self.deviceId) {
            object.deviceId = self.deviceId;
        }
    }
    
    if ([(NSObject *)object respondsToSelector:@selector(themeId)]) {
        if (self.themeId) {
            object.themeId = self.themeId;
        }
    }

    if ([(NSObject *)object respondsToSelector:@selector(pluseData)]) {
        if (self.pluseData) {
            object.pluseData = self.pluseData;
        }
    }
    
    if ([(NSObject *)object respondsToSelector:@selector(deviceType)]) {
        if (self.deviceType == KDeviceTypeHopeBackgroundMusic
            || self.deviceType == KDeviceTypeSBKBGMusic
            || self.deviceType == KDeviceTypeMixPad) {
            object.deviceType = self.deviceType;
        }
    }
    
    // 晾衣架使用此字段表示设备动作类型
    if ([(NSObject *)object respondsToSelector:@selector(pluseNum)]) {
        object.pluseNum = self.pluseNum;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    HMAction *object = [[HMAction alloc]init];
    
    object.bindOrder = self.bindOrder;
    object.value1 = self.value1;
    object.value2 = self.value2;
    object.value3 = self.value3;
    object.value4 = self.value4;
    object.hue = self.hue;
    object.saturation = self.saturation;
    object.deviceType = self.deviceType;
    object.pluseNum = self.pluseNum;
    if (self.deviceId) {
        object.deviceId = self.deviceId;
    }
    if (self.actionName) {
        object.actionName = self.actionName;
    }
    if (self.pluseData) {
        object.pluseData = self.pluseData;
    }
    return object;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"value1 = %d,value2 = %d,value3 = %d,value4 = %d,order = %@,deviceId = %@,pluseData = %@",self.value1,self.value2,self.value3,self.value4,self.bindOrder?:@"NULL",self.deviceId?:@"NULL", self.pluseData?:@"NULL"];
}
@end
