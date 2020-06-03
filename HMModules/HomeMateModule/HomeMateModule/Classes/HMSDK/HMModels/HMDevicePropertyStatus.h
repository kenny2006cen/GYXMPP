//
//  HMDevicePropertyStatus.h
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/10/10.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMDevicePropertyStatus : HMBaseModel

@property (nonatomic, copy) NSString *devicePropertyStatusId;


//设备Id
@property (nonatomic, copy) NSString *deviceId;

///设备属性
@property (nonatomic, copy) NSString *property;

///状态值
@property (nonatomic, copy) NSString *value;

+ (NSString *)valueOfProperty:(NSString *)property uid:(NSString *)uid;

+ (NSString *)valueOfProperty:(NSString *)property uid:(NSString *)uid deviceId:(NSString *)deviceId;

+ (void)deletePropertyOfUid:(NSString *)uid deviceId:(NSString *)deviceId;
@end

