//
//  AuthorizedUnlock.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "HMAuthorizedUnlockModel.h"

@implementation HMAuthorizedUnlockModel

+(NSString *)tableName
{
    return @"authorizedUnlock";
}

+ (NSArray*)columns
{
    return @[column("authorizedUnlockId","text"),
             column("uid","text"),
             column("deviceId","text"),
             column("authorizer","text"),
             column("authorizedId","Integer"),
             column("phone","text"),
             column("time","Integer"),
             column("number","Integer"),
             column("startTime","Integer"),
             column("unlockNum","Integer"),
             column("authorizeStatus","Integer"),
             column("pwdUseType","integer"),
             column("day","text"),
             column("createTimeSec","integer"),
             column("updateTimeSec","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE(authorizedUnlockId, uid) ON CONFLICT REPLACE";
}

/**不改版本号的情况下，新增的一个column*/
+ (NSArray<NSDictionary *>*)newColumns {
    return @[column("day","text default ''")
             ,column("pwdUseType","integer default 0")
             ,column("createTimeSec","integer default 0")
             ,column("updateTimeSec","integer default 0")];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from authorizedUnlock where authorizedUnlockId = '%@'",self.authorizedUnlockId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (HMAuthorizedUnlockModel *)SelectRecentUserWithDeviceId:(NSString *)deviceId{
    __block HMAuthorizedUnlockModel *unlock = nil;
    
    HMDevice *device = [HMDevice objectWithDeviceId:deviceId uid:nil];
    
    NSString *sql = [NSString stringWithFormat:@"select * from authorizedUnlock where uid = '%@' and deviceId = '%@' and delFlag = 0 order by createTime desc limit 1",device.uid,deviceId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        unlock = [HMAuthorizedUnlockModel object:rs];
    });
    return unlock;
}


/**
 *  获取最近三次次授权的用户信息
 *
 *  @param device
 *
 *  @return
 */
+(NSMutableArray<HMAuthorizedUnlockModel *> *)selectRecentThreeUserWithDevice:(HMDevice *)device {

    NSMutableArray * array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from authorizedUnlock where uid = '%@' and deviceId = '%@' and delFlag = 0 order by createTime desc limit 3",device.uid,device.deviceId];

    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        [array addObject:[HMAuthorizedUnlockModel object:rs]];
    }
    [rs close];
    
    return array;
}


/**
 *  获取有效的授权开锁信息
 *
 *  @param deviceID
 *
 *  @return
 */
+(NSMutableArray *)selectUserWithDevice:(HMDevice *)device {
    NSMutableArray * array = [NSMutableArray array];
    NSString *scope = @"(26,27,28,29,30)"; // T1，C1默认临时授权authorizedId取值返回
    
    // H1 26-30 自定义时长密码
    // H1 36-40 周期性密码
    if (device.deviceType == KDeviceTypeLockH1) {
        scope = @"(26,27,28,29,30,36,37,38,39,40)";
    }
    NSString *sql = [NSString stringWithFormat:@"select * from authorizedUnlock where uid = '%@' and deviceId = '%@' and delFlag = 0 and authorizeStatus = 0 and authorizedId in %@ order by createTime",device.uid,device.deviceId,scope];
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        [array addObject:[HMAuthorizedUnlockModel object:rs]];
    }
    [rs close];
    return array;
}

+ (BOOL)deleteUnlockModelDevice:(HMDevice *)device {
    NSString * sql = [NSString stringWithFormat:@"delete from authorizedUnlock where deviceId = '%@'",device.deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

@end
