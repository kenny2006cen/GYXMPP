//
//  HMAirConditionUtil.m
//  HomeMate
//
//  Created by liqiang on 16/3/22.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMAirConditionUtil.h"

#import "HMConstant.h"
#import "ControlDeviceCmd.h"
#import "HMDevice.h"
#import "HMSceneBind.h"
#import "HMDeviceStatus.h"

@implementation HMAirConditionUtil

/**
 *  设置温度
 *
 *  @param temperature 温度值
 *  @param device      设备
 *
 *  @return 设置温度命令
 */
+ (ControlDeviceCmd *)setTemperature:(NSInteger)temperature device:(HMDevice *)device {

    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    ControlDeviceCmd * cmd = [[ControlDeviceCmd alloc] init];
   
    cmd.value1 = status.value1;
    int value2 = status.value2;
    
   
    NSString * order = @"";
    if (device.deviceType == KDeviceTypeAirconditioner && device.appDeviceId == KDeviceWifiDevice) {
        order = @"ac control";
    }else {
        order = @"temperature setting";
    }
    cmd.value2 = [HMAirConditionUtil airTemperatureInt:value2 temperature:(int)temperature];;
    cmd.value3 = status.value3;
    cmd.value4 = status.value4;
    cmd.deviceId = device.deviceId;
    cmd.order = order;
    cmd.userName = userAccout().userName;
    cmd.uid = device.uid;
    return cmd;
    
}

/**
 *  绑定命令设置温度
 *
 *  @param temperature 温度
 *  @param scenebind
 *
 *  @return
 */
+ (id)setBindTemperature:(NSInteger)temperature senebind:(id)scenebind {

    
    if ([scenebind isKindOfClass:[HMSceneBind class]]) {
        HMSceneBind *  sceneBindTemp = (HMSceneBind *)scenebind;
        
        
        int value2 = sceneBindTemp.value2;
        
        sceneBindTemp.value2 = [HMAirConditionUtil airTemperatureInt:value2 temperature:(int)temperature];
        
        scenebind = sceneBindTemp;
        
        
    }else if([scenebind isKindOfClass:[HMAction class]]) {
        HMAction *  sceneBindTemp = (HMAction *)scenebind;
        
        int value2 = sceneBindTemp.value2;
        
        sceneBindTemp.value2 = [HMAirConditionUtil airTemperatureInt:value2 temperature:(int)temperature];
        
        scenebind = sceneBindTemp;
        
    }else if ([scenebind isKindOfClass:[HMLinkageOutput class]]) {
        HMLinkageOutput *  sceneBindTemp = (HMLinkageOutput *)scenebind;
        int value2 = sceneBindTemp.value2;
        
        sceneBindTemp.value2 = [HMAirConditionUtil airTemperatureInt:value2 temperature:(int)temperature];
        
        scenebind = sceneBindTemp;
    }else if ([scenebind isKindOfClass:[HMRemoteBind class]]) {
        HMRemoteBind *  sceneBindTemp = (HMRemoteBind *)scenebind;
        int value2 = sceneBindTemp.value2;
        
        sceneBindTemp.value2 = [HMAirConditionUtil airTemperatureInt:value2 temperature:(int)temperature];
        
        scenebind = sceneBindTemp;
    }
    
    
    return scenebind;


}

