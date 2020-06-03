//
//  HMStatusRecordModel.m
//  HomeMate
//
//  Created by liuzhicai on 16/6/30.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMStatusRecordModel.h"
#import "HMDevice.h"
#import "HMUserGatewayBind.h"

@implementation HMStatusRecordModel

+(NSString *)tableName
{
    return @"statusRecord";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("messageId","text","PRIMARY KEY ON CONFLICT REPLACE"),
             column("familyId","text"),
             column("userId","text"),
             column("deviceId","text"),
             column("text","text"),
             column("readType","integer"),
             column("time","INTEGER"),
             column("deviceType","integer"),
             column("value1","integer"),
             column("value2","integer"),
             column("value3","integer"),
             column("value4","integer"),
             column("sequence","integer"),
             column("isPush","integer"),
             column("updateTimeSec","TEXT"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer"),
             column("type","integer"),
             column("classifiedSequence","integer"),
             ];
}

/**不改版本号的情况下，新增的一个column*/
+ (NSArray<NSDictionary *>*)newColumns {
    return  @[column("type","integer default 0"),column("classifiedSequence","integer")];
}


- (void)prepareStatement
{
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+ (BOOL)deleteStatusRecordWithDeviceId:(NSString *)deviceId
{
    int maxSequence = [self getMaxSequenceNumWithDeviceId:deviceId];
    NSString *sql = [NSString stringWithFormat:@"delete from statusRecord where deviceId = '%@' and sequence != %d",deviceId,maxSequence];
    BOOL result1 = [self executeUpdate:sql];
    sql = [NSString stringWithFormat:@"update statusRecord set delFlag = 1 where deviceId = '%@'",deviceId];
    BOOL result2 = [self executeUpdate:sql];
    return result1 && result2;
}



+ (NSString *)sqlStrWithSequence:(int)sequence deviceId:(NSString *)deviceId
{
     NSString *sql = [NSString stringWithFormat:@"select * from statusRecord where deviceId = '%@' and sequence <= %d and delFlag = 0 order by sequence desc limit 0, 20",deviceId,sequence];
    return sql;
}

// 获取小于某个序号的最大中断序号（20条以内），如果中断则去服务器请求
+ (int)getInterruptSequenceAfterSomeSequence:(int)sequence withDeviceId:(NSString *)deviceId
{
    int tempSequence = sequence;
    int currSequence = 0;
    int interruptSequence = -1; // 中断序号
    NSString *sql = [self sqlStrWithSequence:sequence deviceId:deviceId];
    FMResultSet *set = [self executeQuery:sql];
    while ([set next]) {
        currSequence = [set intForColumn:@"sequence"];
        if(tempSequence - currSequence != 1) {
            interruptSequence = tempSequence;
            break;
        }
        tempSequence = currSequence;
    }
    [set close];
    return interruptSequence;
}

+ (BOOL)isHasInterruptStatusRecordAfterSomeSequence:(int)sequence withDeviceId:(NSString *)deviceId
{
    int tempSequence = sequence;
    int currSequence = 0;
    BOOL isHas = NO;
    NSString *sql = [self sqlStrWithSequence:sequence deviceId:deviceId];
    
    FMResultSet *set = [self executeQuery:sql];
    while ([set next]) {
        currSequence = [set intForColumn:@"sequence"];
        if(tempSequence - currSequence != 1) {
            isHas = YES;
            break;
        }
        tempSequence = currSequence;
    }
    [set close];
    return isHas;
}

// 获取小于某序号的连续数据，（每次查20条）
+ (NSMutableArray *)continuousRecordAfterSomeSequence:(int)sequence withDeviceId:(NSString *)deviceId
{
    NSMutableArray *recordsArr = [NSMutableArray array];
    int tempSequence = sequence;
    int currSequence = 0;

    NSString *sql = [self sqlStrWithSequence:sequence deviceId:deviceId];
    
    FMResultSet *set = [self executeQuery:sql];
    
    while ([set next]) {
        currSequence = [set intForColumn:@"sequence"];
        if((tempSequence - currSequence != 1) && (tempSequence != sequence)) {
            break;
        }
        
        HMStatusRecordModel *srModel = [HMStatusRecordModel object:set];
        [recordsArr addObject:srModel];
        tempSequence = currSequence;
    }
    
    [set close];

    
    return recordsArr;
}

// 获取数据库中最新的20条数据，根据序号递减顺序返回
+ (NSMutableArray *)getNewestTwentyDataFromDbWithDeviceId:(NSString *)deviceId
{
    int maxSequence = [self getMaxSequenceNumWithDeviceId:deviceId];
    return [self continuousRecordAfterSomeSequence:maxSequence withDeviceId:deviceId];
}

+ (NSMutableArray *)getRecordDataBetweenMinSequence:(int)minSequence maxSequence:(int)maxSequence deviceId:(NSString *)deviceId
{
    NSMutableArray *recordsArr = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from statusRecord where deviceId = '%@' and sequence >= %d and sequence < %d and delFlag = 0 order by sequence desc",deviceId,minSequence,maxSequence];
    FMResultSet *set = [self executeQuery:sql];
    while ([set next]) {
        
        HMStatusRecordModel *srModel = [HMStatusRecordModel object:set];
        [recordsArr addObject:srModel];break;
    }
    [set close];
    return recordsArr;
}

+ (int)getMaxSequenceNumWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select max(sequence) as maxSequence from statusRecord where deviceId = '%@'",deviceId];
    //    FMResultSet *set = [self executeQuery:sql];
    __block int maxSequenceNum = 0;
    
    queryDatabase(sql,^(FMResultSet *rs){
        
        maxSequenceNum = [rs intForColumn:@"maxSequence"];
        
    });
    
    
    return maxSequenceNum;
}


