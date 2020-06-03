//
//  HMDoorUserBind.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMDoorUserBind.h"
#import "HMDevice.h"
#import "HMDeviceSettingModel.h"
#import "HMUserGatewayBind.h"

@implementation HMDoorUserBind
+ (NSString *)tableName {
    return @"doorUserBind";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("bindId","text","UNIQUE ON CONFLICT REPLACE"),
             column("uid","text"),
             column("userId","text"),
             column("extAddr","text"),
             column("authorizedId","integer"),
             column("name","text"),
             column("fp1","text"),
             column("fp2","text"),
             column("fp3","text"),
             column("fp4","text"),
             column("pwd1","text"),
             column("pwd2","text"),
             column("rf1","text"),
             column("rf2","text"),
             column("uniqueId","integer"),
             column("modifiedRecord","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}
+ (NSArray<NSDictionary *> *)newColumns {
    return  @[column("rf1","text"),column("rf2","text"),column("uniqueId","integer"),
              column("modifiedRecord","integer"),];
}

+ (HMDoorUserBind *)objectForBindId:(NSString *)bindId {
    HMDoorUserBind *user = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from doorUserBind where bindId = '%@' and delFlag = 0",bindId];
    FMResultSet *rs = [self executeQuery:sql];
    if ([rs next]) {
        user = [HMDoorUserBind object:rs];
    }
    [rs close];
    return user;
}
+ (NSMutableArray *)objectForextAddr:(HMDevice *)device {
    NSString * createTime = device.createTime;
    if (device.isC1Lock) {
        createTime = @"0"; //c1不能判断时间
    }
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from doorUserBind where extAddr = '%@' and  authorizedId < 26 and delFlag = 0 and updateTime >= '%@' order by createTime",device.extAddr,createTime];
    
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        HMDoorUserBind *doorUserBind = [HMDoorUserBind object:rs];
        doorUserBind.showRecord = YES;
        //查询 HMDoorUserBind 的开锁记录设置
        NSString *showRecordSQL = [NSString stringWithFormat:@"select * from deviceSetting where paramId = '%@'",doorUserBind.bindId];
        queryDatabase(showRecordSQL, ^(FMResultSet *rs) {
            HMDeviceSettingModel *deviceSetting = [HMDeviceSettingModel object:rs];
            if ([deviceSetting.paramValue isEqualToString:@"1"]) {
                doorUserBind.showRecord = NO;
            }
        });
        [array addObject:doorUserBind];
    }
    [rs close];
    return array;
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from doorUserBind where bindId = '%@' ",self.bindId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (BOOL)deleteAllObjectWithExtAddr:(NSString *)extAddr;
{
    NSString * sql = [NSString stringWithFormat:@"delete from doorUserBind where extAddr = '%@' ",extAddr];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (HMDoorUserBind *)objectForDevice:(HMDevice *)device authorizedId:(int)authorizedId {
    NSString * createTime = device.createTime;
    if (device.isC1Lock) {
        createTime = @"";
    }
    HMDoorUserBind *user = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from doorUserBind where extAddr = '%@' and authorizedId = %d and delFlag = 0 and createTime > '%@'",device.extAddr,authorizedId,createTime];
    FMResultSet *rs = [self executeQuery:sql];
    if ([rs next]) {
        user = [HMDoorUserBind object:rs];
    }
    [rs close];
    return user;
}

+ (HMDoorUserBind *)objectForDevice:(HMDevice *)device authorizedId:(int)authorizedId recordTime:(NSString *)recordTime {
    
    HMDoorUserBind *user = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from doorUserBind where extAddr = '%@' and authorizedId = %d and delFlag = 0 and createTime <= '%@' order by createTime desc",device.extAddr,authorizedId,recordTime];
    FMResultSet *rs = [self executeQuery:sql];
    if ([rs next]) {
        user = [HMDoorUserBind object:rs];
    }
    [rs close];
    return user;
}

// 获取临时授权用户
+(NSMutableArray *)selectTempUserWithDevice:(HMDevice *)device {
    
    if (device.deviceType == KDeviceTypeLockH1) {
        return [self tempUsersForH1Lock:device];
    }
    NSString * createTime = device.createTime;
    if (device.isC1Lock) {
        createTime = [HMUserGatewayBind bindWithUid:device.uid].createTime;
    }
    NSMutableArray * array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from doorUserBind where extAddr = '%@' and authorizedId in (26,27,28,29,30) and delFlag = 0 and createTime > '%@' order by createTime ",device.extAddr,createTime];
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        [array addObject:[HMDoorUserBind object:rs]];
    }
    [rs close];
    return array;
}

+ (NSMutableArray *)sortedDoorUsersForDevice:(HMDevice *)device {
    NSMutableArray *array = [NSMutableArray array];
    NSString * sql = @"";
    if(device.isC1Lock){
      sql = [NSString stringWithFormat:@"select * from doorUserBind where extAddr = '%@' and delFlag = 0 order by createTime asc",device.extAddr];
    }else {
       sql = [NSString stringWithFormat:@"select * from doorUserBind where extAddr = '%@' and delFlag = 0 and createTime >= '%@' order by createTime",device.extAddr,device.createTime];
    }
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        [array addObject:[HMDoorUserBind object:rs]];
    }
    [rs close];
    
    if (!array.count) {
        return array;
    }
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    // 把门锁用户找出来
    NSArray *tmpUserAuthorIdArr = @[@(26),@(27),@(28),@(29),@(30)];
    NSArray *users = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (self.authorizedId in %@)",tmpUserAuthorIdArr]];
    [tmpArray addObjectsFromArray:users];
    
    // 移除门锁用户得到临时用户
    [array removeObjectsInArray:users];

    // 把临时用户加在后面
    [tmpArray addObjectsFromArray:array];

    return tmpArray;
}


- (void)setDeleteDoorUser:(NSNumber *)delFlag {
    self.delFlag = delFlag.intValue;
}

/**
 H1门锁所有用户，不包含临时授权用户
 */
+ (NSMutableArray *)usersForH1Lock:(HMDevice *)device
{
    NSMutableArray *array = [NSMutableArray array];
    
    // 1 管理员-密码 2管理员-刷卡
    // >100 本地录入的密码和卡用户
    NSString *sql = [NSString stringWithFormat:@"select * from doorUserBind u LEFT join deviceSetting s on s.paramId = u.bindId and s.delFlag = 0 where u.extAddr = '%@' and u.delFlag = 0 and u.updateTime >= '%@' and (u.authorizedId >= 100 or u.authorizedId == 1 or u.authorizedId == 2) order by u.createTime,u.authorizedId",device.extAddr,device.createTime];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMDoorUserBind *doorUserBind = [HMDoorUserBind object:rs];
        doorUserBind.showRecord = YES;
        //查询 HMDoorUserBind 的开锁记录设置
        NSString *paramValue = [rs stringForColumn:@"paramValue"];
        if ([paramValue isEqualToString:@"1"]) {
            doorUserBind.showRecord = NO;
        }
        
        [array addObject:doorUserBind];
    });
    return array;
}

/**
 H1门锁临时授权用户
 */
+ (NSMutableArray *)tempUsersForH1Lock:(HMDevice *)device
{
    NSMutableArray *array = [NSMutableArray array];
    
    // 26-30 临时密码 31-35 临时卡
    // 36-40 周期密码 41-45 周期卡
    NSString *sql = [NSString stringWithFormat:@"select * from doorUserBind where extAddr = '%@' and authorizedId in (26,27,28,29,30,36,37,38,39,40) and delFlag = 0 and createTime > '%@' order by createTime ",device.extAddr,device.createTime];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMDoorUserBind *doorUserBind = [HMDoorUserBind object:rs];
        [array addObject:doorUserBind];
    });
    return array;
}
@end
