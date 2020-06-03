//
//  HMKKDevice.m
//  HomeMate
//
//  Created by orvibo on 16/4/11.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMKKDevice.h"
#import "HMKKIr.h"
#import "HMDatabaseManager.h"


@implementation HMKKDevice

+ (NSString *)tableName
{
    return @"kkDevice";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("kkDeviceId","text","primary key asc on conflict replace"),
             column("uid","text"),
             column("deviceId","text"),
             column("rid","integer"),
             column("freq","integer"),
             column("type","integer"),
             column("exts","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","Integer")
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


-(id)copyWithZone:(NSZone *)zone
{
    HMKKDevice *kkdevice = [[HMKKDevice alloc] init];
    kkdevice.kkDeviceId = self.kkDeviceId;
    kkdevice.rid = self.rid;
    kkdevice.freq = self.freq;
    kkdevice.type = self.type;
    kkdevice.exts = self.exts;
    kkdevice.createTime = self.createTime;
    kkdevice.updateTime = self.updateTime;
    kkdevice.delFlag = self.delFlag;
    kkdevice.deviceId = self.deviceId;
    return kkdevice;
}

+ (instancetype)objectWithRid:(int)rid deviceId:(NSString *)deviceId
{
    __block HMKKDevice *kkDevice;
    NSString *sql = [NSString stringWithFormat:@"select * from kkDevice where rid = %d and delFlag = 0 and deviceId = '%@'",rid, deviceId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        kkDevice = [[HMKKDevice object:rs] copy];
    });
    return kkDevice;
}

+ (BOOL)deleteWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"delete from kkDevice where deviceId = '%@'",deviceId];
    BOOL result = [self executeUpdate:sql];
    result = [HMKKIr deleteWithDeviceId:deviceId];
    return result;
}

@end
