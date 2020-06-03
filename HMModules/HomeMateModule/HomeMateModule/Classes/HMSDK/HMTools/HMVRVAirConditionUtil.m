//
//  HMVRVAirConditionUtil.m
//  HomeMate
//
//  Created by peanut on 2017/1/10.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMVRVAirConditionUtil.h"

#import "HMDevice.h"
#import "HMDeviceStatus.h"
#import "ControlDeviceCmd.h"
#import "HMConstant.h"

#pragma mark - VRV控制与定时设置命令
NSString * const kVRVOnOrder = @"on";
NSString * const kVRVOffOrder = @"off";
NSString * const kVRVTemperatureSettingOrder = @"temperature setting";
NSString * const kVRVWindSettingOrder = @"wind setting";
NSString * const kVRVModeSettingOrder = @"mode setting";
NSString * const kVRVStatusControlOrder = @"status control";


// 当前温度，低十六位除以10
#define CurrentTemp(value)   (((value) & 0Xffff) / 100)
// 设定温度，高十六位除以10
#define SettingTemp(value)   ((((value) >> 16) & 0Xffff) / 100)

@implementation HMVRVErrorCode

@end

@implementation HMVRVAirConditionUtil

#pragma mark - sendCmd
+ (ControlDeviceCmd *)setTemperature:(NSInteger)temperature device:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    ControlDeviceCmd * cmd = [[ControlDeviceCmd alloc] init];
    int value4 =  status.value4;
    
    temperature = temperature * 100;
    cmd.value1 = status.value1;
    cmd.value2 = status.value2;
    cmd.value3 = status.value3;
    cmd.value4 = [self replaceBits:value4 withBits:((int)temperature) from:16 length:16];
    cmd.deviceId = device.deviceId;
    cmd.order = kVRVTemperatureSettingOrder;
    cmd.userName = userAccout().userName;
    cmd.uid = device.uid;
    
    return cmd;
}


+ (ControlDeviceCmd *)openAirCondition:(BOOL)isOpen device:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    ControlDeviceCmd * cmd = [[ControlDeviceCmd alloc] init];
    if(isOpen) {
        cmd.value1 = [self replaceBits:0 withBits:0 from:0 length:1];
    }else {
        cmd.value1 = [self replaceBits:0 withBits:1 from:0 length:1];
    }
    cmd.value2 = status.value2;
    cmd.value3 = status.value3;
    cmd.value4 = status.value4;
    cmd.deviceId = device.deviceId;
    NSString * order = @"";
    if(isOpen){
        order = kVRVOnOrder;
    }else{
        order = kVRVOffOrder;
    }
    
    cmd.order = order;
    cmd.userName = userAccout().userName;
    cmd.uid = device.uid;
    return cmd;
}

+ (ControlDeviceCmd *)setWindLevel:(HMVRVAirWindLevel)level device:(HMDevice *)device {
    [self checkWhetherOutOfRangeWithWindlevel:level]; // 检查风速越界
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    ControlDeviceCmd * cmd = [[ControlDeviceCmd alloc] init];
    cmd.value1 = status.value1;
    cmd.value2 = status.value2;
    cmd.value3 = [self replaceBits:0 withBits:((int)(level-HMAirWindLevelVRVStartPoint)) from:0 length:8];
    cmd.value4 = status.value4;
    cmd.deviceId = device.deviceId;
    cmd.order = kVRVWindSettingOrder;
    cmd.userName = userAccout().userName;
    cmd.uid = device.uid;
    return cmd;
}

+ (ControlDeviceCmd *)setAirModel:(HMVRVAirModelStatus)statusModel device:(HMDevice *)device {
    [self checkWhetherOutOfRangeWithAirmodel:statusModel]; // 检查模式越界
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    ControlDeviceCmd * cmd = [[ControlDeviceCmd alloc] init];
    cmd.value1 = status.value1;
    cmd.value2 = [self replaceBits:0 withBits:((int)(statusModel-HMAirModelStatusVRVStartPoint)) from:0 length:8];
    cmd.value3 = status.value3;
    cmd.value4 = status.value4;
    cmd.deviceId = device.deviceId;
    cmd.order = kVRVModeSettingOrder;
    cmd.userName = userAccout().userName;
    cmd.uid = device.uid;
    return cmd;
}

#pragma mark - getStatus
+ (int)airconditionCurrentValue:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    // 室温
    int currentTemperature = CurrentTemp(status.value4);
    return currentTemperature;
}

+ (int)airconditionSettingValue:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    // 设置温度
    DLog(@"status.Value4 :%d",status.value4);
    int realSettingTemp = SettingTemp(status.value4);
    DLog(@"转化成功后温度 :%d",realSettingTemp);
    int settingTemp = [self letValue:realSettingTemp insideRangeWithLow:16 high:32];
    return settingTemp;
}

+ (HMVRVAirWindLevel)airWindLevel:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    
    int windLevel = (status.value3 & 0xff) + HMAirWindLevelVRVStartPoint;
    return windLevel;
}

