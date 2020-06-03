//
//  HMSensorData.m
//  HomeMate
//
//  Created by JQ on 16/8/11.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMSensorData.h"
#import "HMConstant.h"

@implementation HMSensorData

+ (NSString *)tableName
{
    return @"sensorDataLast";//传感器数据上报表
}


+ (NSArray*)columns
{
    return @[
              column("sensorDataLastId","text"),
              column("familyId","text"),
              column("uid","text"),
              column("deviceId","text"),
              column("timestamp","integer"),
              column("batteryValue","integer"),
              column("coConcentration","integer"),
              column("hchoConcentration","integer"),
              column("temperature","integer"),
              column("humidity","integer"),
              column("alarmStatus","integer"),
              column("pm25","integer"),
              column("createTime","text"),
              column("updateTime","text"),
              column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (uid, deviceId) ON CONFLICT REPLACE";
}

+ (NSArray<NSDictionary *>*)newColumns {
    return  @[column("pm25","integer")];
}

- (void)prepareStatement
{
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
    if (!self.updateTime) { // 接收的数据中没有updateTime数据，就把手机当前时间作为updateTime
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSString *timeString = [formatter stringFromDate:[NSDate date]];
        self.updateTime = timeString;
    }
 }

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+ (instancetype)sensorDataWithDictionary:(NSDictionary *)dic
{
    HMSensorData *sensorData = [HMSensorData objectFromDictionary:dic];
    if (!sensorData.deviceId || [sensorData.deviceId isEqualToString:@"0"]) {
        HMDevice *device = [HMDevice objectWithUid:sensorData.uid];
        if (device) {
            sensorData.deviceId = device.deviceId;
        }
    }
    if (!sensorData.updateTime && sensorData.timestamp) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:sensorData.timestamp];
        NSString *timeString = [formatter stringFromDate:date];
        sensorData.updateTime = timeString;
    }
    return sensorData;
}


- (void)setHchoConcentration:(int)hchoConcentration
{
    _hchoConcentration = hchoConcentration;
    _hchoConcentrationStr = [NSString stringWithFormat:@"%.2f",self.hchoConcentration/100.0];
    if ([_hchoConcentrationStr isEqualToString:@"-0"]) {
        _hchoConcentrationStr = @"0";
    }
}

- (void)setTemperature:(int)temperature
{
    _temperature = temperature;
    float f = self.temperature/10.0;
    int r = round(f);
    _temperatureStr = [NSString stringWithFormat:@"%d",r];
    if ([_temperatureStr isEqualToString:@"-0"]) {
        _temperatureStr = @"0";
    }
}

+ (instancetype)objectWithDeviceId:(NSString *)deviceId uid:(NSString *)uid
{
    NSString *sql = uid
    ? [NSString stringWithFormat:@"select * from sensorDataLast where deviceId = '%@' and uid = '%@'",deviceId,uid]
    : [NSString stringWithFormat:@"select * from sensorDataLast where deviceId = '%@'",deviceId];

    FMResultSet * rs = [self executeQuery:sql];

    if([rs next])
    {
        HMSensorData *object = [HMSensorData object:rs];

        [rs close];

        return object;
    }
    [rs close];

    return nil;
}

+ (BOOL)deleteWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"delete from sensorDataLast where deviceId = '%@'",deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}


+ (NSString *)temperatureAndHumidityStringWithSensorData:(HMSensorData *)sensorData
{
    if (!sensorData) {
        return @"";
    }
    NSString *string = [NSString stringWithFormat:@"%@℃ %d%%",sensorData.temperatureStr,sensorData.humidity];
    return string;
}

- (BOOL)isOccurred
{
    if (self.alarmStatus > 0) {
        return YES;
    }else {
        return NO;
    }
}
@end




















