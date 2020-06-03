//
//  HMSensorEvent.m
//  HomeMate
//
//  Created by orvibo on 16/8/22.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMSensorEvent.h"
#import "HMDevice.h"

@implementation HMSensorEvent

+ (NSString *)tableName
{
    return @"sensorEvent";//传感器数据上报表
}

+ (NSArray*)columns
{
    return @[
             column("sensorEventId","text"),
             column("uid","text"),
             column("deviceId","text"),
             column("powerStatus","integer"),
             column("deviceStatus","integer"),
             column("muteStatus","integer"),
             column("brightness","integer"),
             column("alarmLevel","integer"),
             column("voiceStatus","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (uid, deviceId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+ (instancetype)objectWithDeviceId:(NSString *)deviceId uid:(NSString *)uid
{
    NSString *sql = uid
    ? [NSString stringWithFormat:@"select * from sensorEvent where deviceId = '%@' and uid = '%@'",deviceId,uid]
    : [NSString stringWithFormat:@"select * from sensorEvent where deviceId = '%@'",deviceId];

    FMResultSet * rs = [self executeQuery:sql];

    if([rs next])
    {
        HMSensorEvent *object = [HMSensorEvent object:rs];
//        object.brightness = [self changeHostIntToShowBrightness:object.brightness];
        [rs close];

        return object;
    }
    [rs close];
    
    return nil;
}

+ (instancetype)originObjectWithDeviceId:(NSString *)deviceId uid:(NSString *)uid
{
    NSString *sql = uid
    ? [NSString stringWithFormat:@"select * from sensorEvent where deviceId = '%@' and uid = '%@'",deviceId,uid]
    : [NSString stringWithFormat:@"select * from sensorEvent where deviceId = '%@'",deviceId];

    FMResultSet * rs = [self executeQuery:sql];

    if([rs next])
    {
        HMSensorEvent *object = [HMSensorEvent object:rs];
        [rs close];

        return object;
    }
    [rs close];

    return nil;
}

+ (instancetype)sensorEventWithDictionary:(NSDictionary *)dic {

    HMSensorEvent *sensorEvent = [HMSensorEvent objectFromDictionary:dic];
    if ([sensorEvent.deviceId isEqualToString:@"0"]) {
        HMDevice *device = [HMDevice objectWithUid:sensorEvent.uid];
        if (device) {
            sensorEvent.deviceId = device.deviceId;
        }
    }
    return sensorEvent;
}

+ (BOOL)deleteWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"delete from sensorEvent where deviceId = '%@'",deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (int)changeHostIntToShowBrightness:(int)originBrightness {
    int brightness = 10;
    switch (originBrightness) {
        case 0:
            brightness = 10;
            break;
        case 1:
            brightness = 20;
            break;
        case 2:
            brightness = 30;
            break;
        case 3:
            brightness = 40;
            break;
        case 4:
            brightness = 50;
            break;
        case 6:
            brightness = 60;
            break;
        case 8:
            brightness = 70;
            break;
        case 10:
            brightness = 80;
            break;
        case 12:
            brightness = 90;
            break;
        case 15:
            brightness = 100;
            break;
        default:
            break;
    }
    return brightness;
}



@end
