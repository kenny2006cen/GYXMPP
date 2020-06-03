//
//  HMSecurityBusiness.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMSecurityBusiness.h"

@implementation HMSecurityBusiness
+(NSArray *)securityDeviceArray
{
    return @[@(KDeviceTypeCamera),
             @(KDeviceTypeLock),
             @(KDeviceTypeOrviboLock),
             @(KDeviceTypeLockH1),
             @(KDeviceTypeInfraredSensor),
             @(KDeviceTypeMagneticDoor),
             @(KDeviceTypeMagneticWindow),
             @(KDeviceTypeMagneticDrawer),
             @(KDeviceTypeMagneticOther),
             @(KDeviceTypeSmokeTransducer),
             @(KDeviceTypeMagnet),
             @(KDeviceTypeCarbonMonoxideAlarm),
             @(kDeviceTypeWaterDetector),
             @(KDeviceTypeEmergencyButton),
             @(KDeviceTypeAlarmDevice)
             ];
}

+(NSArray *)subDeviceTypeisSecurityArray
{
    return @[@(KDeviceTypeInfraredSensor),
             @(KDeviceTypeDoubleInfrared),
             @(KDeviceTypeMagneticDoor),
             @(KDeviceTypeMagneticWindow),
             @(KDeviceTypeMagneticDrawer),
             @(KDeviceTypeMagneticOther),
             @(KDeviceTypeSmokeTransducer),
             @(KDeviceTypeMagnet),
             @(kDeviceTypeWaterDetector),
             @(KDeviceTypeEmergencyButton)
             ];
}

+(NSString *)deviceTypesArrayStr:(NSArray *)deviceTypeArr {
    NSString * (^object2String)(NSArray *) = ^(NSArray *objectArray){
        
        NSMutableString *objString = [NSMutableString string];
        for (NSString *obj in objectArray) {
            [objString appendFormat:@"%@,",obj];
        }
        // 删除最后一个 ',' 逗号
        if ([objString hasSuffix:@","]) {
            NSString *result = [objString substringToIndex:objString.length - 1];
            [objString setString:result];
        }
        return objString;
    };
    
    return object2String(deviceTypeArr);
}

+ (NSArray *)getAllSecurityDevicesWithFamilyId:(NSString *)familyId andUserId:(NSString *)userId {
    
    NSString *securityDeviceStr = [HMSecurityBusiness deviceTypesArrayStr:[HMSecurityBusiness securityDeviceArray]];
    NSString *subDeviceTypeisSecurityStr = [HMSecurityBusiness deviceTypesArrayStr:[HMSecurityBusiness subDeviceTypeisSecurityArray]];
    
    NSString *securityDeviceSQL = [NSString stringWithFormat:@"select * from (SELECT * FROM device WHERE uid IN %@) where (deviceType in (%@) or (deviceType = '%d' AND subDeviceType in (%@))) and delFlag = 0 order by createTime desc",[HMUserGatewayBind uidStatement], securityDeviceStr, KDeviceTypeSensorAccessModuleType,subDeviceTypeisSecurityStr];
    
    __block NSMutableArray *devicesArr = [NSMutableArray array];
    queryDatabase(securityDeviceSQL, ^(FMResultSet *rs) {
        HMDevice *device = [HMDevice object:rs];
        [devicesArr addObject:device];
    });
    return [devicesArr copy];
}

+ (NSArray *)getAllSecurityDevicesWhoWithTopActionByFamilyId:(NSString *)familyId andUserId:(NSString *)userId {
    
    NSString *securityDeviceStr = [HMSecurityBusiness deviceTypesArrayStr:[HMSecurityBusiness securityDeviceArray]];
    NSString *subDeviceTypeisSecurityStr = [HMSecurityBusiness deviceTypesArrayStr:[HMSecurityBusiness subDeviceTypeisSecurityArray]];
    
    NSString *securityDeviceSQL = [NSString stringWithFormat:@"select * from (SELECT * FROM device WHERE uid IN %@) where (deviceType in (%@) or (deviceType = '%d' AND subDeviceType in (%@))) and delFlag = 0 order by createTime desc",[HMUserGatewayBind uidStatement], securityDeviceStr, KDeviceTypeSensorAccessModuleType,subDeviceTypeisSecurityStr];
    
    NSString *topDeviceSQL = [NSString stringWithFormat:@"select * from (%@) as d left join securityDeviceSort on d.deviceId = securityDeviceSort.sortDeviceId where sortFamilyId = '%@' and sortUserId = '%@' order by sortTime desc",securityDeviceSQL,familyId,userId];
    
    __block NSMutableArray *topDevicesArr = [NSMutableArray array];
    
    queryDatabase(topDeviceSQL, ^(FMResultSet *rs) {
        
        HMDevice *device = [HMDevice object:rs];
        
        if (device.deviceType == KDeviceTypeOrviboLock) {
            
            HMDeviceDesc * desc = [HMDeviceDesc objectWithModel:device.model];
            if (desc.deviceFlag == HMLockDeviceFlagC1) {
                [topDevicesArr addObject:device];
            }else {
                HMUserGatewayBind *bind = [HMUserGatewayBind bindWithUid:device.blueExtAddr];
                if (bind) {//有绑定关系才显示
                    [topDevicesArr addObject:device];
                }
            }
            
            
        }else {
            [topDevicesArr addObject:device];
        }
    });
    return [topDevicesArr copy];
}

