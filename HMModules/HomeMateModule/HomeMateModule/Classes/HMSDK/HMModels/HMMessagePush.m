//
//  MessagePush.m
//  HomeMate
//
//  Created by liuzhicai on 15/8/25.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMMessagePush.h"
#import "HMConstant.h"

@implementation HMMessagePush

+(NSString *)tableName
{
    return @"messagePush";
}

+ (NSArray*)columns
{
    return @[
             column("pushId","text"),
             column("familyId","text"),
             column("userId","text"),
             column("type","integer"),
             column("taskId","text"),
             column("isPush","integer"),
             column("startTime","text"),
             column("endTime","text"),
             column("week","integer"),
             column("day","integer"),
             column("authorizedId","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSArray<NSDictionary *>*)newColumns {
    return  @[column("day","integer default 1")];
}

+ (NSString*)constrains
{
    return @"UNIQUE (pushId) ON CONFLICT REPLACE";
}

- (void)prepareStatement
{
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
    if (!self.userId) {
        self.userId = userAccout().userId;
    }

    if (self.taskId == nil) {
        self.taskId = @"";
    }
    if (self.startTime == nil) {
        self.startTime = @"";
    }
    if (self.endTime == nil) {
        self.endTime = @"";
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject
{
    NSString *sql = [NSString stringWithFormat:@"delete from messagePush where pushId = '%@'",self.pushId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    return dic;
}

+ (BOOL)deleteWifiSockectPushSettingWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"delete from messagePush where taskId = '%@'",deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (BOOL)isHasOnCoco
{
    NSString *userId = userAccout().userId;
    NSString *sql = [NSString stringWithFormat:@"select count() as count from messagePush where userId = '%@' and familyId = '%@' and type = 1 and isPush = 0 and delFlag = 0 and taskId in (select deviceId from device where uid in %@ and delFlag = 0)",userId,userAccout().familyId,[HMUserGatewayBind uidStatement]];
   FMResultSet *set = [self executeQuery:sql];
    int count = 0;
    if ([set next]) {
        count = [set intForColumn:@"count"];
    }
    [set close];
    return count > 0 ? YES : NO;
}

+ (BOOL)isHasOnSensor
{
    NSString *userId = userAccout().userId;
    NSString *sql = [NSString stringWithFormat:@"select count() as count from messagePush where userId = '%@' and familyId = '%@' and type = 3 and isPush = 0 and delFlag = 0 and taskId in (select deviceId from device where uid in %@ and delFlag = 0)",userId,userAccout().familyId,[HMUserGatewayBind uidStatement]];
    FMResultSet *set = [self executeQuery:sql];
    int count = 0;
    if ([set next]) {
        count = [set intForColumn:@"count"];
    }
    [set close];
    return count > 0 ? YES : NO;
}

#pragma mark - 所有传感器相关消息是否需要推送
+ (BOOL)allSensorsMessageIsNeedPush
{
    NSString *sql = [NSString stringWithFormat:@"select isPush from messagePush where userId = '%@' and familyId = '%@' and type = %d and delFlag = 0 order by updateTime desc",userAccout().userId,userAccout().familyId,2];
    BOOL isNeedPush = YES;
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        isNeedPush = ([set intForColumn:@"isPush"] == 0) ? YES : NO;
    }
     [set close];
    return isNeedPush;
}

#pragma mark - 所有coco相关消息是否需要推送
+ (BOOL)allCocosMessageIsNeedPush
{
    NSString *sql = [NSString stringWithFormat:@"select isPush from messagePush where userId = '%@' and familyId = '%@' and type = %d and delFlag = 0 order by updateTime desc",userAccout().userId,userAccout().familyId,0];
    BOOL isNeedPush = YES;
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        isNeedPush = ([set intForColumn:@"isPush"] == 0) ? YES : NO;
    }
    [set close];
    return isNeedPush;
}

#pragma mark - 单个coco相关消息是否需要推送
+ (BOOL)singleCocoIsNeedPushWithDeviceId:(NSString *)deviceId
{
    if (![[self class] allCocosMessageIsNeedPush]) {
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"select isPush from messagePush where userId = '%@' and familyId = '%@' and delFlag=0 and type=1 and taskId='%@' order by updateTime desc",userAccout().userId,userAccout().familyId,deviceId];
    BOOL isPush = YES;
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        isPush = ([set intForColumn:@"isPush"] == 1) ? NO : YES;
    }
     [set close];
    return isPush;
}


#pragma mark - 单个传感器相关消息是否需要推送
+ (BOOL)singleSensorsIsNeedPushWithDeviceId:(NSString *)deviceId
{
//    if (![[self class] allSensorsMessageIsNeedPush]) {
//        return NO;
//    }
    NSString *sql = [NSString stringWithFormat:@"select isPush from messagePush where userId = '%@' and familyId = '%@' and delFlag=0 and type=3 and taskId='%@' order by updateTime desc",userAccout().userId,userAccout().familyId,deviceId];
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        return ([set intForColumn:@"isPush"] == 0) ? YES : NO;
    }
     [set close];
    return YES;
}


+ (instancetype)objectWithTaskId:(NSString *)TaskId
{
    NSString *userId = userAccout().userId;
    NSString *sql = [NSString stringWithFormat:@"select * from messagePush where userId = '%@' and familyId = '%@' and taskId = '%@' and delFlag = 0 and type = 3 order by updateTime desc",userId,userAccout().familyId,TaskId];
    FMResultSet *set = [self executeQuery:sql];
    HMMessagePush *msgPushObj = nil;
    if ([set next]) {
        msgPushObj = [HMMessagePush object:set];
    }
    [set close];
    return msgPushObj;
}

+ (instancetype)sensorObjectWithTaskId:(NSString *)taskId {

    NSString *userId = userAccout().userId;
    NSString *sql = [NSString stringWithFormat:@"select * from messagePush where userId = '%@' and familyId = '%@' and taskId = '%@' and delFlag = 0 and type = 9",userId,userAccout().familyId,taskId];
    FMResultSet *set = [self executeQuery:sql];
    HMMessagePush *msgPushObj = nil;
    if ([set next]) {
        msgPushObj = [HMMessagePush object:set];
    }
    [set close];
    return msgPushObj;
}

+ (void)updateTableSetIsPush:(int)isPush type:(int)type taskId:(NSString *)taskId
{
//    MessagePush
    NSString *sql = nil;
    if (!taskId) {
        sql = [NSString stringWithFormat:@"update messagePush set isPush = %d where type = %d and userId = '%@' and familyId = '%@' and delFlag = 0",isPush,type,userAccout().userId,userAccout().familyId];
    }else {
        if (type == 2) {//总开关不需要taskId
            sql = [NSString stringWithFormat:@"update messagePush set isPush = %d where type = %d and userId = '%@' and familyId = '%@' and delFlag = 0",isPush,type,userAccout().userId,userAccout().familyId];
        }else{
            sql = [NSString stringWithFormat:@"update messagePush set isPush = %d where type = %d and userId = '%@' and familyId = '%@' and taskId = '%@' and delFlag = 0",isPush,type,userAccout().userId,userAccout().familyId,taskId];
        }
    }
    [self executeUpdate:sql];
}

+ (BOOL)hasDataWithDeviceId:(NSString *)deviceId
{
    NSString *userId = userAccout().userId;
    NSString *sql = [NSString stringWithFormat:@"select taskId from messagePush where userId = '%@' and familyId = '%@' and taskId = '%@'",userId,userAccout().familyId,deviceId];
    __block BOOL isHas = NO;
    queryDatabase(sql, ^(FMResultSet *rs) {
        if ([rs stringForColumn:@"taskId"]) {
            isHas =  YES ;
        }
    });
    return isHas;
}

+ (void)updateSensorsPushDataIsPush:(int)isPush
{
    NSString *userId = userAccout().userId;
    NSString *sql = [NSString stringWithFormat:@"select deviceId from device where deviceType in (26,46,47,48,49) and uid in %@",[HMUserGatewayBind uidStatement]];
    NSMutableArray *array = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        [array addObject:[rs stringForColumn:@"deviceId"]];
    });
    
    for (NSString *deviceId in array) {
        sql = [NSString stringWithFormat:@"insert into messagePush (userId,familyId,type,taskId,isPush,startTime,endTime,week,delFlag) values('%@','%@',%d,'%@',%d,'%@','%@',%d,%d)",userId,userAccout().familyId,3,deviceId,isPush,@"00:00:00",@"00:00:00",255,0];
        
        if (![[self class] hasDataWithDeviceId:deviceId]) {
            [self executeUpdate:sql];
        }else {
            [[self class] updateTableSetIsPush:isPush type:3 taskId:nil];
        }
    }
}