+ (BOOL)airIsOpen:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    BOOL isOpen;
    int value1 = status.value1;
    if ((value1 & 1) == 0) {
        isOpen = YES;
    } else {
        isOpen = NO;
    }
    return isOpen;
}

+ (HMVRVAirModelStatus)modelStatus:(HMDevice *)device {
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    return status.value2+HMAirModelStatusVRVStartPoint;
}


+ (HMVRVAirModelStatus)nextModelStatusWithModelStatus:(HMVRVAirModelStatus)airModelStatus {
    NSArray <NSNumber *>*orderModelStatusArray = @[
                                                   @(HMAirModelStatusVRVCool),             // 制冷
                                                   @(HMAirModelStatusVRVHeat),             // 制热
                                                   @(HMAirModelStatusVRVFanOnly),          // 通风
                                                   @(HMAirModelStatusVRVDehumidification), // 除湿
//                                                   @(HMAirModelStatusVRVAuto),             // 自动
                                                   ];
    __block NSUInteger currentIndex = -1;
    [orderModelStatusArray enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.integerValue == airModelStatus) {
            currentIndex = idx;
            *stop = YES;
        }
    }];
    if (currentIndex == -1) {
        DLog(@"VRV: 查找下一个模式，但没找到当前模式(%d)", airModelStatus);
    }
    // 没找到则用自动模式
    NSUInteger nextIndex = (currentIndex + 1) % orderModelStatusArray.count;
    return orderModelStatusArray[nextIndex].integerValue;
}

#pragma mark - setupAction
+ (id)setAirBindModel:(HMVRVAirModelStatus)statusModel sceneBind:(id)sceneBind {
    [self checkWhetherOutOfRangeWithAirmodel:statusModel]; // 检查模式越界
    id<OrderProtocol> action = sceneBind;
    action.value2 = [self replaceBits:0 withBits:((int)(statusModel-HMAirModelStatusVRVStartPoint)) from:0 length:8];
    action.bindOrder = kVRVStatusControlOrder;
    return action;
}
+ (id)setBindWindLevel:(HMVRVAirWindLevel)level sceneBind:(id)sceneBind {
    [self checkWhetherOutOfRangeWithWindlevel:level]; // 检查风速越界
    id<OrderProtocol> action = sceneBind;
    action.value3 = [self replaceBits:0 withBits:((int)(level-HMAirWindLevelVRVStartPoint)) from:0 length:8];
    action.bindOrder = kVRVStatusControlOrder;
    return action;
}
+ (id)setBindAirOpen:(BOOL)isOpen senebind:(id)scenebind {
    id<OrderProtocol> action = scenebind;
    if(isOpen) {
        action.value1 = [self replaceBits:0 withBits:0 from:0 length:1];
    }else {
        action.value1 = [self replaceBits:0 withBits:1 from:0 length:1];
    }
    action.bindOrder = kVRVStatusControlOrder;
    return action;
}
+ (id)setBindTemperature:(NSInteger)temperature senebind:(id)scenebind {
    id<OrderProtocol> action = scenebind;
    int value1 =  0;
    temperature = temperature * 100;
    action.value4 = [self replaceBits:value1 withBits:((int)temperature) from:16 length:16];
    action.bindOrder = kVRVStatusControlOrder;
    return action;
}

#pragma mark - actionStatus
+ (BOOL)bindOpen:(id)sceneBind {
    id<OrderProtocol> action = sceneBind;
    BOOL isOpen;
    int value1 = action.value1;
    if ((value1 & 1) == 0) {
        isOpen = YES;
    } else {
        isOpen = NO;
    }
    return isOpen;
}
+ (HMVRVAirModelStatus)bindModel:(id)sceneBind {
    id<OrderProtocol> action = sceneBind;
    return action.value2+HMAirModelStatusVRVStartPoint;
}
+ (HMVRVAirWindLevel)bindWindLevel:(id)sceneBind {
    id<OrderProtocol> action = sceneBind;
    
    int windLevel = (action.value3 & 0xff) + HMAirWindLevelVRVStartPoint;
    return windLevel;
}
+ (int)getBindSettingTemperature:(id)sceneBind {
    id<OrderProtocol> action = sceneBind;
    int realSettingTemperature = SettingTemp(action.value4);
    int settingTemperature = [self letValue:realSettingTemperature insideRangeWithLow:16 high:32];
    return settingTemperature;
}
#pragma mark - 设置电源打开
+ (void)openAirConditionWithCmd:(ControlDeviceCmd *)cmd {
    cmd.value1 = 0;
}

#pragma mark - 故障码
+ (HMVRVErrorCode *)errorStatus:(HMDevice *)device {
    HMVRVErrorCode *errorCode = nil;
    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
    if (status) {
        /** 高16位为异常编码 */
        int errorValue = (status.value3 >> 16) & 0xffff;
        if (errorValue) {
            errorCode = [[HMVRVErrorCode alloc] init];
            errorCode.errorCode = errorValue;
            errorCode.errorDescription = @"Error!!!";
        }
    }
    return errorCode;
}

