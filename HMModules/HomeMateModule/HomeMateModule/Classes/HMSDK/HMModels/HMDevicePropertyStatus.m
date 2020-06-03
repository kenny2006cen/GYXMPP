//
//  HMDevicePropertyStatus.m
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/10/10.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMDevicePropertyStatus.h"
#import "HMBaseModel+Extension.h"
#import "HMDatabaseManager.h"


@implementation HMDevicePropertyStatus

+(NSString *)tableName
{
    return @"devicePropertyStatus";
}

+ (NSArray*)columns
{
    return @[
             column("devicePropertyStatusId", "text"),
             column("uid", "text"),
             column("deviceId", "text"),
             column("property", "text"),
             column("value", "text"),
             column("updateTime", "text"),
             column("createTime", "text"),
             column("delFlag", "integer"),
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (uid,deviceId,property) ON CONFLICT REPLACE";
}

- (void)prepareStatement
{
    if (!self.devicePropertyStatusId) {
        self.devicePropertyStatusId = @"";
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}
- (BOOL)deleteObject {
    
    NSString * sql = [NSString stringWithFormat:@"delete from devicePropertyStatus where uid = '%@' ",self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (NSString *)valueOfProperty:(NSString *)property uid:(NSString *)uid {
    NSString *sql = [NSString stringWithFormat:@"select value from devicePropertyStatus where uid = '%@' and property = '%@' and delFlag = 0 order by updateTime desc",uid,property];
    __block NSString *value = @"";
    FMResultSet *set = executeQuery(sql);
    if ([set next]) {
        value = [set stringForColumn:@"value"];
    }
    [set close];
    return value;
}

+ (NSString *)valueOfProperty:(NSString *)property uid:(NSString *)uid deviceId:(NSString *)deviceId{
    NSString *sql = [NSString stringWithFormat:@"select value from devicePropertyStatus where uid = '%@' and deviceId = '%@' and property = '%@' and delFlag = 0 order by updateTime desc",uid,deviceId,property];
    __block NSString *value = @"";
    FMResultSet *set = executeQuery(sql);
    if ([set next]) {
        value = [set stringForColumn:@"value"];
    }
    [set close];
    return value;
}
    
+ (void)deletePropertyOfUid:(NSString *)uid deviceId:(NSString *)deviceId{
    NSString *sql = [NSString stringWithFormat:@"delete from devicePropertyStatus where uid = '%@' and deviceId = '%@'",uid,deviceId];
    updateInsertDatabase(sql);
}


@end
