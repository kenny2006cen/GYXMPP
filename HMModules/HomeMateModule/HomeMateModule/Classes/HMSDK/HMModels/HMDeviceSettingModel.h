//
//  HMDeviceSettingModel.h
//  HomeMate
//
//  Created by liuzhicai on 16/7/6.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel+Extension.h"
#import "HMConstant.h"

@interface HMDeviceSettingModel : HMBaseModel

/**
 *  主键，设备唯一标识
 */
@property (nonatomic, copy)NSString *deviceId;

/**
 *  主键，参数的唯一标识
 *  每个设备中的paramId是唯一的，不可重复。
 *  具有特定含义，如：relay_off_time延时关时长。
 */
@property (nonatomic, copy)NSString *paramId;


/**
 *  参数类型
    1:布尔，2:整数，3:小数，4:文本，5:二进制，6:JSON，7:自定义

 */
@property (nonatomic, assign)int paramType;

/**
 *  参数的值，如果是数值、小数，均转换成字符串存储。布尔转换成False或True，二进制的转换成HEX文本串保存。如果是复合类型，则保存为json格式。
 */
@property (nonatomic, copy)NSString *paramValue;


/**
 *  是否开启了缓亮缓灭，查不到则返回NO
 */
+ (BOOL)slowOnSlowOffIsEnableWithDeviceId:(NSString *)deviceId;

/**
 *  是否开启了缓亮缓灭, 用户给个默认值 defaultValue，查不到返回 defaultValue
 */
+ (BOOL)slowOnSlowOffIsEnableWithDeviceId:(NSString *)deviceId defalutValue:(BOOL)defaultValue;

/**
 *  是否开启了延时关闭
 */
+ (BOOL)delayOffIsEnableWithDeviceId:(NSString *)deviceId;


/**
 *  是否禁止在手机端关闭电源,新配电箱表示是否网络锁定， 为YES 则 情景绑定那里不显示，二级界面没有开关
 */
+ (BOOL)switchIsLockOnAppWithDevice:(HMDevice *)device;

/**
 新配电箱 的分控的硬件是否已网络锁定
 
 0 表示 硬件 正常
 1 表示 硬件网络已锁定， 定时、情景那里app不显示

 @param deviceId 分控deviceId
 */
+ (BOOL)hardWareIsLockWithDeviceId:(NSString *)deviceId;

/**
 *  是否启动自定义电流保护
 */
+ (BOOL)eletricitySaveIsOnWithDeviceId:(NSString *)deviceId;

/**
 *  保护点持续时间(s)
 */
+ (int)eletricTimeWithDeviceId:(NSString *)deviceId;

/**
 *  保护点电流(mA)     返回数据以 mA 为单位
 */
+ (int)eletricValueWithDevice:(HMDevice *)device;

/**
 *  缓亮缓灭时间长度，查不到默认返回 0
 */
+ (int)slowOnSlowOffTimeWithDeviceId:(NSString *)deviceId;

/**
 *  缓亮缓灭时间长度,
    defaultTime ： 用户给定查不到时的默认值
 */
+ (int)slowOnSlowOffTimeWithDeviceId:(NSString *)deviceId defauleTime:(int)defaultTime;

/**
 *  延迟关时间长度
 */
+ (int)delayOffTimeWithDeviceId:(NSString *)deviceId;

/**
 *  设备排列序号 （配电箱的分控有排序）
 */
+ (int)sortNumOfDeviceId:(NSString *)deviceId;

+ (int)abnormalFlagValueWithDeviceId:(NSString *)deviceId;


/**
 配电箱异常标志对象

 */
+ (HMDeviceSettingModel *)abnormalDistObjWithDeviceId:(NSString *)deviceId;
///**
// *  查询传感器接入模块的设备类型
// */
//+ (int)selectSubDeviceTypeWithDeviceType:(NSString *)deviceId;

// MARK: 单火开关的面板类型
+ (int)boardTypeWithDeviceId:(NSString *)deviceId;


/**
 新配电箱  是否设置过总闸

 @param deviceId 新配电箱虚拟端点（即端点0）的deviceId
 */
+ (BOOL)isHasSetGeneralGateWithDeviceId:(NSString *)deviceId;


/**
 某个配电箱下面的端点是否为总闸
 
 @param chlDeviceId 子端点
 */
+ (BOOL)isGeneralGateWithChildDeviceId:(NSString *)chlDeviceId;


/**
 配电箱的总闸的deviceId  无则为空

 @param deviceId 配电箱虚拟端点的deviceId，即首页显示那个
 */
+ (NSString *)generalGateOfDistBoxDeviceId:(NSString *)deviceId;


/**
 查询参数值

 @param deviceId 设备唯一标识
 @param paramId 参数的唯一标识
 */
+ (NSString *)paramValueOfDeviceId:(NSString *)deviceId paramId:(NSString *)paramId;


// 获取T1门锁的时间
+ (int)T1timeWithDeviceId:(NSString *)deviceId;


/**
 查询mixpad语音控制范围
 @return 0:全部(默认),  1:部分
 */
+ (int)voiceControlRangeForMixPadWithDeviceId:(NSString *)deviceId;


/**
 查询mixpad唤醒词
 */
+ (NSString *)wakeupWordForMixPadWithDeviceId:(NSString *)deviceId;

//智慧光源
/// 查询缓亮缓灭设置时间
/// @param defaultTime 默认时长
/// @param on yes:缓亮   no:缓灭
+ (int)getWisdomLightSlowOnAndOffTimeWithDeviceId:(NSString *)deviceId defauleTime:(int)defaultTime on:(BOOL)on;

/// 获取通电默认状态
+ (int)getWisdomLightPowerOnDefaultStatusWithDeviceId:(NSString *)deviceId;

/**
 查询mixpad是否连续对话
 @return 0:不开启连续对话(默认),  1:开启连续对话
 */
+ (int)mixpadContinuousDialogue:(NSString *)deviceId;

/**
 查询mixpad是否就近唤醒
 @return 0:不开启就近唤醒(默认),  1:开启就近唤醒
 */
+ (int)mixpadNearbyWeakUp:(NSString *)deviceId;

@end