+ (int)airTemperatureInt:(int)value2 temperature:(int)temperature{
    
    switch (temperature) {
        case 0:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value0:value2 position:3];
            value2 = [HMAirConditionUtil value0:value2 position:2];
            value2 = [HMAirConditionUtil value0:value2 position:1];
            break;
        case 1:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value0:value2 position:3];
            value2 = [HMAirConditionUtil value0:value2 position:2];
            value2 = [HMAirConditionUtil value1:value2 position:1];
            break;
        case 2:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value0:value2 position:3];
            value2 = [HMAirConditionUtil value1:value2 position:2];
            value2 = [HMAirConditionUtil value0:value2 position:1];
            break;
        case 3:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value0:value2 position:3];
            value2 = [HMAirConditionUtil value1:value2 position:2];
            value2 = [HMAirConditionUtil value1:value2 position:1];
            break;
        case 4:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value1:value2 position:3];
            value2 = [HMAirConditionUtil value0:value2 position:2];
            value2 = [HMAirConditionUtil value0:value2 position:1];
            break;
        case 5:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value1:value2 position:3];
            value2 = [HMAirConditionUtil value0:value2 position:2];
            value2 = [HMAirConditionUtil value1:value2 position:1];
            break;
        case 6:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value1:value2 position:3];
            value2 = [HMAirConditionUtil value1:value2 position:2];
            value2 = [HMAirConditionUtil value0:value2 position:1];
            break;
        case 7:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value1:value2 position:3];
            value2 = [HMAirConditionUtil value1:value2 position:2];
            value2 = [HMAirConditionUtil value1:value2 position:1];
            break;
        case 8:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value1:value2 position:4];
            value2 = [HMAirConditionUtil value0:value2 position:3];
            value2 = [HMAirConditionUtil value0:value2 position:2];
            value2 = [HMAirConditionUtil value0:value2 position:1];
            break;
        case 9:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value1:value2 position:4];
            value2 = [HMAirConditionUtil value0:value2 position:3];
            value2 = [HMAirConditionUtil value0:value2 position:2];
            value2 = [HMAirConditionUtil value1:value2 position:1];
            break;
        case 10:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value1:value2 position:4];
            value2 = [HMAirConditionUtil value0:value2 position:3];
            value2 = [HMAirConditionUtil value1:value2 position:2];
            value2 = [HMAirConditionUtil value0:value2 position:1];
            break;
        case 11:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value1:value2 position:4];
            value2 = [HMAirConditionUtil value0:value2 position:3];
            value2 = [HMAirConditionUtil value1:value2 position:2];
            value2 = [HMAirConditionUtil value1:value2 position:1];
            break;
        case 12:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value1:value2 position:4];
            value2 = [HMAirConditionUtil value1:value2 position:3];
            value2 = [HMAirConditionUtil value0:value2 position:2];
            value2 = [HMAirConditionUtil value0:value2 position:1];
            break;
        case 13:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value1:value2 position:4];
            value2 = [HMAirConditionUtil value1:value2 position:3];
            value2 = [HMAirConditionUtil value0:value2 position:2];
            value2 = [HMAirConditionUtil value1:value2 position:1];
            break;
        case 14:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value1:value2 position:4];
            value2 = [HMAirConditionUtil value1:value2 position:3];
            value2 = [HMAirConditionUtil value1:value2 position:2];
            value2 = [HMAirConditionUtil value0:value2 position:1];
            break;
        case 15:
            value2 = [HMAirConditionUtil value0:value2 position:5];
            value2 = [HMAirConditionUtil value1:value2 position:4];
            value2 = [HMAirConditionUtil value1:value2 position:3];
            value2 = [HMAirConditionUtil value1:value2 position:2];
            value2 = [HMAirConditionUtil value1:value2 position:1];
            break;
        case 16:
            value2 = [HMAirConditionUtil value1:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value0:value2 position:3];
            value2 = [HMAirConditionUtil value0:value2 position:2];
            value2 = [HMAirConditionUtil value0:value2 position:1];
            break;
        case 17:
            value2 = [HMAirConditionUtil value1:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value0:value2 position:3];
            value2 = [HMAirConditionUtil value0:value2 position:2];
            value2 = [HMAirConditionUtil value1:value2 position:1];
            break;
        case 18:
            value2 = [HMAirConditionUtil value1:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value0:value2 position:3];
            value2 = [HMAirConditionUtil value1:value2 position:2];
            value2 = [HMAirConditionUtil value0:value2 position:1];
            break;
        case 19:
            value2 = [HMAirConditionUtil value1:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value0:value2 position:3];
            value2 = [HMAirConditionUtil value1:value2 position:2];
            value2 = [HMAirConditionUtil value1:value2 position:1];
            break;
        case 20:
            value2 = [HMAirConditionUtil value1:value2 position:5];
            value2 = [HMAirConditionUtil value0:value2 position:4];
            value2 = [HMAirConditionUtil value1:value2 position:3];
            value2 = [HMAirConditionUtil value0:value2 position:2];
            value2 = [HMAirConditionUtil value0:value2 position:1];
            break;
            
        default:
            break;
    }
    
    
    return value2;

}

