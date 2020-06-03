//
//  HMHubOnlineModel.m
//  HomeMateSDK
//
//  Created by liqiang on 2018/2/24.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMHubOnlineModel.h"
#import "HMConstant.h"


@implementation HMHubOnlineModel
+(NSString *)tableName
{
    return @"hubOnline";
}

+ (NSArray*)columns
{
    return @[
             column("familyId", "text"),
             column("uid", "text"),
             column("online", "integer"),
             ];
}


+ (NSString*)constrains
{
    return @"UNIQUE (uid) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}
/**
 根据uid查询网关是否在线（每一个心跳周期从服务器查询一次） 默认是YES
 
 @param uid
 @return YES 在线  NO 不在线
 */
+ (BOOL)hubOnline:(NSString *)uid {
    HMHubOnlineModel *onlineModel = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from hubOnline where uid = '%@' and familyId = '%@'",uid,userAccout().familyId];
    FMResultSet *rs = [self executeQuery:sql];
    if ([rs next]) {
        onlineModel = [HMHubOnlineModel object:rs];
    }
    [rs close];
    if (onlineModel) {
        DLog(@"找到相应主机在线网络状态，返回状态 %d",onlineModel.online);
        return onlineModel.online;
    }
    DLog(@"没有找到相应主机在线网络状态，返回默认在线状态");
    return YES;
}
+ (HMHubOnlineModel *)hubOnlineModel:(NSString *)uid {
    HMHubOnlineModel *onlineModel = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from hubOnline where uid = '%@' and familyId = '%@'",uid,userAccout().familyId];
    FMResultSet *rs = [self executeQuery:sql];
    if ([rs next]) {
        onlineModel = [HMHubOnlineModel object:rs];
    }
    [rs close];
    
    return onlineModel;
}

+ (NSArray <HMHubOnlineModel *>* )hubOnlineModelWithUids:(NSArray *)uids {
    NSMutableArray * array = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from hubOnline where uid in (%@) and familyId = '%@'",stringWithObjectArray(uids),userAccout().familyId];
    queryDatabase(sql, ^(FMResultSet *rs) {
       HMHubOnlineModel * onlineModel = [HMHubOnlineModel object:rs];
        if (onlineModel) {
            [array addObject:onlineModel];
        }
    });
    return array;
}

@end
