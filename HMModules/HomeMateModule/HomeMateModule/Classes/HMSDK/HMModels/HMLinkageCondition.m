//
//  VihmeLinkageCondition.m
//  HomeMate
//
//  Created by Air on 15/8/17.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMLinkageCondition.h"
#import "HMConstant.h"

@implementation HMLinkageCondition

+(NSString *)tableName
{
    return @"linkageCondition";
}

+ (NSArray*)columns
{
    return @[
             column("linkageConditionId","text"),
             column("uid","text"),
             column("linkageId","text"),
             column("linkageType","integer"),
             column("condition","integer"),
             column("deviceId","text"),
             column("statusType","integer"),
             column("keyAction","integer"),
             column("keyNo","integer"),
             column("authorizedId","text"),
             column("value","integer"),
             column("priorityLevel","integer"),
             column("conditionRelation","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","Integer")
             ];
}

/**不改版本号的情况下，新增的一个column*/
+ (NSArray<NSDictionary *>*)newColumns {
    return @[column("priorityLevel","integer"),
             column("conditionRelation","text"),];
}

+ (NSString*)constrains
{
    return @"UNIQUE (linkageConditionId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = self.uid ? [NSString stringWithFormat:@"delete from linkageCondition where linkageConditionId = '%@' and uid = '%@'",self.linkageConditionId,self.uid]
                              : [NSString stringWithFormat:@"delete from linkageCondition where linkageConditionId = '%@'",self.linkageConditionId];

    BOOL result = [self executeUpdate:sql];
    return result;
}

- (id)copyWithZone:(NSZone *)zone
{
    HMLinkageCondition *copySelf = [[HMLinkageCondition alloc]init];
    copySelf.linkageConditionId = self.linkageConditionId;
    copySelf.uid = self.uid;
    copySelf.linkageId = self.linkageId;
    copySelf.linkageType = self.linkageType;
    copySelf.condition = self.condition;
    copySelf.deviceId = self.deviceId;
    copySelf.statusType = self.statusType;
    copySelf.value = self.value;
    copySelf.authorizedId = self.authorizedId;
    copySelf.keyAction = self.keyAction;
    copySelf.keyNo = self.keyNo;
    
    return copySelf;
}
- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    return dic;
}

+(NSMutableArray *)linkageConditionExcepCycletWithlinkageId:(NSString *)linkageId
{
    NSMutableArray * conditionArray = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from linkageCondition where linkageId = '%@'  and linkageType in (0,3,4,5,6,10) and delFlag = 0 order by conditionRelation desc, createTime asc",linkageId];
    FMResultSet *resultSet = [self executeQuery:sql];
    HMLinkageCondition *linkageCondition;
    while ([resultSet next]) {
        linkageCondition = [HMLinkageCondition object:resultSet];
        [conditionArray addObject:linkageCondition];
    }
    [resultSet close];
    return conditionArray;
}

+(NSMutableArray *)linkageConditionlinkageId:(NSString *)linkageId
{
    NSMutableArray * conditionArray = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from linkageCondition where linkageId = '%@'  and delFlag = 0 order by createTime asc",linkageId];
    FMResultSet *resultSet = [self executeQuery:sql];
    HMLinkageCondition *linkageCondition;
    while ([resultSet next]) {
        linkageCondition = [HMLinkageCondition object:resultSet];
        [conditionArray addObject:linkageCondition];
    }
    [resultSet close];
    return conditionArray;
}

+(HMLinkageCondition *)getLightLinkageConditonWithlinkageId:(NSString *)linkageId
{
    NSString *sql = [NSString stringWithFormat:@"select * from linkageCondition where linkageId = '%@' and uid in %@ and linkageType = 0 and condition in (3, 4) and delFlag = 0",linkageId,[HMUserGatewayBind uidStatement]];
    FMResultSet *resultSet = [self executeQuery:sql];
    HMLinkageCondition *linkageCondition;
    if ([resultSet next]) {
        linkageCondition = [HMLinkageCondition object:resultSet];
    }
    [resultSet close];
    return linkageCondition;
}

+ (BOOL)isLightSensorLinkageWithLinkageId:(NSString *)linkageId {
    NSString *sql = [NSString stringWithFormat:@"select deviceId from linkageCondition where linkageId = '%@' and linkageType = 0 and delFlag = 0", linkageId];
    __block NSInteger count = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {

        NSString *deviceId = [rs stringForColumn:@"deviceId"];

        if ([[HMDevice objectWithDeviceId:deviceId uid:nil].model isEqualToString:KHumanLightSensorModelID] ||
            [[HMDevice objectWithDeviceId:deviceId uid:nil].model isEqualToString:KHumanLightSensorModelIDHOMMYN]) { //光感
            count ++;
        }

    });
    if (count == 2) {
        return YES;
    }
    return NO;
}