/**
 *  控制开关命令
 *
 *  @param isOpen YES 开  NO 关
 *  @param device
 *
 *  @return 开关命令
 */
+ (ControlDeviceCmd *)openAirCondition:(BOOL)isOpen device:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    ControlDeviceCmd * cmd = [[ControlDeviceCmd alloc] init];
    if(isOpen) {
        cmd.value1 = [HMAirConditionUtil value1:status.value1 position:4];

    }else {
        cmd.value1 = [HMAirConditionUtil value0:status.value1 position:4];
    }
    cmd.value2 = status.value2;
    cmd.value3 = status.value3;
    cmd.value4 = status.value4;
    cmd.deviceId = device.deviceId;
    NSString * order = @"";
    if (device.deviceType == KDeviceTypeAirconditioner && device.appDeviceId == KDeviceWifiDevice) {
        order = @"ac control";
    }else {
        if(isOpen){
            order = @"on";
        }else{
            order = @"off";

        }
    }
    cmd.order = order;
    cmd.userName = userAccout().userName;
    cmd.uid = device.uid;
    return cmd;
}

/**
 *  绑定空调 开关
 *
 *  @param isOpen
 *  @param scenebind
 *
 *  @return
 */
+ (id)setBindAirOpen:(BOOL)isOpen senebind:(id)scenebind {

    
    
    if ([scenebind isKindOfClass:[HMSceneBind class]]) {
        HMSceneBind *  sceneBindTemp = (HMSceneBind *)scenebind;
        
        
        if(isOpen) {
            sceneBindTemp.value1 = [HMAirConditionUtil value1:sceneBindTemp.value1 position:4];
            
        }else {
            sceneBindTemp.value1 = [HMAirConditionUtil value0:sceneBindTemp.value1 position:4];
        }
        
        
        scenebind = sceneBindTemp;
        
    }else if([scenebind isKindOfClass:[HMAction class]]) {
        HMAction *  sceneBindTemp = (HMAction *)scenebind;
        if(isOpen) {
            sceneBindTemp.value1 = [HMAirConditionUtil value1:sceneBindTemp.value1 position:4];
            
        }else {
            sceneBindTemp.value1 = [HMAirConditionUtil value0:sceneBindTemp.value1 position:4];
        }
        scenebind = sceneBindTemp;
        
    }else if ([scenebind isKindOfClass:[HMLinkageOutput class]]) {
        HMLinkageOutput *  sceneBindTemp = (HMLinkageOutput *)scenebind;
        if(isOpen) {
            sceneBindTemp.value1 = [HMAirConditionUtil value1:sceneBindTemp.value1 position:4];
            
        }else {
            sceneBindTemp.value1 = [HMAirConditionUtil value0:sceneBindTemp.value1 position:4];
        }
        scenebind = sceneBindTemp;
    }else if ([scenebind isKindOfClass:[HMRemoteBind class]]) {
        HMRemoteBind *  sceneBindTemp = (HMRemoteBind *)scenebind;
        if(isOpen) {
            sceneBindTemp.value1 = [HMAirConditionUtil value1:sceneBindTemp.value1 position:4];
            
        }else {
            sceneBindTemp.value1 = [HMAirConditionUtil value0:sceneBindTemp.value1 position:4];
        }
        scenebind = sceneBindTemp;
    }
    

    return scenebind;
}

/**
 *  空调锁的命令
 *
 *  @param isLock YES 锁 NO 开锁
 *  @param device
 *
 *  @return 锁命令
 */
+ (ControlDeviceCmd *)lockAirCondition:(BOOL)isLock device:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    ControlDeviceCmd * cmd = [[ControlDeviceCmd alloc] init];
    cmd.value1 = status.value1;

    if(isLock) {
        cmd.value2 = [HMAirConditionUtil value1:status.value2 position:8];
        
    }else {
        cmd.value2 = [HMAirConditionUtil value0:status.value2 position:8];
    }
    cmd.value3 = status.value3;
    cmd.value4 = status.value4;
    cmd.deviceId = device.deviceId;
    cmd.order = @"locked setting";
    cmd.userName = userAccout().userName;
    cmd.uid = device.uid;
    return cmd;
}

/**
 *  绑定空调锁动作
 *
 *  @param isLock
 *  @param scenebind
 *
 *  @return
 */
