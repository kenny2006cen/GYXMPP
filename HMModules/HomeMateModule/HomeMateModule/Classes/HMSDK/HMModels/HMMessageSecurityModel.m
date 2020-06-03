//
//  HMMessageSecurityModel.m
//  HomeMateSDK
//
//  Created by user on 16/10/11.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMMessageSecurityModel.h"
#import "HMBaseModel+Extension.h"
#import "HMConstant.h"

@implementation HMMessageSecurityModel

+(NSString *)tableName
{
    return @"messageSecurity";
}

+ (NSArray*)columns
{
    return @[
             column("messageSecurityId","text"),
             column("familyId","text"),
             column("userId","text"),
             column("deviceId","text"),
             column("text","text"),
             column("params","text"),
             column("readType","integer"),
             column("time","integer"),
             column("deviceType","integer"),
             column("value1","integer"),
             column("value2","integer"),
             column("value3","integer"),
             column("value4","integer"),
             column("sequence","integer"),
             column("isPush","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (messageSecurityId) ON CONFLICT REPLACE";
}

- (void)prepareStatement
{
    if (!self.userId) {
        self.userId = @"unknowUserId";
    }
    
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from messageSecurity where messageSecurityId = '%@'",self.messageSecurityId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+(NSMutableArray *)selectDataByUserIdLimitCount:(NSInteger)count{
    NSMutableArray *arr = [NSMutableArray new];
    NSString * sql = [NSString stringWithFormat:@"select * from messageSecurity where familyId = '%@' and userId = '%@' and delFlag = 0 order by createTime desc limit %ld",userAccout().familyId, userAccout().userId, (long)count];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMMessageSecurityModel *model = [HMMessageSecurityModel object:rs];
    
        [arr addObject:model];
    });
    return arr;
}

+ (int)getMaxSequenceNumWithFamilyld:(NSString *)familyld
{
    NSString *sql = [NSString stringWithFormat:@"select max(sequence) as maxSequence from messageSecurity where familyId = '%@'",familyld];
    __block int maxSequenceNum = -1;
    
    queryDatabase(sql,^(FMResultSet *rs){
        
        maxSequenceNum = [rs intForColumn:@"maxSequence"];
    });
    
    return maxSequenceNum;
}


+ (int)getMaxSequenceNum
{
   return  [self getMaxSequenceNumWithFamilyld:userAccout().familyId];
}


+ (int)getSequenceNumWhoWithDelFlag
{
    NSString *sql = [NSString stringWithFormat:@"select sequence from messageSecurity where familyId = '%@' and userId = '%@' and delFlag = 1",userAccout().familyId, userAccout().userId];
    __block int sequence = -1;
    
    queryDatabase(sql,^(FMResultSet *rs){
        
        sequence = [rs intForColumn:@"sequence"];
    });
    
    return sequence;
}


+ (BOOL)isHasUnreadData;
{
    NSString *sql = [NSString stringWithFormat:@"select count() as count from messageSecurity where readType = 0 and userId = '%@' and familyId = '%@' and delFlag = 0", userAccout().userId, userAccout().familyId];
    __block NSInteger count = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {
        count = [[rs objectForColumn:@"count"] integerValue];
    });
    if (count > 0) {
        return YES;
    }else {
        return NO;
    }
}

+ (BOOL)hasUreadDataWithFamilyId:(NSString *)familyId{
    NSString *sql = [NSString stringWithFormat:@"select count() as count from messageSecurity where readType = 0 and userId = '%@' and familyId = '%@' and delFlag = 0", userAccout().userId, familyId];
    __block NSInteger count = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {
        count = [[rs objectForColumn:@"count"] integerValue];
    });
    if (count > 0) {
        return YES;
    }else {
        return NO;
    }

}

+ (void)updateMessageSecuritySetReadType1
{
    NSString *sql = [NSString stringWithFormat:@"update messageSecurity set readType = 1 where userId = '%@' and familyId = '%@'",userAccout().userId, userAccout().familyId];
    [self executeUpdate:sql];
}


+(int )selectAllDataCount{
    __block int count = 0;
    NSString * sql = [NSString stringWithFormat:@"select count() as count from messageSecurity where userId = '%@' and familyId = '%@' and delFlag = 0 " ,userAccout().userId, userAccout().familyId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        count = [rs intForColumn:@"count"];
        
    });
    return count;
}

+ (BOOL)clearSecurityRecord {
    int maxSequence = [self getMaxSequenceNumWithFamilyld:userAccout().familyId];
    NSString *sql = [NSString stringWithFormat:@"delete from messageSecurity where familyId = '%@' and sequence != %d",userAccout().familyId ,maxSequence];
    BOOL result1 = [self executeUpdate:sql];
    sql = [NSString stringWithFormat:@"update messageSecurity set delFlag = 1 where familyId = '%@'",userAccout().familyId];
    BOOL result2 = [self executeUpdate:sql];
    return result1 && result2;
}

@end
