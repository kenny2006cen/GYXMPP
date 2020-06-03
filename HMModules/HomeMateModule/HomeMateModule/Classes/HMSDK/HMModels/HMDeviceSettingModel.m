//
//  HMDeviceSettingModel.m
//  HomeMate
//
//  Created by liuzhicai on 16/7/6.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMDeviceSettingModel.h"

@implementation HMDeviceSettingModel

+(NSString *)tableName
{
    return @"deviceSetting";
}
+ (NSArray*)columns
{
    return @[column("deviceId","text"),
             column("paramId","text"),
             column("paramType","integer"),
             column("paramValue","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    //primary key (deviceId,paramId)
    return @"UNIQUE (deviceId, paramId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}



+ (int)sortNumOfDeviceId:(NSString *)deviceId
{
    NSString *sql = [self dbSqlWithDeviceId:deviceId
                                    paramId:@"sort_weight"];
    return [self queryDistBoxSortNumWithSql:sql];
}

+ (int)slowOnSlowOffTimeWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self dbSqlWithDeviceId:deviceId
                                    paramId:@"level_delay_time"];
    return [self queryIntValueSql:sql defaultTime:0];
}

+ (int)slowOnSlowOffTimeWithDeviceId:(NSString *)deviceId defauleTime:(int)defaultTime {
    NSString *sql = [self dbSqlWithDeviceId:deviceId
                                    paramId:@"level_delay_time"];
    return [self queryIntValueSql:sql defaultTime:defaultTime];
}

+ (int)delayOffTimeWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:@"off_delay_time"];
    return [self queryIntValueSql:sql];
}

+ (int)eletricTimeWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self dbSqlWithDeviceId:deviceId
                                    paramId:@"eletric_time"];
    int time = -1;
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        NSString *paramValue = [set stringForColumn:@"paramValue"];
        time = [paramValue intValue];
    }
    [set close];
    
    if (time == -1) {  // 为-1说明数据库没数据，采用默认值：（默认电流保护点为24A/立即）
        time = 0;
    }
    return time;
}

+ (HMDeviceSettingModel *)abnormalDistObjWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select * from deviceSetting where deviceId = '%@' and paramId = 'power_alarm_mask' and delFlag = 0",deviceId];
    __block HMDeviceSettingModel *model = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        model = [HMDeviceSettingModel object:rs];
    });
    return model;
}

+ (int)abnormalFlagValueWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:@"power_alarm_mask"];
    int value = 0;
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        NSString *paramValue = [set stringForColumn:@"paramValue"];
        value = [paramValue intValue];
    }
    [set close];
    return value;
}



+ (int)eletricValueWithDevice:(HMDevice *)device
{
    NSString *sql = [self dbSqlWithDeviceId:device.deviceId paramId:@"electric_value"];
    
    int value = kDistBoxAttributeDefaultValue;
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        NSString *paramValue = [set stringForColumn:@"paramValue"];
        value = [paramValue intValue];
    }
    [set close];
    
    if (value == kDistBoxAttributeDefaultValue) {
        // 为-1说明数据库没数据，采用默认值：（旧配电箱：默认电流保护点为24A/立即 *****  新配电箱为数据库查到的额定电流值）
        value = device.deviceType == KDeviceTypeNewDistBox ? [HMDistBoxAttributeModel rateCurrentValueWithDeviceId:device.deviceId]*1000 : 24 * 1000;
    }
    return value;
}

+ (BOOL)slowOnSlowOffIsEnableWithDeviceId:(NSString *)deviceId
{
    return [self slowOnSlowOffIsEnableWithDeviceId:deviceId defalutValue:NO];
}

+ (BOOL)slowOnSlowOffIsEnableWithDeviceId:(NSString *)deviceId defalutValue:(BOOL)defaultValue {
    NSString *sql = [self dbSqlWithDeviceId:deviceId
                                    paramId:@"level_delay_enable"];
    return [self queryBooleanValueSql:sql defaultValue:defaultValue];
}


+ (BOOL)isChuangWeiLight:(HMDevice *)device {
    if ([device.model isEqualToString:kChuangWeiOrdinaryLightModel]
        || [device.model isEqualToString:kChuangWeiDimmerLightModel]
        || [device.model isEqualToString:kChuangWeiRGBWModel]
        || [device.model isEqualToString:kChuangWeiColorTempLightModel]
        || [device.model isEqualToString:kChuangWeiRgbModel]) {
        return YES;
    }
    return NO;
}