+ (id)setBindAirLock:(BOOL)isLock senebind:(id)scenebind {

    if ([scenebind isKindOfClass:[HMSceneBind class]]) {
        HMSceneBind *  sceneBindTemp = (HMSceneBind *)scenebind;
        if(isLock) {
            sceneBindTemp.value2 = [HMAirConditionUtil value1:sceneBindTemp.value2 position:8];
            
        }else {
            sceneBindTemp.value2 = [HMAirConditionUtil value0:sceneBindTemp.value2 position:8];
        }
        scenebind = sceneBindTemp;
        
    }else if([scenebind isKindOfClass:[HMAction class]]) {
        HMAction *  sceneBindTemp = (HMAction *)scenebind;
        if(isLock) {
            sceneBindTemp.value2 = [HMAirConditionUtil value1:sceneBindTemp.value2 position:8];
            
        }else {
            sceneBindTemp.value2 = [HMAirConditionUtil value0:sceneBindTemp.value2 position:8];
        }
        scenebind = sceneBindTemp;
        
    }else if ([scenebind isKindOfClass:[HMLinkageOutput class]]) {
        HMLinkageOutput *  sceneBindTemp = (HMLinkageOutput *)scenebind;
        if(isLock) {
            sceneBindTemp.value2 = [HMAirConditionUtil value1:sceneBindTemp.value2 position:8];
            
        }else {
            sceneBindTemp.value2 = [HMAirConditionUtil value0:sceneBindTemp.value2 position:8];
        }
        scenebind = sceneBindTemp;
    }else if ([scenebind isKindOfClass:[HMRemoteBind class]]) {
        HMRemoteBind *  sceneBindTemp = (HMRemoteBind *)scenebind;
        if(isLock) {
            sceneBindTemp.value2 = [HMAirConditionUtil value1:sceneBindTemp.value2 position:8];
            
        }else {
            sceneBindTemp.value2 = [HMAirConditionUtil value0:sceneBindTemp.value2 position:8];
        }
        scenebind = sceneBindTemp;
    }
    

    
    return scenebind;
}

/**
 *  设置空调模式
 *
 *  @param status  模式
 *  @param device
 *
 *  @return 模式命令
 */
+ (ControlDeviceCmd *)setAirModel:(HMAirModelStatus)statusModel device:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    ControlDeviceCmd * cmd = [[ControlDeviceCmd alloc] init];
    int value1 =  status.value1;
    
    cmd.value1 = [HMAirConditionUtil setAirModel:statusModel value:value1];
    cmd.value2 = status.value2;
    cmd.value3 = status.value3;
    cmd.value4 = status.value4;
    cmd.deviceId = device.deviceId;
    NSString * order = @"";
    if (device.deviceType == KDeviceTypeAirconditioner && device.appDeviceId == KDeviceWifiDevice) {
        order = @"ac control";
    }else {
        order = @"mode setting";
    }
    cmd.order = order;
    cmd.userName = userAccout().userName;
    cmd.uid = device.uid;
    
    
    return cmd;
}

/**
 *  绑定设置模式
 *
 *  @param statusModel
 *  @param sceneBind
 *
 *  @return
 */
+ (id)setAirBindModel:(HMAirModelStatus)statusModel sceneBind:(id)sceneBind {

    
    
    if ([sceneBind isKindOfClass:[HMSceneBind class]]) {
        HMSceneBind *  sceneBindTemp = (HMSceneBind *)sceneBind;
        sceneBindTemp.value1 = [HMAirConditionUtil setAirModel:statusModel value:sceneBindTemp.value1];
        sceneBind = sceneBindTemp;
        
    }else if([sceneBind isKindOfClass:[HMAction class]]) {
        HMAction *  sceneBindTemp = (HMAction *)sceneBind;
        sceneBindTemp.value1 = [HMAirConditionUtil setAirModel:statusModel value:sceneBindTemp.value1];
        
        sceneBind = sceneBindTemp;
        
    }else if ([sceneBind isKindOfClass:[HMLinkageOutput class]]) {
        HMLinkageOutput *  sceneBindTemp = (HMLinkageOutput *)sceneBind;
        sceneBindTemp.value1 = [HMAirConditionUtil setAirModel:statusModel value:sceneBindTemp.value1];
        
        sceneBind = sceneBindTemp;
    }else if ([sceneBind isKindOfClass:[HMRemoteBind class]]) {
        HMRemoteBind *  sceneBindTemp = (HMRemoteBind *)sceneBind;
        sceneBindTemp.value1 = [HMAirConditionUtil setAirModel:statusModel value:sceneBindTemp.value1];
        
        sceneBind = sceneBindTemp;
    }
    
    return sceneBind;
}

