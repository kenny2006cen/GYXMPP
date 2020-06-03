//
//  HMMessageCommonModel.m
//  HomeMateSDK
//
//  Created by liuzhicai on 16/11/17.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMMessageCommonModel.h"
#import "HMConstant.h"


@implementation HMMessageCommonModel

+(NSString *)tableName
{
    return @"messageCommon";
}


+ (NSArray*)columns
{
    return @[
             column("messageCommonId","text"),
             column("familyId","text"),
             column("userId","text"),
             column("deviceId","text"),
             column("text","text"),
             column("deviceName","text"),
             column("roomName","text"),
             column("readType","integer"),
             column("time","integer"),
             column("deviceType","integer"),
             column("value1","integer"),
             column("value2","integer"),
             column("value3","integer"),
             column("value4","integer"),
             column("sequence","integer"),
             column("isPush","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer"),
             column("infoType", "integer"),
             column("type", "integer"),
             column("rule", "text"),
             column("params", "text"),
             column("classifiedSequence", "integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (messageCommonId,userId) ON CONFLICT REPLACE";
}

- (void)prepareStatement
{
    if (!self.userId) {
        self.userId = userAccout().userId;
    }
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
    if (!self.deviceName) {
        self.deviceName = @"";
    }
    if (!self.roomName) {
        self.roomName = @"";
    }
}


-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


+ (int)getMaxSequenceNum
{
    return [self getMaxSequenceNumWithFamilyId:userAccout().familyId messageType:HMMessageTypeAll];
}

// 查找最大的已删除的序号，如果消息都小于此序号，不显示
+ (int)getMaxDeleteSequenceWithFamilyId:(NSString *)familyId messageType:(HMMessageType)messageType
{
    NSString *sql = @"";
    // 查最大序号不能结合delFlag = 1 来查，否则会把清空的数据请求回来
    if(messageType == HMMessageTypeAll){
        sql = [NSString stringWithFormat:@"select max(sequence) as maxDeleteSequence from messageCommon where familyId = '%@' and userId = '%@' and delFlag = 1",familyId,userAccout().userId];
    }else {
        sql = [NSString stringWithFormat:@"select max(classifiedSequence) as maxDeleteSequence from messageCommon where familyId = '%@' and userId = '%@' and type = %ld and delFlag = 1",familyId,userAccout().userId,(long)messageType];
    }
    
    __block int maxDeleteSequenceNum = -1;
    queryDatabase(sql,^(FMResultSet *rs){
        maxDeleteSequenceNum = [rs intForColumn:@"maxDeleteSequence"];
    });
    return maxDeleteSequenceNum;
}

+ (int)getMaxSequenceNumWithFamilyId:(NSString *)familyId messageType:(HMMessageType)messageType {
    if (!familyId) {
        familyId = userAccout().familyId;
    }
    NSString *sql = @"";
    // 查最大序号不能结合delFlag = 1 来查，否则会把清空的数据请求回来
    if(messageType == HMMessageTypeAll){
        sql = [NSString stringWithFormat:@"select max(sequence) as maxSequence from messageCommon where familyId = '%@' and userId = '%@'",familyId,userAccout().userId];
    }else {
        sql = [NSString stringWithFormat:@"select max(classifiedSequence) as maxSequence from messageCommon where familyId = '%@' and userId = '%@' and type = %ld",familyId,userAccout().userId,(long)messageType];
    }
    
    __block int maxSequenceNum = 0;
    queryDatabase(sql,^(FMResultSet *rs){
        
        maxSequenceNum = [rs intForColumn:@"maxSequence"];
        
    });
    
    return maxSequenceNum;
}


+ (NSArray *)lastTwentyMsgFromCount:(int)count messageType:(HMMessageType)messageType {
    NSString *familyId = userAccout().familyId;
    NSString *userId = userAccout().userId;
    NSString * sql = @"";
    
    int maxDeleteSequence = [self getMaxDeleteSequenceWithFamilyId:familyId messageType:messageType];
    
    if (messageType == HMMessageTypeAll) {// 全部还是按原来的逻辑处理
        sql = [NSString stringWithFormat:@"select * from messageCommon where familyId = '%@' and userId = '%@' and sequence > %d and delFlag = 0 order by sequence desc limit %ld, 20",familyId,userId,maxDeleteSequence,(long)count];
    }else {// 其他分类按分类的消息分类字段 type 分类的序列classifiedSequence 来处理
        sql = [NSString stringWithFormat:@"select * from messageCommon where familyId = '%@' and userId = '%@' and classifiedSequence > %d and type = %ld and delFlag = 0 order by classifiedSequence desc limit %ld, 20",familyId,userId,maxDeleteSequence,(long)messageType,(long)count];
    }
    
    __block NSMutableArray *messages = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!messages) {
            messages = [NSMutableArray array];
        }
        HMMessageCommonModel *msg = [HMMessageCommonModel object:rs];
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

// 防止清空后，第一次触发收到多条消息，对最新的消息标记删除，其他消息物理删除
+ (BOOL)deleteAllMsg
{
    NSString *userId = userAccout().userId;
    NSString *familyId = userAccout().familyId;
    // 不能物理删除，否则删了会导致清空后又读回来
    NSString * sql = [NSString stringWithFormat:@"update messageCommon set delFlag = 1 where familyId = '%@' and userId = '%@'",familyId,userId];
    
    BOOL result = [self executeUpdate:sql];
    return result;
}

+(int)getUnreadMsgNum
{
    return [self getUnreadMsgNumWithFamilyId:userAccout().familyId];
}

+(int)getUnreadMsgNumWithFamilyId:(NSString *)familyId
{
    NSMutableArray *msgTypeArr = [HMMessageTypeModel messageTypesArrOfFamilyId:familyId];
    if (msgTypeArr.count == 0) {
        return 0; // 如果消息类型表没有，则直接返回0
    }
    __block int unReadNum = 0;
    NSString *sql = [NSString stringWithFormat:@"select count() as count from messageCommon where readType = %d and familyId = '%@' and userId = '%@' and delFlag = 0",0,familyId,userAccout().userId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        unReadNum = [rs intForColumn:@"count"];
    });
    DLog(@"家庭id: %@  未读消息数：%d",familyId,unReadNum);
    return unReadNum;
}


+(BOOL)isHasHomePageRedInFamilyId:(NSString *)familyId{
    return [self getUnreadMsgNumWithFamilyId:familyId] > 0;
}

+ (void)setAllMsgToHasRead
{
    NSString * sql = [NSString stringWithFormat:@"update messageCommon set readType = %d where familyId = '%@' and userId = '%@'",1,userAccout().familyId,userAccout().userId];
    [self executeUpdate:sql];
}

+ (BOOL)isHasInterruptMsgAfterSomeSequence:(HMMessageCommonModel *)messageCommonModel messageType:(HMMessageType)messageType
{
    int tempSequence = 0;
    int currSequence = 0;
    int sequence = 0;
    BOOL isHas = NO;
    NSString * sql = @"";
    if (messageType == HMMessageTypeAll) {// 全部还是按原来的逻辑处理
        sequence = messageCommonModel.sequence;
        sql = [NSString stringWithFormat:@"select * from messageCommon where familyId = '%@' and userId = '%@' and sequence <= %d and delFlag = 0 order by sequence desc limit 0, 20",userAccout().familyId,userAccout().userId,sequence];
    }else {// 其他分类按分类的消息分类字段 type 分类的序列classifiedSequence 来处理
        sequence = messageCommonModel.classifiedSequence;
        sql = [NSString stringWithFormat:@"select * from messageCommon where familyId = '%@' and userId = '%@' and type = %ld and classifiedSequence <= %d and delFlag = 0 order by classifiedSequence desc limit 0, 20",userAccout().familyId,userAccout().userId,(long)messageType,sequence];
    }
    tempSequence = sequence;
    
    FMResultSet *set = [self executeQuery:sql];
    NSInteger count = 0;
    while ([set next]) {
        count ++;
        if (messageType == HMMessageTypeAll) {//所有消息类型用sequence字段
            currSequence = [set intForColumn:@"sequence"];
        }else {//其他类型消息用 classifiedSequence
            currSequence = [set intForColumn:@"classifiedSequence"];
        }
        if(tempSequence - currSequence != 1 && currSequence != sequence) {
            isHas = YES;
            break;
        }
        tempSequence = currSequence;
    }
    
    if (count == 1 && sequence != 1) { // 说明只剩下当前序号，则中断了
        isHas = YES;
    }
    [set close];
    return isHas;
}

// 获取小于某个序号的最大中断序号（20条以内），如果中断则去服务器请求
+ (int)getInterruptSequenceAfterSomeSequence:(HMMessageCommonModel *)messageCommonModel messageType:(HMMessageType)messageType{
    int currSequence = 0;
    int sequence = 0;

    NSString *sql = @"";
    if (messageType == HMMessageTypeAll) {
        sequence = messageCommonModel.sequence;
        sql = [NSString stringWithFormat:@"select * from messageCommon where familyId = '%@' and userId = '%@' and sequence <= %d and delFlag = 0 order by sequence desc limit 0, 20",userAccout().familyId,userAccout().userId,sequence];
    }else {
        sequence = messageCommonModel.classifiedSequence;
        sql = [NSString stringWithFormat:@"select * from messageCommon where familyId = '%@' and userId = '%@' and type = %ld and classifiedSequence <= %d and delFlag = 0 order by classifiedSequence desc limit 0, 20",userAccout().familyId,userAccout().userId,(long)messageType,sequence];

    }
    int interruptSequence = sequence; // 中断序号
    int tempSequence = sequence;

    FMResultSet *set = [self executeQuery:sql];
    while ([set next]) {
        if (messageType == HMMessageTypeAll) {
            currSequence = [set intForColumn:@"sequence"];
        }else {
            currSequence = [set intForColumn:@"classifiedSequence"];
        }
        if(tempSequence - currSequence != 1  &&  tempSequence != currSequence) {
            interruptSequence = tempSequence;
            break;
        }
        tempSequence = currSequence;
    }
    [set close];
    return interruptSequence;
}

+ (NSMutableArray *)getCommonMsgBetweenMinSequence:(int)minSequence maxSequence:(int)maxSequence familyId:(NSString *)familyId messageType:(HMMessageType)messageType
{
    NSMutableArray *commonMsgArr = [NSMutableArray array];
    NSString *sql = @"";
    if (messageType == HMMessageTypeAll) {
        sql = [NSString stringWithFormat:@"select * from messageCommon where familyId = '%@' and userId = '%@' and sequence >= %d and sequence < %d and delFlag = 0 order by sequence desc",familyId,userAccout().userId,minSequence,maxSequence];
    }else {
        sql = [NSString stringWithFormat:@"select * from messageCommon where familyId = '%@' and userId = '%@' and classifiedSequence >= %d and classifiedSequence < %d and type = %ld and delFlag = 0 order by classifiedSequence desc",familyId,userAccout().userId,minSequence,maxSequence,(long)messageType];

    }
    
    FMResultSet *set = [self executeQuery:sql];
    while ([set next]) {
        
        HMMessageCommonModel *srModel = [HMMessageCommonModel object:set];
        [commonMsgArr addObject:srModel];
    }
    [set close];
    return commonMsgArr;
}


+ (NSMutableArray *)getCommonMsgBetweenMinSequence:(int)minSequence maxSequence:(int)maxSequence messageType:(HMMessageType)messageType
{
    return [self getCommonMsgBetweenMinSequence:minSequence maxSequence:maxSequence familyId:userAccout().familyId messageType:messageType];
}

// 获取小于某序号的数据，（每次查20条） (序号可能不连续)
+ (NSMutableArray *)continuousMessageAfterSomeSequence:(HMMessageCommonModel *)messageCommonModel messageType:(HMMessageType)messageType{
    NSMutableArray *recordsArr = [NSMutableArray array];
    int currSequence = 0;
    int sequence = 0;
    NSString *sql = @"";
    int maxDeleteSequence = [self getMaxDeleteSequenceWithFamilyId:userAccout().familyId messageType:messageType];

    if (messageType == HMMessageTypeAll) {
        sequence = messageCommonModel.sequence;
        sql =[NSString stringWithFormat:@"select * from messageCommon where familyId = '%@' and userId = '%@' and sequence <= %d and sequence > %d and delFlag = 0 order by sequence desc limit 0, 20",userAccout().familyId,userAccout().userId,sequence,maxDeleteSequence];
    }else {
        sequence = messageCommonModel.classifiedSequence;
        sql =[NSString stringWithFormat:@"select * from messageCommon where familyId = '%@' and userId = '%@' and classifiedSequence <= %d and classifiedSequence > %d and delFlag = 0 and type = %ld order by classifiedSequence desc limit 0, 20",userAccout().familyId,userAccout().userId,sequence,maxDeleteSequence,(long)messageType];

    }
    int tempSequence = sequence;
    
    FMResultSet *set = [self executeQuery:sql];
    
    while ([set next]) {
        if (messageType == HMMessageTypeAll) {
            currSequence = [set intForColumn:@"sequence"];

        }else {
            currSequence = [set intForColumn:@"classifiedSequence"];

        }
        
        if (tempSequence == currSequence) {
            continue;
        }
//        if(tempSequence - currSequence != 1) {
//            break;
//        }
        HMMessageCommonModel *srModel = [HMMessageCommonModel object:set];
        [recordsArr addObject:srModel];
        tempSequence = currSequence;
    }
    
    [set close];
    
    
    return recordsArr;
}

- (NSString *)messageTitle
{
    _messageTitle = @"";
    NSDictionary *parmsDic = [self dictionaryWithJsonString:self.params];
    if (parmsDic) {
        _messageTitle = parmsDic[@"title"];
    }    
    return _messageTitle;
}

- (NSString *)msgIconUrl
{
    _msgIconUrl = @"";
    NSDictionary *parmsDic = [self dictionaryWithJsonString:self.params];
    if (parmsDic) {
        _msgIconUrl = parmsDic[@"imageUrl"];
    }
    return _msgIconUrl;
}

- (NSString *)pageUrl
{
    _pageUrl = @"";
    NSDictionary *parmsDic = [self dictionaryWithJsonString:self.params];
    if (parmsDic) {
        _pageUrl = parmsDic[@"url"];
    }
    return _pageUrl;
}

- (BOOL)isIOSSystem {
    NSDictionary *ruleDic = [self dictionaryWithJsonString:self.rule];
    if (ruleDic) {
        NSArray *osArr = ruleDic[@"os"];
        if ([osArr isKindOfClass:[NSArray class]]) {
            return [osArr containsObject:@"iOS"];
        }else {
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    return [BLUtility dictionaryWithJsonString:jsonString];
}

- (BOOL)isShouldDisplay {
    _isShouldDisplay = YES;
    if (self.infoType == 47) {
        if ([self isIOSSystem]) {
            
            if (!isBlankString(self.rule))
            {
                NSDictionary *ruleDic = [self dictionaryWithJsonString:self.rule];
                NSArray *verArr = ruleDic[@"ver"];
                if ([verArr isKindOfClass:[NSArray class]] && verArr.count > 0)
                {
                    if ([verArr containsObject:[self appVersion]]) {
                        
                    }else {
                        _isShouldDisplay = NO;
                        DLog(@"版本号数组不为空，且不包含app当前版本不显示");
                    }
                }
            }
            
        }else {
            _isShouldDisplay = NO;
        }
    }
    return _isShouldDisplay;
}

-(NSString *)appVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}


@end