+ (void)updateCocosPushDataIsPush:(int)isPush
{
    NSString *userId = userAccout().userId;
    NSString *sql = [NSString stringWithFormat:@"select deviceId from device where deviceType = 43 and uid in %@",[HMUserGatewayBind uidStatement]];
    NSMutableArray *array = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        [array addObject:[rs stringForColumn:@"deviceId"]];
    });
    
    for (NSString *deviceId in array) {
        sql = [NSString stringWithFormat:@"insert into messagePush (userId,familyId,type,taskId,isPush,delFlag) values('%@','%@',%d,'%@',%d,%d)",userId,userAccout().familyId,1,deviceId,isPush,0];
        
        if (![[self class] hasDataWithDeviceId:deviceId]) {
            [self executeUpdate:sql];
        }else {
            [[self class] updateTableSetIsPush:isPush type:1 taskId:nil];
        }
    }
}

// 是否需要打开总开关，如果本来为开，则不用
+ (BOOL)isNeedOpenAllSwitchWithType:(int)type
{
     __block BOOL isHas = NO;
    NSString *sql = [NSString stringWithFormat:@"select * from messagePush where type = %d and delFlag = 0 and userId = '%@' and familyId = '%@'",type,userAccout().userId,userAccout().familyId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        isHas = ([rs intForColumn:@"isPush"] == 1) ? YES : NO;
    });
    return isHas;
}

