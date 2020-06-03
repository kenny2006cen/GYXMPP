//
//  HMCustomChannel.m
//  HomeMateSDK
//
//  Created by liqiang on 2018/6/7.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMCustomChannel.h"
#import "HMConstant.h"
#import "HMDevice.h"

@implementation HMCustomChannel
+(NSString *)tableName
{
    return @"customChannel";
}

+ (NSArray*)columns
{
    return @[
             column("customChannelId", "text"),
             column("deviceId", "text"),
             column("stbChannelId", "text"),
             column("channel", "integer"),
             column("channelName", "text"),
             column("sequence", "integer"),
             ];
}


+ (NSString*)constrains
{
    return @"UNIQUE (customChannelId) ON CONFLICT REPLACE";
}

- (void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}
- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from customChannel where customChannelId = '%@' ",self.customChannelId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (NSMutableArray *)customChannelWithDevice:(HMDevice *)device {
    NSMutableArray * array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from customChannel where deviceId = '%@' and customChannelId is not NULL and stbChannelId = '' order by channel",device.deviceId];
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        [array addObject:[HMCustomChannel object:rs]];
    }
    [rs close];
    return array;
}
+ (NSMutableArray *)allChannelWithDevice:(HMDevice *)device {
    NSMutableArray * array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from customChannel where deviceId = '%@' order by channel",device.deviceId];
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        [array addObject:[HMCustomChannel object:rs]];
    }
    [rs close];
    return array;
}
+ (BOOL)deleteCustomChannelWithDevice:(HMDevice *)device {
    NSString * sql = [NSString stringWithFormat:@"delete from customChannel where customChannelId is not NULL and deviceId = '%@'",device.deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}
+ (BOOL)deletePublicObjectWithDevice:(HMDevice *)device {
    NSString * sql = [NSString stringWithFormat:@"delete from customChannel where customChannelId is NULL and deviceId = '%@'",device.deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}
+ (BOOL)deleteAllObjectWithDevice:(HMDevice *)device {
    NSString * sql = [NSString stringWithFormat:@"delete from customChannel where deviceId = '%@' ",device.deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}
@end
