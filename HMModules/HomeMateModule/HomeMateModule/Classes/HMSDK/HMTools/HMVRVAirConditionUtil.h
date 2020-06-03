//
//  HMVRVAirConditionUtil.h
//  HomeMate
//
//  Created by peanut on 2017/1/10.
//  Copyright © 2017年 Air. All rights reserved.
//


#import <Foundation/Foundation.h>

@class HMDevice;
@class HMDeviceStatus;
@class ControlDeviceCmd;

@interface HMVRVErrorCode : NSObject

/**
 故障码
 */
@property (nonatomic, assign) int errorCode;

/**
 故障描述
 */
@property (nonatomic, copy) NSString *errorDescription;
@end

//空调面板类型
typedef NS_ENUM(NSUInteger, HMAirConditionerPanelType) {
    HMAirConditionerPanelType_YiLin,
    HMAirConditionerPanelType_ChuangWei,
    HMAirConditionerPanelType_AirMaster,
    HMAirConditionerPanelType_AirMasterPro,
    HMAirConditionerPanelType_Unkown,
};

// wifi空调/空调面板模式类型
typedef NS_ENUM(NSInteger, HMVRVAirModelStatus) {
    
    /** 新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理 */
    HMAirModelStatusVRVStartPoint,       // 作为基准，不使用
    /** VRV自动模式(新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理) */
    HMAirModelStatusVRVAuto,
    /** VRV除湿模式(新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理) */
    HMAirModelStatusVRVDehumidification,
    /** VRV制冷模式(新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理) */
    HMAirModelStatusVRVCool,
    /** VRV制热模式(新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理) */
    HMAirModelStatusVRVHeat,
    /** VRV紧急加热模式(新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理) */
    //HMAirModelStatusVRVEmergencyHeating, [替换为采暖模式]
    /** VRV采暖模式(协议没有，需要协商)(新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理) */
    HMAirModelStatusVRVHeatPlumbing,
    /** VRV预冷却模式(新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理) */
    HMAirModelStatusVRVPrecooling,
    /** VRV送风模式(新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理) */
    HMAirModelStatusVRVFanOnly,
    /** VRV干燥模式(新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理) */
    HMAirModelStatusVRVDry,
    /** VRV睡眠模式(新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理) */
    HMAirModelStatusVRVSleep,
    /** VRV采暖模式(协议没有，需要协商)(新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理) */
    //    HMAirModelStatusVRVHeatPlumbing,
};

// wifi空调/空调面板 风速
typedef NS_ENUM(NSInteger,HMVRVAirWindLevel) {
    /** 新加的VRV，在HMVRVAirConditionUtil处理，HMAirConditionUitl不做处理 */
    HMAirWindLevelVRVStartPoint,       // 作为基准，不使用
    HMAirWindLevelVRVLow,              // 弱
    HMAirWindLevelVRVMedium,           // 中
    HMAirWindLevelVRVHigh,             // 强
    HMAirWindLevelVRVOn,               //
    HMAirWindLevelVRVAuto,             //
    HMAirWindLevelVRVSmart,            //
    HMAirWindLevelVRVMediumLow,        //
    HMAirWindLevelVRVMediumHigh,       //
    
};

@interface HMVRVAirConditionUtil : NSObject

/**
 取得当前空调模式对应的下一个空调模式

 @param airModelStatus 当前空调模式
 @return 下一个空调模式
 */
+ (HMVRVAirModelStatus)nextModelStatusWithModelStatus:(HMVRVAirModelStatus)airModelStatus;

/**
 是否处于故障状态下，是则返回故障对象，不存在则不返回

 @param device 设备
 @return 故障对象
 */
+ (HMVRVErrorCode *)errorStatus:(HMDevice *)device;


/**
 是否有设备状态，有则返回状态

 @param device 设备
 @return 状态
 */
+ (HMDeviceStatus *)hasStatus:(HMDevice *)device;

/**
 面板对应的主控制器是否在线(主控制器在设备状态表有状态，且online=0才为离线)

 @param device 面板设备
 @return 是/否
 */
+ (BOOL)isMainControlOnline:(HMDevice *)device;

/**
 面板地址码。地址码为endPoint+14，以十进制方式显示

 @param device VRV子面板设备
 @return 该设备的面板地址码
 */
+ (NSString *)addressCodeWithDevice:(HMDevice *)device;

#pragma mark - Func Methods

/**
 将value的第position位设为1
 
 @param value    修改前的值
 @param position 第position位设定为1，position的序号从1开始
 @return         修改后的值
 */
+ (int)value1:(int)value position:(int)position;
/**
 将value的第position位设为0
 
 @param value    修改前的值
 @param position 第position位设定为0，position的序号从1开始
 @return         修改后的值
 */
+ (int)value0:(int)value position:(int)position;

#pragma mark - 控制或命令方法
/**
 * 设置电源打开(控制命令)
 */
+ (void)openAirConditionWithCmd:(ControlDeviceCmd *)cmd;

+ (ControlDeviceCmd *)setTemperature:(NSInteger)temperature device:(HMDevice *)device;
+ (ControlDeviceCmd *)openAirCondition:(BOOL)isOpen device:(HMDevice *)device;
+ (ControlDeviceCmd *)setWindLevel:(HMVRVAirWindLevel)level device:(HMDevice *)device;
+ (ControlDeviceCmd *)setAirModel:(HMVRVAirModelStatus)statusModel device:(HMDevice *)device;

#pragma mark - getStatus
+ (int)airconditionCurrentValue:(HMDevice *)device;
+ (int)airconditionSettingValue:(HMDevice *)device;
+ (HMVRVAirWindLevel)airWindLevel:(HMDevice *)device;
+ (BOOL)airIsOpen:(HMDevice *)device;
+ (HMVRVAirModelStatus)modelStatus:(HMDevice *)device;

#pragma mark - setupAction
+ (id)setAirBindModel:(HMVRVAirModelStatus)statusModel sceneBind:(id)sceneBind;
+ (id)setBindWindLevel:(HMVRVAirWindLevel)level sceneBind:(id)sceneBind;
+ (id)setBindAirOpen:(BOOL)isOpen senebind:(id)scenebind;
+ (id)setBindTemperature:(NSInteger)temperature senebind:(id)scenebind;

#pragma mark - actionStatus
+ (BOOL)bindOpen:(id)sceneBind;
+ (HMVRVAirModelStatus)bindModel:(id)sceneBind;
+ (HMVRVAirWindLevel)bindWindLevel:(id)sceneBind;
+ (int)getBindSettingTemperature:(id)sceneBind;


#pragma mark - 判断面板类型
+ (HMAirConditionerPanelType)getAirConditionerPanelTypeWithDevice:(HMDevice *)device;

///为了不修改之前的方法重新写一个 这个方法的默认值 为未知
/// @param device 设备
+ (HMAirConditionerPanelType)getAirConditionerPanelTypeWithDevice1:(HMDevice *)device;


+ (BOOL)linkageConditionSpecialStatus:(HMDevice *)device;
@end