+ (BOOL)delayOffIsEnableWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self dbSqlWithDeviceId:deviceId
                                    paramId:@"off_delay_enable"];
    return [self queryBooleanValueSql:sql];
}

+ (BOOL)switchIsLockOnAppWithDevice:(HMDevice *)device
{
    NSString *sql = [self dbSqlWithDeviceId:device.deviceId paramId:@"enable_shutdown"];
    
    if (device.deviceType == KDeviceTypeOldDistBox) {
        return [self queryBooleanValueSql:sql];
    }else {
        // 新配电箱：硬件上锁定了也表示锁定
        return [self queryBooleanValueSql:sql] || [self hardWareIsLockWithDeviceId:device.deviceId];
    }
}


+ (BOOL)hardWareIsLockWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:@"hw_onoff_status"];
    return [self queryBooleanValueSql:sql];
}

+ (BOOL)eletricitySaveIsOnWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:@"enable_protect"];
    return [self queryBooleanValueSql:sql];
}


#pragma mark - Help Function

/**
 *  查询布尔值字段值的方法
 *
 *  @param sql 给出sql语句
 *
 *  @return 返回查询结果
 */
+ (BOOL)queryBooleanValueSql:(NSString *)sql
{
    return [self queryBooleanValueSql:sql defaultValue:NO];
}

+ (BOOL)queryBooleanValueSql:(NSString *)sql defaultValue:(BOOL)defaultValue {
    BOOL isEnable = defaultValue;
    
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        NSString *paramValue = [set stringForColumn:@"paramValue"];
        
        if ([paramValue isKindOfClass:[NSString class]]) {
            if ([paramValue isEqualToString:@"True"]) {
                isEnable = YES;
            }else if ([paramValue isEqualToString:@"False"]) {
                isEnable = NO;
            }
        }else {
            if ([paramValue intValue] == 1) {
                 isEnable = YES;
            }else if ([paramValue intValue] == 0){
                 isEnable = NO;
            }
        }
    }
    [set close];
    return isEnable;
}


/// 查询整形字段值的方法
/// @param sql sql
+ (int)queryIntValueSql:(NSString *)sql
{
    return [self queryIntValueSql:sql defaultTime:0];
}

+ (int)queryIntValueSql:(NSString *)sql defaultTime:(int)defaultTime
{
    int time = defaultTime;
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        NSString *paramValue = [set stringForColumn:@"paramValue"];
        time = [paramValue intValue];
    }
    [set close];
    return time;
}

+ (int)queryDistBoxSortNumWithSql:(NSString *)sql {
   
    int sortNum = 10000;  // 默认 10000 没有顺序则排在后面
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        NSString *paramValue = [set stringForColumn:@"paramValue"];
        sortNum = [paramValue intValue];
    }
    [set close];
    return sortNum;
}

+ (NSString *)dbSqlWithDeviceId:(NSString *)deviceId paramId:(NSString *)paramId
{
    NSString *sql = [NSString stringWithFormat:@"select paramValue from deviceSetting where deviceId = '%@' and paramId = '%@' and delFlag = 0",deviceId,paramId];
    return sql;
}

/**
 查询mixpad是否连续对话
 @return 0:不开启连续对话(默认),  1:开启连续对话
 */
+ (int)mixpadContinuousDialogue:(NSString *)deviceId {
    
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:@"continuous_dialogue"];
    int value = 0;
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        NSString *paramValue = [set stringForColumn:@"paramValue"];
        value = [paramValue intValue];
    }
    [set close];
    return value;
    
}

/**
 查询mixpad是否就近唤醒
 @return 0:不开启就近唤醒(默认),  1:开启就近唤醒
 */
+ (int)mixpadNearbyWeakUp:(NSString *)deviceId {
    
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:@"wakeup_nearby"];
    int value = 0;
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        NSString *paramValue = [set stringForColumn:@"paramValue"];
        value = [paramValue intValue];
    }
    [set close];
    return value;
}