+ (HMStatusRecordModel *)latestRecordWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select * from statusRecord where updateTime in (select max(updateTime) from statusRecord where deviceId = '%@') and deviceId = '%@'",deviceId,deviceId];
    FMResultSet *set = [self executeQuery:sql];
    HMStatusRecordModel *model = nil;
    while ([set next]) {
        model = [HMStatusRecordModel object:set];break;
    }
    [set close];
    return model;
}

+ (HMStatusRecordModel *)latestLockRecordWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select * from messageLast where updateTime in (select max(updateTime) from messageLast where deviceId = '%@' and value4>=0 and value3 != 0) and deviceId = '%@'",deviceId,deviceId];
    FMResultSet *set = [self executeQuery:sql];
    HMStatusRecordModel *model = nil;
    while ([set next]) {
        model = [HMStatusRecordModel object:set];break;
    }
    [set close];
    return model;
}

- (NSString *)stringDateTime
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSMutableString *mutaStr = [NSMutableString stringWithString:dateString];
    [mutaStr insertString:@"-" atIndex:4];
    [mutaStr insertString:@"-" atIndex:7];
    
    [mutaStr insertString:@" " atIndex:10];
    
    [mutaStr insertString:@":" atIndex:13];
    [mutaStr insertString:@":" atIndex:16];

    _stringDateTime = mutaStr;

    return _stringDateTime;
    
    
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.time];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
//    NSString *dateString = [dateFormatter stringFromDate:date];
//    _stringDateTime = dateString;
//    return _stringDateTime;
}

//- (void)setTime:(int)time
//{
//    _time = time;
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
//    NSString *dateString = [dateFormatter stringFromDate:date];
//    self.stringDateTime = dateString;
//}


+(NSMutableArray *)selectDataByUserIdLimitCount:(NSInteger )count AndDeviceId:(NSString *)deviceId recordType:(StatusRecordType)recordType{
    NSMutableArray *arr = [NSMutableArray new];
    HMDevice *device = [HMDevice objectWithDeviceId:deviceId uid:nil];
    NSString *sql = nil;
    if (device.deviceType == KDeviceTypeOrviboLock) {
        
        NSString * createTime = device.createTime;
        if (device.isC1Lock) {
            createTime = [HMUserGatewayBind bindWithUid:device.uid].createTime;
        }
        
        sql = [NSString stringWithFormat:@"select * from statusRecord where deviceId = '%@' and delFlag = 0 and createTime > '%@' and type = %d order by time desc limit %d",deviceId ,createTime ,(int)recordType,(int)count];
        if (recordType == StatusRecordTypeAll) {
            sql = [NSString stringWithFormat:@"select * from statusRecord where deviceId = '%@' and delFlag = 0 and createTime > '%@' order by time desc limit %d",deviceId ,createTime ,(int)count];
        }
    }else {
        sql = [NSString stringWithFormat:@"select * from statusRecord where deviceId = '%@' and delFlag = 0 and type = %d order by time desc limit %d",deviceId, (int)recordType,(int)count];
        
        if (recordType == StatusRecordTypeAll) {
           sql = [NSString stringWithFormat:@"select * from statusRecord where deviceId = '%@' and delFlag = 0  order by time desc limit %d",deviceId,(int)count];
        }
    }
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMStatusRecordModel *model = [HMStatusRecordModel object:rs];
        [arr addObject:model];
    });
    return arr;
}