+ (int)setAirModel:(HMAirModelStatus)statusModel value:(int)value1 {

    switch (statusModel) {
        case HMAirModelStatusCold: {
            value1 = [HMAirConditionUtil value0:value1 position:3];
            value1 = [HMAirConditionUtil value0:value1 position:2];
            value1 = [HMAirConditionUtil value1:value1 position:1];
            break;
        }
        case HMAirModelStatusHot: {
            value1 = [HMAirConditionUtil value1:value1 position:3];
            value1 = [HMAirConditionUtil value0:value1 position:2];
            value1 = [HMAirConditionUtil value0:value1 position:1];
            break;
        }
        case HMAirModelStatusWet: {
            value1 = [HMAirConditionUtil value0:value1 position:3];
            value1 = [HMAirConditionUtil value1:value1 position:2];
            value1 = [HMAirConditionUtil value0:value1 position:1];
            break;
        }
        case HMAirModelStatusWind: {
            value1 = [HMAirConditionUtil value0:value1 position:3];
            value1 = [HMAirConditionUtil value1:value1 position:2];
            value1 = [HMAirConditionUtil value1:value1 position:1];
            break;
        }
        case HMAirModelStatusAuto: {
            value1 = [HMAirConditionUtil value0:value1 position:3];
            value1 = [HMAirConditionUtil value0:value1 position:2];
            value1 = [HMAirConditionUtil value0:value1 position:1];
            break;
        }
        default:
            DLog(@"unknown HMAirModelStatus(%d)", statusModel);
            break;
    }
    
    
    return value1;
}

/**
 *  设置风级命令
 *
 *  @param level  风级
 *  @param device
 *
 *  @return 风级命令
 */
+ (ControlDeviceCmd *)setWindLevel:(HMAirWindLevel)level device:(HMDevice *)device {

    
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    ControlDeviceCmd * cmd = [[ControlDeviceCmd alloc] init];
    int value1 =  status.value1;
    
    cmd.value1 = [HMAirConditionUtil setWindLevel:level value:value1];
    cmd.value2 = status.value2;
    cmd.value3 = status.value3;
    cmd.value4 = status.value4;
    cmd.deviceId = device.deviceId;
    NSString * order = @"";
    if (device.deviceType == KDeviceTypeAirconditioner && device.appDeviceId == KDeviceWifiDevice) {
        order = @"ac control";
    }else {
        order = @"wind setting";
    }
    cmd.order = order;
    cmd.userName = userAccout().userName;
    cmd.uid = device.uid;
    return cmd;
    
}

/**
 *  绑定air风级
 *
 *  @param level
 *  @param sceneBind
 *
 *  @return
 */
