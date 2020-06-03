//
//  PushInfoModel.m
//  HomeMate
//
//  Created by Air on 15/8/20.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMMessage.h"
#import "HMConstant.h"

@implementation HMMessage

+(NSString *)tableName
{
    return @"message";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("messageId","text","UNIQUE ON CONFLICT ignore"),  // messageid相同时不能覆盖
             column("userId","text"),
             column("serial","integer"),
             column("infoType","integer"),
             column("text","text"),
             column("action","integer"),
             column("pageId","integer"),
             column("url","text"),
             column("timingId","text"),
             column("status","integer"),
             column("deviceId","text"),
             column("deviceType","integer"),
             column("time","integer"),
             column("bindOrder","text"),
             column("value1","integer"),
             column("value2","integer"),
             column("value3","integer"),
             column("value4","integer"),
             column("online","integer"),
             column("alarmType","integer"),
             column("inviteId","text"),
             column("dealType","integer"),
             column("readType","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

- (void)prepareStatement
{
    if (!self.userId) {
        self.userId = @"unknowUserId";
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


// 防止清空后第一次触发收到多条消息，对最新的消息标记删除，其他消息物理删除
+ (BOOL)deleteMsgWithDeviceId:(NSString *)deciceId
{
    DLog(@"deleteMsgWithDeviceId:%@",deciceId);
    
    NSString *userId = userAccout().userId;
    NSString * sql = [NSString stringWithFormat:@"delete from message where deviceId = '%@' and userId = '%@' and time not in (select max(time) from message where deviceId = '%@' and userId = '%@')",deciceId,userId,deciceId,userId];
    BOOL result = [self executeUpdate:sql];
    
    sql = [NSString stringWithFormat:@"update message set delFlag = 1 where deviceId = '%@' and userId = '%@'",deciceId,userId];
    result = [self executeUpdate:sql];
    return result;
}

// 防止清空后第一次触发收到多条消息，对最新的消息标记删除，其他消息物理删除
+ (BOOL)deleteAllMsg
{
    NSString *userId = userAccout().userId;

    NSString * sql = [NSString stringWithFormat:@"delete from message where userId = '%@' and time not in (select max(time) from message where userId = '%@')",userId,userId];
    BOOL result = [self executeUpdate:sql];
    
    sql = [NSString stringWithFormat:@"update message set delFlag = 1 where userId = '%@'",userId];
   
    result = [self executeUpdate:sql];
    return result;
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from message where messageId = %@",self.messageId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (void)setAllMsgToHasRead
{
    NSString * sql = [NSString stringWithFormat:@"update message set readType = %d where userId = '%@' and delFlag = 0",1,userAccout().userId];
    [self executeUpdate:sql];
}

+ (void)setSomeDeviceMsgToHasReadWithDeviceId:(NSString *)deviceId
{
    NSString * sql = [NSString stringWithFormat:@"update message set readType = %d where userId = '%@' and deviceId = '%@' and delFlag = 0",1,userAccout().userId,deviceId];
    [self executeUpdate:sql];
    
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    return dic;
}

+(int)getUnreadMsgNum
{
    __block int unReadNum = 0;
    NSString *userId = userAccout().userId;
    NSString *sql = [NSString stringWithFormat:@"select count() as count from message where readType = %d and userId = '%@' and infoType in (%@) and deviceId in (select deviceId from device where delFlag = 0) and delFlag = 0 and deviceType not in (%@)",0,userId,kNeedDisplayInfoType,kSecurityDeviceType];
    queryDatabase(sql, ^(FMResultSet *rs) {
        unReadNum = [rs intForColumn:@"count"];
    });
    DLog(@"用户id: %@  未读消息数：%d",userId,unReadNum);
    return unReadNum;
}

+(int)getAllMsgNum
{
    __block int allMsgNum = 0;
    NSString *sql = [NSString stringWithFormat:@"select count() as count from message where userId = '%@' and infoType in (%@) and deviceId in (select deviceId from device where delFlag = 0) and delFlag = 0",userAccout().userId,kNeedDisplayInfoType];

    queryDatabase(sql, ^(FMResultSet *rs) {
        allMsgNum = [rs intForColumn:@"count"];
    });
    DLog(@"用户id: %@  所有消息数：%d",userAccout().userId,allMsgNum);
    return allMsgNum;
}

+(BOOL)isHasHandleInviteWithId:(NSString *)invited
{
    __block BOOL hasHandle = NO;
    NSString *sql = [NSString stringWithFormat:@"select * from message where userId = '%@' and inviteId = '%@' and delFlag = 0",userAccout().userId,invited];
    queryDatabase(sql, ^(FMResultSet *rs) {
        hasHandle = YES;
    });
    return hasHandle;
}

+ (BOOL)isHasSameDataWithSerial:(long long)serial
{
    __block BOOL isHas = NO;
    NSString *sql = [NSString stringWithFormat:@"select * from message where serial = %lld and userId = '%@' and delFlag = 0",serial,userAccout().userId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        isHas = YES;
    });
    return isHas;
}

+ (int)dealTypeWithInviteId:(NSString *)inviteId
{
    int dealType = 0;
    NSString *sql = [NSString stringWithFormat:@"select dealType from message where inviteId = '%@' and userId = '%@' and delFlag = 0",inviteId,userAccout().userId];
    FMResultSet *set = [self executeQuery:sql];
    if ([set next]) {
        dealType = [set intForColumn:@"dealType"];
    }
    [set close];
    return dealType;
}

+ (HMMessage *)lastestMsgWithDeviceId:(NSString *)deviceId
{
    __block HMMessage *msgObj = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from message where time = (select max(time) from message where deviceId = '%@' and delFlag = 0) and delFlag = 0",deviceId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        msgObj = [HMMessage object:rs];
    });
    return msgObj;
}

+ (NSArray *)lastTwentyMsgFromCount:(int)count {
    NSString *userId = userAccout().userId;
    NSString * sql = [NSString stringWithFormat:@"select * from message where userId = '%@' and infoType in (%@) and delFlag = 0 and deviceId in (select deviceId from device where userId = '%@') and deviceType not in (%@) order by time desc, serial desc limit %ld, 20",userId,kNeedDisplayInfoType,userId,kSecurityDeviceType,(long)count];
    __block NSMutableArray *messages = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!messages) {
            messages = [NSMutableArray array];
        }
        HMMessage *msg = [HMMessage object:rs];
        [messages addObject:msg];
    });
    return messages;
}

- (NSString *)minPreciseTimeStr {
   // 2016-10-03 16:10:00
    NSString *minTimeStr = @"";
    if (self.updateTime.length > 3) {
        minTimeStr = [self.updateTime substringToIndex:self.updateTime.length-3];
    }
    return minTimeStr;
}


@end