+(NSMutableArray *)selectT1AlarmRecordDevice:(HMDevice *)device lastTime:(NSString *)lastTime{
    NSMutableArray *arr = [NSMutableArray new];
    NSString * createTime = device.createTime;
    if (device.isC1Lock) {
        createTime = [HMUserGatewayBind bindWithUid:device.uid].createTime;
    }
    NSString * sql = [NSString stringWithFormat:@"select * from statusRecord where deviceId = '%@' and delFlag = 0 and createTime > '%@' and updateTime > '%@' and type = %d and messageId NOT IN (select recordId from ignoreAlertRecord where deviceId = '%@' and familyId = '%@') order by createTime desc",device.deviceId ,createTime,lastTime,(int)StatusRecordTypeAlarm,device.deviceId,userAccout().familyId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMStatusRecordModel *model = [HMStatusRecordModel object:rs];
        [arr addObject:model];
    });
    return arr;
}

+ (BOOL)deleteWithDeviceId:(NSString *)deviceId
{
    NSString * sql = [NSString stringWithFormat:@"delete from statusRecord where deviceId = '%@' ",deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (NSInteger )getLastDeleteSequence:(HMDevice *)device recordType:(StatusRecordType)recordType{
    __block NSInteger sequence = -1;
    
    if (device.deviceType == KDeviceTypeOrviboLock
        ||device.deviceType == KDeviceTypeLockH1) {
        
        NSString * createTime = device.createTime;
        if (device.isC1Lock) {
            createTime = [HMUserGatewayBind bindWithUid:device.uid].createTime;
        }
        
        NSString * sql1 = [NSString stringWithFormat:@"select min(sequence) as minSequence from statusRecord where deviceId = '%@' and delFlag = 0 and createTime > '%@'",device.deviceId, createTime];
        queryDatabase(sql1, ^(FMResultSet *rs) {
            sequence = [rs intForColumn:@"minSequence"];
        });
    }
    
    NSString * sql2 = [NSString stringWithFormat:@"select * from statusRecord where deviceId = '%@' and type = %d and delFlag = 1",device.deviceId,(int)recordType];

    if (recordType == StatusRecordTypeAll) {
        sql2 = [NSString stringWithFormat:@"select * from statusRecord where deviceId = '%@' and delFlag = 1",device.deviceId];
    }
    queryDatabase(sql2, ^(FMResultSet *rs) {
        sequence = [rs intForColumn:@"sequence"];
        if (recordType != StatusRecordTypeAll) {
            sequence = [rs intForColumn:@"classifiedSequence"];
        }
    });
    
    
    return sequence;
}

/******  门锁开关记录新逻辑   *****/


+ (NSArray *)twentyRecordFromPagingLimitIndex:(int)index deviceId:(NSString *)deviceId {
    NSString *familyId = userAccout().familyId;
    NSString *userId = userAccout().userId;
    NSString * sql = [NSString stringWithFormat:@"select * from statusRecord where familyId = '%@' and userId = '%@' and deviceId = '%@' and delFlag = 0 order by sequence desc limit %ld, 20",familyId,userId,deviceId,(long)index];
    
    __block NSMutableArray *records = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!records) {
            records = [NSMutableArray array];
        }
        HMStatusRecordModel *msg = [HMStatusRecordModel object:rs];
        [records addObject:msg];
    });
    return records;
}

+ (NSInteger)maxRecordUpdateTimeForDevice:(HMDevice *)device {

    NSInteger lastUpdatime = 0;

    NSString *sql = [NSString stringWithFormat:@"select max(updateTime) as MaxUpdateTime  from statusRecord where familyId = '%@' and userId = '%@' and deviceId = '%@' and delFlag = 0",userAccout().familyId,userAccout().userId,device.deviceId];
    FMResultSet *set = [[HMDatabaseManager shareDatabase] executeQuery:sql];
    if ([set next]) {
        NSString *dateStr = [set stringForColumn:@"MaxUpdateTime"];
        if (dateStr
            && (![dateStr isEqualToString:@""])
            && (![dateStr isEqualToString:@"null"])) {
            
            lastUpdatime = secondWithString(dateStr);
            DLog(@"获取蓝牙最大更新时间：%@",dateStr);
        }
    }
    [set close];
    return lastUpdatime;

}

+ (NSArray *)lastestTwentyRecordFromDbWithDeviceId:(NSString *)deviceId
{
    return [self twentyRecordFromPagingLimitIndex:0 deviceId:deviceId];
}



@end