+ (id)setBindWindLevel:(HMAirWindLevel)level sceneBind:(id)sceneBind {
    
    if ([sceneBind isKindOfClass:[HMSceneBind class]]) {
        HMSceneBind *  sceneBindTemp = (HMSceneBind *)sceneBind;
        sceneBindTemp.value1 = [HMAirConditionUtil setWindLevel:level value:sceneBindTemp.value1];
        sceneBind = sceneBindTemp;

    }else if([sceneBind isKindOfClass:[HMAction class]]) {
        HMAction *  sceneBindTemp = (HMAction *)sceneBind;
        sceneBindTemp.value1 = [HMAirConditionUtil setWindLevel:level value:sceneBindTemp.value1];
    
        sceneBind = sceneBindTemp;
        
    }else if ([sceneBind isKindOfClass:[HMLinkageOutput class]]) {
        HMLinkageOutput *  sceneBindTemp = (HMLinkageOutput *)sceneBind;
        sceneBindTemp.value1 = [HMAirConditionUtil setWindLevel:level value:sceneBindTemp.value1];
        
        sceneBind = sceneBindTemp;
    }else if ([sceneBind isKindOfClass:[HMRemoteBind class]]) {
        HMRemoteBind *  sceneBindTemp = (HMRemoteBind *)sceneBind;
        sceneBindTemp.value1 = [HMAirConditionUtil setWindLevel:level value:sceneBindTemp.value1];
        
        sceneBind = sceneBindTemp;
    }
    
    return sceneBind;
}
+ (int)setWindLevel:(HMAirWindLevel)level value:(int)value1 {

    switch (level) {
        case HMAirWindLevelAuto: {
            value1 = [HMAirConditionUtil value0:value1 position:7];
            value1 = [HMAirConditionUtil value0:value1 position:6];
            value1 = [HMAirConditionUtil value0:value1 position:5];
            
            break;
        }
        case HMAirWindLevelWeak: {
            value1 = [HMAirConditionUtil value0:value1 position:7];
            value1 = [HMAirConditionUtil value0:value1 position:6];
            value1 = [HMAirConditionUtil value1:value1 position:5];
            break;
        }
        case HMAirWindLevelMiddleWeak: {
            value1 = [HMAirConditionUtil value0:value1 position:7];
            value1 = [HMAirConditionUtil value1:value1 position:6];
            value1 = [HMAirConditionUtil value0:value1 position:5];
            break;
        }
        case HMAirWindLevelMiddle: {
            value1 = [HMAirConditionUtil value0:value1 position:7];
            value1 = [HMAirConditionUtil value1:value1 position:6];
            value1 = [HMAirConditionUtil value1:value1 position:5];
            break;
        }
        case HMAirWindLevelMiddleStrong: {
            value1 = [HMAirConditionUtil value1:value1 position:7];
            value1 = [HMAirConditionUtil value0:value1 position:6];
            value1 = [HMAirConditionUtil value0:value1 position:5];
            break;
        }
        case HMAirWindLevelStrong: {
            value1 = [HMAirConditionUtil value1:value1 position:7];
            value1 = [HMAirConditionUtil value0:value1 position:6];
            value1 = [HMAirConditionUtil value1:value1 position:5];
            break;
        }
        case HMAirWindLevelSuper: {
            value1 = [HMAirConditionUtil value1:value1 position:7];
            value1 = [HMAirConditionUtil value1:value1 position:6];
            value1 = [HMAirConditionUtil value0:value1 position:5];
            break;
        }
    }
    
    return value1;
}

/**
 *  判断空调面板 是否加锁
 *
 *  @param device
 *
 *  @return YES 是  NO 否
 */
+ (BOOL)airIsLock:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];;
    BOOL isLock = YES;
    
    int value2 = status.value2;
    int value =  value2>>7 & 0x00001;
    
    if (value == 0) {
        isLock = NO;
    }else if(value == 1){
        isLock  = YES;
    }
    
    return isLock;
}

/**
 *  判断WiFi空调/空调面板开关
 *
 *  @param device
 *
 *  @return YES 开  NO 关
 */
+ (BOOL)airIsOpen:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid]; //[HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    BOOL isOpen = YES;
    
    int value1 = status.value1;
    isOpen = [HMAirConditionUtil open:value1];
    
    return isOpen;
}

/**
 *  获取当前温度值
 *
 *  @param device
 *
 *  @return 温度值
 */
+ (int)airconditionCurrentValue:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    
    int currentTemperature = (status.value2 >> 8) & 255;
    
    return currentTemperature;
}

/**
 *  获取WiFi空调/空调面板当前风速
 *
 *  @param device
 *
 *  @return 风速
 */
+ (HMAirWindLevel)airWindLevel:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    
    
    return [HMAirConditionUtil wind:status.value1];
}

/**
 *  获取WiFi空调/空调面板当前模式
 *
 *  @param device
 *
 *  @return 模式
 */
+ (HMAirModelStatus)modelStatus:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    
    return [HMAirConditionUtil model:status.value1];
}



/**
 *  判断绑定开关
 *
 *  @param sceneBind
 *
 *  @return
 */