+ (void)OpenAllSwitchWithType:(int)type
{
    if ([[self class] isNeedOpenAllSwitchWithType:type]) {
        NSString *sql = [NSString stringWithFormat:@"update messagePush set isPush = 0 where type = %d and userId = '%@' and familyId = '%@'",type,userAccout().userId,userAccout().familyId];
        [self executeUpdate:sql];
    }
}

#pragma mark - 查找门锁个人的推送
+ (instancetype)objectWithTaskId:(NSString *)TaskId WithAuthorID:(int )authorId
{
    return [self objectWithTaskId:TaskId WithAuthorID:authorId type:4];
}

+ (instancetype)objectWithTaskId:(NSString *)TaskId WithAuthorID:(int )authorId type:(int)type
{
    NSString *familyId = userAccout().familyId;
    NSString *sql = [NSString stringWithFormat:@"select * from messagePush where familyId = '%@' and taskId = '%@' and authorizedId = %d and delFlag = 0 and type = %d",familyId,TaskId,authorId,type];
    FMResultSet *set = [self executeQuery:sql];
    HMMessagePush *msgPushObj = nil;
    if ([set next]) {
        msgPushObj = [HMMessagePush object:set];
    }
    [set close];
    return msgPushObj;
}



/**
 *  是否总开关类型 
 */
+ (BOOL)isAllSwitchType:(int)type {
    if (type == 0
        || type == 2
        || type == 11
        || type == 13
        || type == 14
        || type == 15
        || type == 18   //18:设备报警提示音 19:布撤防提示音 20:设备报警振动
        || type == 19
        || type == 20
        || type == 21) {
        return YES;
    }
    return NO;
}

+ (HMMessagePush *)selectModelWithTaskId:(NSString *)taskId AndType:(int)type{
    __block HMMessagePush * model;
    NSString *sql = nil;
    if ([self isAllSwitchType:type]) {
        sql = [NSString stringWithFormat:@"select * from messagePush where userId = '%@' and familyId = '%@' and type = %d and delFlag = 0 order by updateTime desc",userAccout().userId,userAccout().familyId,type];
        
        if (type ==11) { // 节能提醒全家庭只有一个设置
            sql = [NSString stringWithFormat:@"select * from messagePush where familyId = '%@' and type = %d and delFlag = 0 order by updateTime desc",userAccout().familyId,type];
        }
        
    }else {
        sql = [NSString stringWithFormat:@"select * from messagePush where userId = '%@' and familyId = '%@' and taskId = '%@' and type = %d and delFlag = 0 order by updateTime desc",userAccout().userId,userAccout().familyId,taskId,type];
        
        if (type == 5 || type ==6  || type ==12 || type ==27 ) { // 定时反锁提醒、节能提醒全家庭只有一个设置
            sql = [NSString stringWithFormat:@"select * from messagePush where taskId = '%@' and type = %d and delFlag = 0 order by updateTime desc",taskId,type];
        }else if (type == 28 || type == 29 || type == 30) {
            sql = [NSString stringWithFormat:@"select * from messagePush where familyId = '%@' and taskId = '%@' and type = %d and delFlag = 0 order by updateTime desc",userAccout().familyId,taskId,type];
        }
    }
    
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        model = [HMMessagePush object:set];
    }
    [set close];
    return model;
}

+ (HMMessagePush *)selectModelWithFamilyId:(NSString *)familyId andType:(int)type {
    __block HMMessagePush * model;
    NSString *sql = [NSString stringWithFormat:@"select * from messagePush where userId = '%@' and familyId = '%@' and type = %d and delFlag = 0", userAccout().userId, familyId, type];

    queryDatabase(sql, ^(FMResultSet *rs) {
        model = [HMMessagePush object:rs];
    });
    return model;
}

//查询t1门锁门磁开关消息
+ (HMMessagePush *)t1LockSensorMessagePush:(HMDevice *)device {
    __block HMMessagePush * model;
    NSString *sql = [NSString stringWithFormat:@"select * from messagePush where  familyId = '%@' and delFlag=0 and type=23 and taskId='%@' order by updateTime desc",userAccout().familyId,device.deviceId];
    
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        model = [HMMessagePush object:set];
    }
    [set close];
    return model;
}
@end