+ (int)boardTypeWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:@"panel_type"];
    int value = 0;
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        NSString *paramValue = [set stringForColumn:@"paramValue"];
        value = [paramValue intValue];
        DLog(@"单火开关 deviceId： %@ 有面板类型数据  类型： %d",deviceId,value);
    }
    [set close];
    return value;
}

// MARK: 配电箱是否设置过总闸
+ (BOOL)isHasSetGeneralGateWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:@"general_gate"];
    __block BOOL isHasSet = NO;
    queryDatabase(sql, ^(FMResultSet *rs) {
        isHasSet = YES;
    });
    return isHasSet;
}

// MARK: 某个配电箱下面的端点是否为总闸

+ (BOOL)isGeneralGateWithChildDeviceId:(NSString *)chlDeviceId
{
    NSString *sql = [NSString stringWithFormat:@"select * from deviceSetting where paramId = 'general_gate' and paramValue = '%@' and delFlag = 0 ",chlDeviceId];
    __block BOOL isGeneralGate = NO;
    queryDatabase(sql, ^(FMResultSet *rs) {
        isGeneralGate = YES;
    });
    return isGeneralGate;
}

+ (NSString *)generalGateOfDistBoxDeviceId:(NSString *)deviceId
{
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:@"general_gate"];
    __block NSString *generalGate = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        generalGate = [rs stringForColumn:@"paramValue"];
    });
    return generalGate;
}

+ (NSString *)paramValueOfDeviceId:(NSString *)deviceId paramId:(NSString *)paramId
{
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:paramId];
    __block NSString *paramValue = @"";
    queryDatabase(sql, ^(FMResultSet *rs) {
        paramValue = [rs stringForColumn:@"paramValue"];
    });
    return paramValue;
}

// 获取T1门锁的时间
+ (int)T1timeWithDeviceId:(NSString *)deviceId {
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:@"userUpdateTime"];
    __block int generalGate = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {
        NSString * string = [rs stringForColumn:@"paramValue"];
        if ([string isKindOfClass:[NSString class]]) {
            generalGate = [string intValue];
        }
    });
    return generalGate;
}

/**
 查询mixpad语音控制范围
 */
+ (int)voiceControlRangeForMixPadWithDeviceId:(NSString *)deviceId {
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:@"voice_control_scope"];
    __block int voiceControlRange = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {
        NSString * string = [rs stringForColumn:@"paramValue"];
        if ([string isKindOfClass:[NSString class]]) {
            voiceControlRange = [string intValue];
        }
    });
    return voiceControlRange;
}

/**
 查询mixpad唤醒词
 */
+ (NSString *)wakeupWordForMixPadWithDeviceId:(NSString *)deviceId {
    NSString *sql = [self dbSqlWithDeviceId:deviceId paramId:@"wakeup"];
    __block NSString * word = @"小欧管家/你好小欧";
    if (isZh_Hant()) {
        word = @"小歐管家/你好小歐";
    }
    queryDatabase(sql, ^(FMResultSet *rs) {
        NSString * string = [rs stringForColumn:@"paramValue"];
        if ([string isKindOfClass:[NSString class]] && string.length) {
            word = string;
        }
    });
    return word;
}

//智慧光源
/// 获取缓亮缓灭设置时间
/// @param deviceId
/// @param defaultTime 默认时长
/// @param on yes:缓亮   no:缓灭
+ (int)getWisdomLightSlowOnAndOffTimeWithDeviceId:(NSString *)deviceId defauleTime:(int)defaultTime on:(BOOL)on{
    NSString *sql = [self dbSqlWithDeviceId:deviceId
                            paramId:on?@"brightness_delay_time":@"close_delay_time"];
    return [self queryIntValueSql:sql defaultTime:defaultTime];
}

/// 获取通电默认状态
/// @param deviceId
/// @param defaultTime 默认时长
/// @param on yes:缓亮   no:缓灭
+ (int)getWisdomLightPowerOnDefaultStatusWithDeviceId:(NSString *)deviceId {
    NSString *sql = [self dbSqlWithDeviceId:deviceId
                                    paramId:@"power_on_default_state"];
    
   __block int status = 2;//默认为开；
    queryDatabase(sql, ^(FMResultSet *rs) {
        NSString *paramValue = [rs stringForColumn:@"paramValue"];
        status = [paramValue intValue];
    });
    
    return status;
}

@end