+ (NSArray *)getAllSecurityDevicesWhoWithoutTopActionByFamilyId:(NSString *)familyId andUserId:(NSString *)userId {
    
    NSString *securityDeviceStr = [HMSecurityBusiness deviceTypesArrayStr:[HMSecurityBusiness securityDeviceArray]];
    NSString *subDeviceTypeisSecurityStr = [HMSecurityBusiness deviceTypesArrayStr:[HMSecurityBusiness subDeviceTypeisSecurityArray]];
    
    NSString *securityDeviceSQL = [NSString stringWithFormat:@"select * from (SELECT * FROM device WHERE uid IN %@) where (deviceType in (%@) or (deviceType = '%d' AND subDeviceType in (%@))) and delFlag = 0 order by createTime desc",[HMUserGatewayBind uidStatement], securityDeviceStr, KDeviceTypeSensorAccessModuleType,subDeviceTypeisSecurityStr];
    
    NSString *otherDeviceSQL = [NSString stringWithFormat:@"select * from (%@) as d left join securityDeviceSort on d.deviceId = securityDeviceSort.sortDeviceId where sortDeviceId is NULL and sortUserId is NULL and sortFamilyId is NULL",securityDeviceSQL];
    
    __block NSMutableArray *noTopDevicesArr = [NSMutableArray array];
    queryDatabase(otherDeviceSQL, ^(FMResultSet *rs) {
        HMDevice *device = [HMDevice object:rs];
        
        if (device.deviceType == KDeviceTypeOrviboLock) {
            
            HMDeviceDesc * desc = [HMDeviceDesc objectWithModel:device.model];
            if (desc.deviceFlag == HMLockDeviceFlagC1) {
                [noTopDevicesArr addObject:device];
            }else {
                HMUserGatewayBind *bind = [HMUserGatewayBind bindWithUid:device.blueExtAddr];
                if (bind) {//有绑定关系才显示
                    [noTopDevicesArr addObject:device];
                }
            }
            
        }else {
            [noTopDevicesArr addObject:device];
        }
        
    });
    return [noTopDevicesArr copy];
}

+ (NSArray *)getSecurityDevicesOfRoomId:(NSString *)roomId familyId:(NSString *)familyId userId:(NSString *)userId
{
    NSString *securityDeviceStr = [self deviceTypesArrayStr:[HMSecurityBusiness securityDeviceArray]];
    NSString *subDeviceTypeisSecurityStr = [self deviceTypesArrayStr:[HMSecurityBusiness subDeviceTypeisSecurityArray]];
    NSString *sql = nil;
    if ([HMRoom isDefaultRoom:roomId]) { // 这样写是为了兼容默认房间为空的情况，以及设备roomId不在房间表的情况
        sql = [NSString stringWithFormat:@"select * from (SELECT * FROM device WHERE uid IN %@) where (deviceType in (%@) or (deviceType = '%d' AND subDeviceType in (%@))) and (roomId = '%@' or ((length(roomId) < 32 or roomId is null or roomId not in (select roomId from room where familyId = '%@' and delFlag = 0) or roomId in (select roomId from room where roomType = -1 and delFlag = 0 and familyId = '%@')))) and delFlag = 0",[HMUserGatewayBind uidStatement], securityDeviceStr, KDeviceTypeSensorAccessModuleType,subDeviceTypeisSecurityStr,roomId,familyId,familyId];
        
    } else {
        sql = [NSString stringWithFormat:@"select * from (SELECT * FROM device WHERE uid IN %@) where (deviceType in (%@) or (deviceType = '%d' AND subDeviceType in (%@))) and roomId = '%@' and delFlag = 0",[HMUserGatewayBind uidStatement], securityDeviceStr, KDeviceTypeSensorAccessModuleType,subDeviceTypeisSecurityStr,roomId];
    }
    
    __block NSMutableArray *devicesArr = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMDevice *device = [HMDevice object:rs];
        [devicesArr addObject:device];
    });
    return [devicesArr copy];
}



@end
