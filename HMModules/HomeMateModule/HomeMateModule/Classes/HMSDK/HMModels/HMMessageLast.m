//
//  HMMessageLast.m
//  HomeMate
//
//  Created by liuzhicai on 16/9/26.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMMessageLast.h"
#import "HMConstant.h"

@implementation HMMessageLast


+(NSString *)tableName
{
    return @"messageLast";
}

+ (NSArray*)columns
{
    return @[
             column("messageLastId","text"),
             column("familyId","text"),
             column("userId","text"),
             column("deviceId","text"),
             column("text","text"),
             column("readType","INTEGER"),
             column("time","INTEGER"),
             column("deviceType","INTEGER"),
             column("value1","INTEGER"),
             column("value2","INTEGER"),
             column("value3","INTEGER"),
             column("value4","INTEGER"),
             column("sequence","INTEGER"),
             column("isPush","INTEGER"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (familyId,deviceId) ON CONFLICT REPLACE";
}

- (void)prepareStatement
{
    if (!self.userId) {
        self.userId = userAccout().userId;
    }
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
    
    // cmd = 82 推过来的时候，插入数据库没有updatetime跟createTime
    if (!self.updateTime) {
        NSString *secondStr = [NSString stringWithFormat:@"%d",self.time];
        NSString *dateStr = dateStringWithSec(secondStr);
        self.updateTime = dateStr;
        self.createTime = dateStr;
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+ (instancetype)objectWithDeviceId:(NSString *)deviceId
{
    __block HMMessageLast *messageLast = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from messageLast where deviceId = '%@' and userId = '%@' and familyId = '%@' and delFlag = 0",deviceId, userAccout().userId,userAccout().familyId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        messageLast = [HMMessageLast object:rs];
    });
    return messageLast;
}

+ (NSInteger)dataNum
{
    NSString *userId = userAccout().userId;
    __block NSInteger count = 0;
    NSString *sql = [NSString stringWithFormat:@"select count() as count from messageLast where userId = '%@' and familyId = '%@'",userId,userAccout().familyId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        count = [rs intForColumn:@"count"];
    });
    return count;
}

+ (instancetype)latestObjWithDeviceTypeString:(NSString *)deviceTypeString roomId:(NSString *)roomId
{
    __block HMMessageLast *messageLast = nil;
    NSString *deviceIdCondition = @"";
    if (roomId && roomId.length > 0) {
        deviceIdCondition = [NSString stringWithFormat:@"and deviceId in (select deviceId from device where roomId = '%@' and delFlag = 0 and uid in %@)",roomId, [HMUserGatewayBind uidStatement]];
    }else {
        deviceIdCondition = [NSString stringWithFormat:@"and deviceId in (select deviceId from device where delFlag = 0 and uid in %@)",[HMUserGatewayBind uidStatement]];
    }
    NSString *condition = [NSString stringWithFormat:@"userId = '%@' and familyId = '%@' and deviceType in (%@) and delFlag = 0 %@",userAccout().userId,userAccout().familyId,deviceTypeString, deviceIdCondition];
    NSString *sql = [NSString stringWithFormat:@"select * from messageLast where %@ and time = (select max(time) from messageLast where %@)",condition,condition];
    queryDatabase(sql, ^(FMResultSet *rs) {
        messageLast = [HMMessageLast object:rs];
    });
    return messageLast;
}

@end




