//
//  DoorLockRecordModel.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "HMDoorLockRecordModel.h"
#import "HMDevice.h"
#import "HMDatabaseManager.h"


@implementation HMDoorLockRecordModel

+(NSString *)tableName
{
    return @"doorLockRecord";
}

+ (NSArray*)columns
{
    return @[column("doorLockRecordId","text"),
             column("uid","text"),
             column("deviceId","text"),
             column("name","text"),
             column("authorizedId","integer"),
             column("type","integer"),
             column("time","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (doorLockRecordId, uid) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from doorLockRecord where doorLockRecordId = '%@'",self.doorLockRecordId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+(NSMutableArray *)selectObjectWith:(NSString *)deviceID andLastMinTime:(int)time{
    HMDevice *device = [HMDevice objectWithDeviceId:deviceID uid:nil];

    NSMutableArray *arr = [NSMutableArray new];
    NSString *sql;
    if (time > 0) {
        sql = [NSString stringWithFormat:@"select * from doorLockRecord where uid = '%@' and deviceId = '%@' and delFlag = 0 and time < %d order by time desc limit 20", device.uid, deviceID, time];
    }else {
        sql = [NSString stringWithFormat:@"select * from doorLockRecord where uid = '%@' and deviceId = '%@' and delFlag = 0 order by time desc limit 20",device.uid,deviceID];
    }
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMDoorLockRecordModel *record = [HMDoorLockRecordModel object:rs];
        [arr addObject:record];
    });
  

    return arr;
}

+(HMDoorLockRecordModel *)selectLastObjectWith:(NSString *)deviceID withAuthorizedId:(int )authorizedId {
    __block HMDoorLockRecordModel *record = nil;
    HMDevice *device = [HMDevice objectWithDeviceId:deviceID uid:nil];

    if (!authorizedId) {
        NSString *sql = [NSString stringWithFormat:@"select * from doorLockRecord where uid = '%@' and deviceId = '%@' and delFlag = 0 order by createTime desc limit 1",device.uid,deviceID];
        queryDatabase(sql, ^(FMResultSet *rs) {
            
            record = [HMDoorLockRecordModel object:rs];
        });
    }else{
        NSString *sql = [NSString stringWithFormat:@"select * from doorLockRecord where uid = '%@' and deviceId = '%@' and type = 4 and authorizedId =  %d and delFlag = 0 order by createTime desc limit 1",device.uid,deviceID,authorizedId];
        queryDatabase(sql, ^(FMResultSet *rs) {
            
            record = [HMDoorLockRecordModel object:rs];
        });
    }
    
    return record;
}

+(BOOL )deleteRecordWithDeviceId:(NSString *)deviceID{
    NSString * sql = [NSString stringWithFormat:@"delete from doorLockRecord where deviceId = '%@'",deviceID];
    BOOL result = [self executeUpdate:sql];
    return result;
}


@end