+ (NSString *)getOtherConditionWithLinakgeId:(NSString *)linkageId {

    NSString *sql = [NSString stringWithFormat:@"select linkageConditionId from linkageCondition where linkageId = '%@' and delFlag = 0 and linkageType = 0",linkageId];

    __block NSString *conditionId;
    queryDatabase(sql, ^(FMResultSet *rs) {
        conditionId = [rs stringForColumn:@"linkageConditionId"];
    });
    return conditionId;
}

+ (NSString *)getLightSensorLinakgeHumanConditionWithLinakgeId:(NSString *)linkageId {

    NSString *sql = [NSString stringWithFormat:@"select linkageConditionId from linkageCondition where linkageId = '%@' and condition = 0 and delFlag = 0 and linkageType = 0",linkageId];

    __block NSString *conditionId;
    queryDatabase(sql, ^(FMResultSet *rs) {
        conditionId = [rs stringForColumn:@"linkageConditionId"];
    });
    return conditionId;
}

+ (NSString *)getLightSensorLinkageLightConditionWithLinkageId:(NSString *)linkageId {
    NSString *sql = [NSString stringWithFormat:@"select linkageConditionId from linkageCondition where linkageId = '%@' and condition in (3,4) and delFlag = 0 and linkageType = 0",linkageId];

    __block NSString *conditionId;
    queryDatabase(sql, ^(FMResultSet *rs) {
        conditionId = [rs stringForColumn:@"linkageConditionId"];
    });
    return conditionId;

}

+ (NSString *)getLightSensorLinakgeHumanDeviceIdWithLinakgeId:(NSString *)linkageId {

    NSString *sql = [NSString stringWithFormat:@"select deviceId from linkageCondition where linkageId = '%@' and condition = 0 and delFlag = 0 and linkageType = 0",linkageId];

    __block NSString *deviceId;
    queryDatabase(sql, ^(FMResultSet *rs) {
        deviceId = [rs stringForColumn:@"deviceId"];
    });
    return deviceId;
}

+ (NSString *)getLightSensorLinkageLightDeviceIdWithLinkageId:(NSString *)linkageId {
    NSString *sql = [NSString stringWithFormat:@"select deviceId from linkageCondition where linkageId = '%@' and condition in (3,4) and delFlag = 0 and linkageType = 0",linkageId];

    __block NSString *deviceId;
    queryDatabase(sql, ^(FMResultSet *rs) {
        deviceId = [rs stringForColumn:@"deviceId"];
    });
    return deviceId;
    
}

+ (NSArray *)securityDeviceArrayWithSecurityId:(NSString *)securityId
{
    NSString *sql = [NSString stringWithFormat:@"select * from linkageCondition where linkageId = '%@' and linkageType = 0 and delFlag = 0",securityId];
    __block NSMutableArray *securityConditionArray;
    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!securityConditionArray) {
            securityConditionArray = [[NSMutableArray alloc] init];
        }
        HMLinkageCondition *linkageCondition = [HMLinkageCondition object:rs];
        [securityConditionArray addObject:linkageCondition];
    });
    return securityConditionArray;
}

+ (NSArray *)deviceIdArrayWithSecurityId:(NSString *)securityId
{
    NSString *sql = [NSString stringWithFormat:@"select deviceId from linkageCondition where linkageId = '%@' and delFlag = 0 group by deviceId",securityId];
    __block NSMutableArray *deviceIdArray;
    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!deviceIdArray) {
            deviceIdArray = [[NSMutableArray alloc] init];
        }
        [deviceIdArray addObject:[rs stringForColumn:@"deviceId"]];
    });
    return deviceIdArray;
}

+ (void)deleteConditionWithConditionId:(NSString *)conditionId {

    NSString *sql = [NSString stringWithFormat:@"delete from linkageCondition where linkageConditionId = '%@'",conditionId];
    [self executeUpdate:sql];
}

+ (HMLinkageCondition *)objectWithLinkageConditionId:(NSString *)linkageConditionId {

    NSString *sql = [NSString stringWithFormat:@"select * from linkageCondition where linkageConditionId = '%@'",linkageConditionId];

    __block HMLinkageCondition *linkageCondition = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        linkageCondition = [HMLinkageCondition object:rs];
    });

    return linkageCondition;
}

@end


