//
//  HMDistBoxAttributeModel.h
//  HomeMateSDK
//
//  Created by liuzhicai on 16/10/17.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"
#import "HMDevice.h"

typedef enum {
    KDBoxAbnorTypeNormal = 0,
    KDBoxAbnorTypeUnderVoltage = 1, //  欠压
    KDBoxAbnorTypeOverVoltage = 2, //  过压
    KDBoxAbnorTypeOverCurrent = 4, // 过流
    KDBoxAbnorTypeOverCurrentAndVoltage = 6, // 过压过流
    KDBoxAbnorTypeLeakageElectric = 8, // 漏电
}KDBoxAbnorType;

@interface HMDistBoxAttributeModel : HMBaseModel

@property (nonatomic, retain)NSString *   deviceId;

/**
 *  属性标识
 */
@property (nonatomic, assign)int   attributeId;

/**
 *  实时属性值
 */
@property (nonatomic, assign)int   attrValue;


// ************* 非表结构字段 ****************
/**
 *  电压
 */
@property (nonatomic, assign)CGFloat voltage;

/**
 *  电流
 */
@property (nonatomic, assign)CGFloat current;


/**
 *  功率
 */
@property (nonatomic, assign)CGFloat power;

/**
 *  功率因数
 */
@property (nonatomic, assign)CGFloat powerFactor;

/**
 *  过载电压
 */
@property (nonatomic, assign)CGFloat overVoltage;

/**
 *  过载电流
 */
@property (nonatomic, assign)CGFloat overCurrent;

+ (CGFloat)voltageWithDeviceId:(NSString *)deviceId; // 电压
+ (CGFloat)currentWithDeviceId:(NSString *)deviceId; // 电流
+ (CGFloat)powerWithDeviceId:(NSString *)deviceId; // 功率
+ (CGFloat)powerFactorWithDeviceId:(NSString *)deviceId; // 功率因素
+ (CGFloat)overVoltageWithDeviceId:(NSString *)deviceId; // 过载电压
+ (CGFloat)overCurrentWithDeviceId:(NSString *)deviceId; // 过载电流

+ (int)abnormalValueWithDevice:(HMDevice *)device; // 异常属性值

+ (int)rateCurrentValueWithDeviceId:(NSString *)deviceId; // 额定电流值


/**
 把配电箱的电压都重置为0( 0,1端点除外 )，查询最新电压

 @param extAddr 配电箱MAC地址
 */
+ (void)resetVoltageToZeroWithExtAddr:(NSString *)extAddr;


/**
 删除配电箱实时数据 (功率、功率因素、电压、电流)

 @param extAddr mac地址
 */
+ (void)deleteRealTimeDataWithExtAddr:(NSString *)extAddr;


/****   以下方法弃用      *******/
/**
 如果一个分控能控制或者能收到开关属性报告返回，则说明正常，把异常标志为的值置0，防止界面上一直显示红色的异常消息

 @param deviceId 分控deviceId
 */
//+ (void)updateAbnormalFlagWithDeviceId:(NSString *)deviceId;



@end
