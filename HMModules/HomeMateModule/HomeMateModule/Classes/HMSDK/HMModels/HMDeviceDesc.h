//
//  DeviceDesc.h
//  HomeMate
//
//  Created by liuzhicai on 16/1/13.
//  Copyright © 2017年 Air. All rights reserved.
//


#import "HMBaseModel.h"

typedef NS_ENUM(int, HMLockDeviceFlag) {
     HMLockDeviceFlagT1C = 1,
     HMLockDeviceFlagH1 = 2,
     HMLockDeviceFlagC1 = 3,
};

@interface HMDeviceDesc : HMBaseModel

@property (nonatomic, copy)NSString *deviceDescId;

@property (nonatomic, copy)NSString *source;

@property (nonatomic, copy)NSString *model;

@property (nonatomic, copy)NSString *productModel;

@property (nonatomic, copy)NSString *internalModel;

@property (nonatomic, copy)NSString *endpointSet;

@property (nonatomic, copy)NSString *picUrl;
@property (nonatomic, assign)int hostFlag;
@property (nonatomic, assign)int wifiFlag; //  0: ZigBee设备 1: WiFi设备 2: 大主机 3: 小主机
@property (nonatomic, assign)int deviceFlag;
@property (nonatomic, assign)int valueAddedService;  //增值服务 0=关闭 1=开启

// 根据32位标识符能查出对应的设备信息
+ (instancetype)objectWithModel:(NSString *)model;

+ (instancetype)objectFromDictionary:(NSDictionary *)dict;

// 根据 model 获取默认名称
+ (NSString *)defaultNameWithModel:(NSString *)model;

// 根据 model 获取DeviceType (注！！！ 只适用于多端设备类型都相同的设备)
+ (KDeviceType)descTableDeviceTypeWithModel:(NSString *)model;

@end
