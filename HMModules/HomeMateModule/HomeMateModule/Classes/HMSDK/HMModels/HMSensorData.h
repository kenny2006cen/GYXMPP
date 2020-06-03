//
//  HMSensorData.h
//  HomeMate
//
//  Created by JQ on 16/8/11.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMSensorData : HMBaseModel

@property (nonatomic, copy) NSString *sensorDataLastId;

@property (nonatomic, copy) NSString *deviceId;

/**
 *  数据包时间戳
 */
@property (nonatomic, assign) int timestamp;

/**
 *  电池电量
 */
@property (nonatomic, assign) int batteryValue;

/**
 *  一氧化碳浓度
 */
@property (nonatomic, assign) int coConcentration;

/**
 *  甲醛浓度, 取值时用hchoConcentrationStr
 *  从服务器或设备获取到的数值范围为1~1000，
 *  原始数值范围：0.01~10 mg/m3,
 *  所以数据显示需要缩小100倍
 */
@property (nonatomic, assign) int hchoConcentration;
@property (nonatomic, copy) NSString *hchoConcentrationStr;

/**
 *  温度，取值时用temperatureStr，
 *  温度范围：
 *  从服务器或设备获取到的数值范围为-250~550，
 *  原数值范围：-25.0~55.0℃
 *  所以数据显示需要缩小10倍
 */
@property (nonatomic, assign) int temperature;
@property (nonatomic, copy) NSString *temperatureStr;


/**
 *  湿度
 */
@property (nonatomic, assign) int humidity;

/**
 *  0：正常；1：报警
 */
@property (nonatomic, assign) int alarmStatus;//alarmLevel;

/**
 *  PM2.5  单位：ug/ m³
 */
@property (nonatomic, assign) int pm25;


+ (instancetype)objectWithDeviceId:(NSString *)deviceId uid:(NSString *)uid;

+ (instancetype)sensorDataWithDictionary:(NSDictionary *)dic;

+ (BOOL)deleteWithDeviceId:(NSString *)deviceId;



/**
 *  获取温湿度对应的字符串
 */
+ (NSString *)temperatureAndHumidityStringWithSensorData:(HMSensorData *)sensorData;

/**
 *  YES：正在报警，NO:没有报警
 */
- (BOOL)isOccurred;

@end