+ (BOOL)bindOpen:(id)sceneBind {

    BOOL isOpen = YES;
    
    if ([sceneBind isKindOfClass:[HMSceneBind class]]) {
     HMSceneBind *  sceneBindTemp = (HMSceneBind *)sceneBind;
        isOpen = [HMAirConditionUtil open:sceneBindTemp.value1];

    }else if([sceneBind isKindOfClass:[HMAction class]]) {
        HMAction *  sceneBindTemp = (HMAction *)sceneBind;
        isOpen = [HMAirConditionUtil open:sceneBindTemp.value1];

    }else if ([sceneBind isKindOfClass:[HMLinkageOutput class]]) {
        HMLinkageOutput *  sceneBindTemp = (HMLinkageOutput *)sceneBind;
        isOpen = [HMAirConditionUtil open:sceneBindTemp.value1];
    }else if ([sceneBind isKindOfClass:[HMRemoteBind class]]) {
        HMRemoteBind *  sceneBindTemp = (HMRemoteBind *)sceneBind;
        isOpen = [HMAirConditionUtil open:sceneBindTemp.value1];
    }
    
    return isOpen;
    
}


/**
 *  判断绑定锁
 *
 *  @param sceneBind
 *
 *  @return
 */
+ (BOOL)bindLock:(id)sceneBind {

    BOOL lock = NO;
    if ([sceneBind isKindOfClass:[HMSceneBind class]]) {
        HMSceneBind *  sceneBindTemp = (HMSceneBind *)sceneBind;
      lock =  [HMAirConditionUtil lock:sceneBindTemp.value2];
    }else if([sceneBind isKindOfClass:[HMAction class]]) {
        HMAction *  sceneBindTemp = (HMAction *)sceneBind;
       lock = [HMAirConditionUtil lock:sceneBindTemp.value2];
        
    }else if ([sceneBind isKindOfClass:[HMLinkageOutput class]]) {
        HMLinkageOutput *  sceneBindTemp = (HMLinkageOutput *)sceneBind;
        lock =  [HMAirConditionUtil lock:sceneBindTemp.value2];
    }else if ([sceneBind isKindOfClass:[HMRemoteBind class]]) {
        HMRemoteBind *  sceneBindTemp = (HMRemoteBind *)sceneBind;
        lock =  [HMAirConditionUtil lock:sceneBindTemp.value2];
    }
    
    return lock;
    
}

/**
 *  绑定模式
 *
 *  @param sceneBind
 *
 *  @return
 */
+ (HMAirModelStatus)bindModel:(id)sceneBind {
    HMAirModelStatus  status = HMAirModelStatusAuto;
    
    if ([sceneBind isKindOfClass:[HMSceneBind class]]) {
        HMSceneBind *  sceneBindTemp = (HMSceneBind *)sceneBind;
        status =  [HMAirConditionUtil model:sceneBindTemp.value1];
    }else if([sceneBind isKindOfClass:[HMAction class]]) {
        HMAction *  sceneBindTemp = (HMAction *)sceneBind;
        status =  [HMAirConditionUtil model:sceneBindTemp.value1];
        
    }else if ([sceneBind isKindOfClass:[HMLinkageOutput class]]) {
        HMLinkageOutput *  sceneBindTemp = (HMLinkageOutput *)sceneBind;
        status =  [HMAirConditionUtil model:sceneBindTemp.value1];
    }else if ([sceneBind isKindOfClass:[HMRemoteBind class]]) {
        HMRemoteBind *  sceneBindTemp = (HMRemoteBind *)sceneBind;
        status =  [HMAirConditionUtil model:sceneBindTemp.value1];
    }
    
    return status;

}

/**
 *  绑定风速
 *
 *  @param sceneBind
 *
 *  @return
 */
+ (HMAirWindLevel)bindWindLevel:(id)sceneBind {
    
    HMAirWindLevel level = HMAirWindLevelWeak;
    
    if ([sceneBind isKindOfClass:[HMSceneBind class]]) {
        HMSceneBind *  sceneBindTemp = (HMSceneBind *)sceneBind;
        level =  [HMAirConditionUtil wind:sceneBindTemp.value1];
    }else if([sceneBind isKindOfClass:[HMAction class]]) {
        HMAction *  sceneBindTemp = (HMAction *)sceneBind;
        level =  [HMAirConditionUtil wind:sceneBindTemp.value1];
        
    }else if ([sceneBind isKindOfClass:[HMLinkageOutput class]]) {
        HMLinkageOutput *  sceneBindTemp = (HMLinkageOutput *)sceneBind;
        level =  [HMAirConditionUtil wind:sceneBindTemp.value1];
    }else if ([sceneBind isKindOfClass:[HMRemoteBind class]]) {
        HMRemoteBind *  sceneBindTemp = (HMRemoteBind *)sceneBind;
        level =  [HMAirConditionUtil wind:sceneBindTemp.value1];
    }
    
    return level;

}