#pragma mark - 设备状态
+ (HMDeviceStatus *)hasStatus:(HMDevice *)device {
    return [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
}

+ (BOOL)isMainControlOnline:(HMDevice *)device {
    NSArray <HMDevice *>*deviceArray = [HMDevice deviceWithSameExtAddress:device];
    for (HMDevice *device in deviceArray) {
        // 找到主控制器
        if (isVRVAirConditionController(device)) {
            HMDeviceStatus *status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:device.uid];
            // 主控制器在设备状态表有状态，且online=0才为离线
            if (status && !status.online) {
                return NO;
            }
            break;
        }
    }
    return YES;
}


#pragma mark - 面板地址码
// 面板地址码
+ (NSString *)addressCodeWithDevice:(HMDevice *)device {
    // 面板地址码为 endPoint+14 (10-4F的十进制)
    NSString *panelAddressCode = [NSString stringWithFormat:@"%d", device.endpoint+14];
    if (device.endpoint < 2 || device.endpoint > 0x4f-14) { // endPoint范围不合法
        DLog(@"self.device.endpoint: %d [endPoint范围不合法]", device.endpoint);
    }
    return panelAddressCode;
}

#pragma mark - Private Methods 
// 把value的from,length范围内的位替换为bits
+ (int)replaceBits:(int)value withBits:(int)bits from:(int)from length:(int)length {
    for (int i=0; i<length; i++) {
        int currentPosition = from+i;
        if (bits & (1<<i)) {
            value = [self value1:value position:currentPosition+1];
        } else {
            value = [self value0:value position:currentPosition+1];
        }
    }
    return value;
}

// 检查风速是否越界
+ (void)checkWhetherOutOfRangeWithWindlevel:(HMVRVAirWindLevel)windlevel {
    if (windlevel <= HMAirWindLevelVRVStartPoint || windlevel > HMAirWindLevelVRVMediumHigh) {
        DLog(@"warning: VRV风速(%d)越界", windlevel);
    } else if (windlevel < HMAirWindLevelVRVLow || windlevel > HMAirWindLevelVRVHigh) {
        DLog(@"warning: VRV风速(%d)不在弱中强范围内", windlevel);
    }
}

// 检查模式是否越界
+ (void)checkWhetherOutOfRangeWithAirmodel:(HMVRVAirModelStatus)airmodel {
    if (airmodel <= HMAirModelStatusVRVStartPoint || airmodel > HMAirModelStatusVRVSleep) {
        DLog(@"warning: VRV模式(%d)越界", airmodel);
    }
}

#pragma mark - Private Method
// 把值限定在low和high范围内，超出则设为low或者high
+ (int)letValue:(int)value insideRangeWithLow:(int)low high:(int)high {
    if (value < low) {
        value = low;
    } else if (value > high) {
        value = high;
    }
    return value;
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


#pragma mark - 判断面板类型
+ (HMAirConditionerPanelType)getAirConditionerPanelTypeWithDevice:(HMDevice *)device {
    
    HMAirConditionerPanelType type = HMAirConditionerPanelType_AirMasterPro;
    
    if ([device.model isEqualToString:kWifiAirconditionerModelID]) {
        type = HMAirConditionerPanelType_YiLin;
        
    }else if ([device.model isEqualToString:kSkyworthModelID]) {
        type = HMAirConditionerPanelType_ChuangWei;
        
    }else if ([device.model isEqualToString:KVRVAirConditionPanelModelID]) {
        type = HMAirConditionerPanelType_AirMaster;
        
    }else {
        HMDeviceDesc *deviceDesc = [HMDeviceDesc objectWithModel:device.model];
        if (deviceDesc.deviceFlag == 4) {
            type = HMAirConditionerPanelType_AirMasterPro;
        }
    }
    return type;
}

///为了不修改之前的方法重新写一个 这个方法的默认值 为未知
/// @param device
+ (HMAirConditionerPanelType)getAirConditionerPanelTypeWithDevice1:(HMDevice *)device {
    
    HMAirConditionerPanelType type = HMAirConditionerPanelType_Unkown;
    
    if ([device.model isEqualToString:kWifiAirconditionerModelID]) {
        type = HMAirConditionerPanelType_YiLin;
        
    }else if ([device.model isEqualToString:kSkyworthModelID]) {
        type = HMAirConditionerPanelType_ChuangWei;
        
    }else if ([device.model isEqualToString:KVRVAirConditionPanelModelID]) {
        type = HMAirConditionerPanelType_AirMaster;
        
    }else {
        HMDeviceDesc *deviceDesc = [HMDeviceDesc objectWithModel:device.model];
        if (deviceDesc.deviceFlag == 4) {
            type = HMAirConditionerPanelType_AirMasterPro;
        }
    }
    return type;
    
}

+ (BOOL)linkageConditionSpecialStatus:(HMDevice *)device {
    HMAirConditionerPanelType type = [self getAirConditionerPanelTypeWithDevice:device];
    
    if (type == HMAirConditionerPanelType_YiLin || type == HMAirConditionerPanelType_ChuangWei) {
        return YES;
    }else {
        return NO;
    }
    
}

@end