/**
 *  获取设置温度值
 *
 *  @param device
 *
 *  @return 温度值
 */
+ (int)airconditionSettingValue:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];

    return status.value2 & 31;
}


+ (BOOL)open:(int)value1 {

    BOOL isOpen = YES;
    
    int value =  value1>>3 & 0x00001;
    
    if (value == 0) {
        isOpen = NO;
    }else if(value == 1){
        isOpen  = YES;
    }
    
    return isOpen;
}

+ (BOOL)lock:(int)value2 {
    
    BOOL isLock = YES;
    
    int value =  value2>>7 & 0x00001;
    
    if (value == 0) {
        isLock = NO;
    }else if(value == 1){
        isLock  = YES;
    }
    
    return isLock;

}


+ (HMAirModelStatus)model:(int)value1 {
    
    HMAirModelStatus modelStatus= HMAirModelStatusAuto;
    
    int value =  value1 & 0x0007;
    
    if (value == 0) {
        modelStatus = HMAirModelStatusAuto;
    }else if(value == 1){
        modelStatus = HMAirModelStatusCold;
    }else if(value == 2) {
        modelStatus = HMAirModelStatusWet;
    }else if(value == 3) {
        modelStatus = HMAirModelStatusWind;
    }else if(value == 4) {
        modelStatus = HMAirModelStatusHot;
    }
    return modelStatus;
}


+ (HMAirWindLevel)wind:(int)value1 {

    HMAirWindLevel windLevel = HMAirWindLevelAuto;
    
    int value =  value1>>4 & 0x00007;
    
    if (value == 0) {
        windLevel = HMAirWindLevelAuto;
    }else if(value == 1){
        windLevel = HMAirWindLevelWeak;
    }else if(value == 2) {
        windLevel = HMAirWindLevelMiddleWeak;
    }else if(value == 3) {
        windLevel = HMAirWindLevelMiddle;
    }else if(value == 4) {
        windLevel = HMAirWindLevelMiddleStrong;
    }else if(value == 5) {
        windLevel = HMAirWindLevelStrong;
    }else if(value == 6) {
        windLevel = HMAirWindLevelSuper;
    }
    
    return windLevel;
    
}

/**
 *  获取设定温度
 *
 *  @param sceneBind
 *
 *  @return
 */
+ (int)getBindSettingTemperature:(id)sceneBind {
    
    if ([sceneBind isKindOfClass:[HMSceneBind class]]) {
        HMSceneBind *  sceneBindTemp = (HMSceneBind *)sceneBind;
        return  sceneBindTemp.value2 & 31;
    }else if ([sceneBind isKindOfClass:[HMAction class]])  {
        HMAction *  sceneBindTemp = (HMAction *)sceneBind;
        return  sceneBindTemp.value2 & 31;
        
    }else if ([sceneBind isKindOfClass:[HMLinkageOutput class]]) {
        HMLinkageOutput *  sceneBindTemp = (HMLinkageOutput *)sceneBind;
        return  sceneBindTemp.value2 & 31;
    }else if ([sceneBind isKindOfClass:[HMRemoteBind class]]) {
        HMRemoteBind *  sceneBindTemp = (HMRemoteBind *)sceneBind;
        return  sceneBindTemp.value2 & 31;
    }
    
    return 1;
    
  
}


/**
 将value的第position位设为1

 @param value    修改前的值
 @param position 第position位设定为1，position的序号从1开始
 @return         修改后的值
 */
+ (int)value1:(int)value position:(int)position {
    return value | (1 << (position - 1));
}
/**
 将value的第position位设为0
 
 @param value    修改前的值
 @param position 第position位设定为0，position的序号从1开始
 @return         修改后的值
 */
+ (int)value0:(int)value position:(int)position {
    int src = INT_MAX ^ (1 << (position - 1)) ;
    return value & src;
}

@end
