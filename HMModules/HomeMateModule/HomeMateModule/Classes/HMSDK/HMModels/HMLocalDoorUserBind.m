//
//  HMLocalDoorUserBind.m
//  HomeMateSDK
//
//  Created by peanut on 2019/4/4.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMLocalDoorUserBind.h"

@implementation HMLocalDoorUserBind
+ (NSString *)tableName {
    return @"localDoorUserBind";
}


- (instancetype)init {
    if (self = [super init]) {
        self.createTime = getCurrentTime(@"yyyy-MM-dd HH:mm:ss");
        self.updateTime = self.createTime;
        self.bindId = [self defaultBindId];
    }
    return self;
}

+ (HMLocalDoorUserBind *)objectFromDoorUserBind:(HMDoorUserBind *)userBind {
    HMLocalDoorUserBind * bindUser = [[HMLocalDoorUserBind alloc] init];
    bindUser.name = userBind.name;
    bindUser.bindId = userBind.bindId;
    bindUser.userId = userBind.userId;
    bindUser.extAddr = userBind.extAddr;
    bindUser.authorizedId = userBind.authorizedId;
    bindUser.fp1 = userBind.fp1;
    bindUser.fp2 = userBind.fp2;
    bindUser.fp3 = userBind.fp3;
    bindUser.fp4 = userBind.fp4;
    bindUser.pwd1 = userBind.pwd1;
    bindUser.pwd2 = userBind.pwd2;
    bindUser.rf1 = userBind.rf1;
    bindUser.rf2 = userBind.rf2;
    bindUser.uniqueId = userBind.uniqueId;
    bindUser.modifiedRecord = userBind.modifiedRecord;
    bindUser.createTime = userBind.createTime;
    bindUser.createTimeSec = userBind.createTimeSec;
    bindUser.uid = userBind.uid;
    bindUser.familyId = userBind.familyId;
    bindUser.delFlag = userBind.delFlag;

    return bindUser;
    
}

- (BOOL)insertObject
{
   
    HMDevice * lock = [HMDevice lockWithExtAddr:self.extAddr];
    
    if (lock == nil) {
        DLog(@"C1插入本地数据，设备不存在 extAddr = %@",self.extAddr);
        return NO;
    }
    
    HMDoorUserBind * doorUserBind = [HMLocalDoorUserBind objectForDevice:lock authorizedId:self.authorizedId];
    
    if (doorUserBind) {
        BOOL ret =  [doorUserBind deleteObject];
        DLog(@"C1插入本地数据，授权id = %d extAddr = %@ 已存在要删除,删除结果 %d",self.authorizedId, self.extAddr,ret);
    }
    
    
    return [self insertModel:[HMDatabaseManager shareDatabase].db];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    self.updateTime = getCurrentTime(@"yyyy-MM-dd HH:mm:ss");

    [self insertModel:db];
}


+ (HMDoorUserBind *)objectForBindId:(NSString *)bindId {
    HMLocalDoorUserBind *user = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from localDoorUserBind where bindId = '%@' and delFlag = 0",bindId];
    FMResultSet *rs = [self executeQuery:sql];
    if ([rs next]) {
        user = [HMLocalDoorUserBind object:rs];
    }
    [rs close];
    return user;
}

+ (NSMutableArray *)localUpdateToServerObjectForextAddr:(HMDevice *)device {
    
    NSString * createTime = device.createTime;
    if (device.isC1Lock) {
        createTime = [HMUserGatewayBind bindWithUid:device.uid].createTime;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from localDoorUserBind where extAddr = '%@' and  authorizedId < 26 and updateTime >= '%@' order by createTime",device.extAddr,createTime];
    
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        HMLocalDoorUserBind *doorUserBind = [HMLocalDoorUserBind object:rs];
        doorUserBind.showRecord = YES;
        //查询 HMLocalDoorUserBind 的开锁记录设置
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

+ (NSMutableArray *)objectForextAddr:(HMDevice *)device {
    NSString * createTime = device.createTime;
    if (device.isC1Lock) {
        createTime = [HMUserGatewayBind bindWithUid:device.uid].createTime;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from localDoorUserBind where extAddr = '%@' and  authorizedId < 26 and delFlag = 0 and updateTime >= '%@' order by createTime",device.extAddr,createTime];
    
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        HMLocalDoorUserBind *doorUserBind = [HMLocalDoorUserBind object:rs];
        doorUserBind.showRecord = YES;
        //查询 HMLocalDoorUserBind 的开锁记录设置
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


+ (NSMutableArray *)localObjectForextAddr:(HMDevice *)device {
    
    NSString * createTime = device.createTime;
    if (device.isC1Lock) {
        createTime = [HMUserGatewayBind bindWithUid:device.uid].createTime;
    }
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from localDoorUserBind where extAddr = '%@' and  authorizedId < 26 and delFlag = 0 and updateTime >= '%@' and bindId like '%%%@%%'  order by createTime",device.extAddr,createTime,@"local"];
    
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        HMLocalDoorUserBind *doorUserBind = [HMLocalDoorUserBind object:rs];
        doorUserBind.showRecord = YES;
        //查询 HMLocalDoorUserBind 的开锁记录设置
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
    NSString * sql = [NSString stringWithFormat:@"delete from localDoorUserBind where bindId = '%@' ",self.bindId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (BOOL)deleteAllObjectWithExtAddr:(NSString *)extAddr;
{
    NSString * sql = [NSString stringWithFormat:@"delete from localDoorUserBind where extAddr = '%@' ",extAddr];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (HMDoorUserBind *)objectForDevice:(HMDevice *)device authorizedId:(int)authorizedId {
    NSString * createTime = device.createTime;
    if (device.isC1Lock) {
        createTime = [HMUserGatewayBind bindWithUid:device.uid].createTime;
    }
    HMLocalDoorUserBind *user = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from localDoorUserBind where extAddr = '%@' and authorizedId = %d and delFlag = 0 and createTime > '%@'",device.extAddr,authorizedId,createTime];
    FMResultSet *rs = [self executeQuery:sql];
    if ([rs next]) {
        user = [HMLocalDoorUserBind object:rs];
    }
    [rs close];
    return user;
}

-(NSString*)defaultBindId {
    
    char data[27];
    
    for (int x=0;x<27;data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    NSString * string = [[[NSString alloc] initWithBytes:data length:27 encoding:NSUTF8StringEncoding] lowercaseString];

    return [NSString stringWithFormat:@"local%@",string];
    
    
}

+ (BOOL)deleteExtAddrInArray:(NSArray *)extAddrArray {
    if (extAddrArray.count == 0) {
        return NO;
    }
    NSMutableString *uidString = [NSMutableString string];
    for (NSString *uid in extAddrArray) {
        [uidString appendFormat:@"'%@',",uid];
    }
    // 删除最后一个 ',' 逗号
    if ([uidString hasSuffix:@","]) {
        NSString *result = [uidString substringToIndex:uidString.length - 1];
        [uidString setString:result];
    }
    
    NSString * sql = [NSString stringWithFormat:@"delete from localDoorUserBind where extAddr in (%@) ",uidString];
    BOOL result = [self executeUpdate:sql];
    return result;
    
}


+ (void)uploadLoaclUserToServer {
    
    NSMutableArray * allSet = [[NSMutableArray alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"select distinct extAddr from localDoorUserBind"];
    
    FMResultSet *set = [[HMDatabaseManager shareDatabase] executeQuery:sql];
    
    while ([set next]){
        NSString * model = [set stringForColumn:@"extAddr"];
        if (model) {
            [allSet addObject:model];
        }
    }
    [set close];
    
    if(allSet.count == 0) {
        DLog(@"本地没有缓存的门锁数据");
        return;
    }
    
    NSMutableArray * allUploadUser = [NSMutableArray array];
    
    for (NSString * extAddr in allSet) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from device where extAddr = '%@'",extAddr];
        FMResultSet *resultSet = [self executeQuery:sql];
        if (![resultSet next]) {//说明设备不存在了，要把本地的保存的删除
            DLog(@"物理地址为：%@的设备已被删除，这里要清除所有的本地保存的设备",extAddr);
            [HMLocalDoorUserBind deleteAllObjectWithExtAddr:extAddr];
        }else {
            HMDevice * device = [HMDevice object:resultSet];
            NSArray * users = [HMLocalDoorUserBind localUpdateToServerObjectForextAddr:device];//查询用户创建时间比设备创建时间晚的用户
            [allUploadUser addObjectsFromArray:users];
        }
        [resultSet close];
    }
    
    NSMutableArray * userList = [NSMutableArray array];
    
    [allUploadUser enumerateObjectsUsingBlock:^(HMLocalDoorUserBind * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        
        if (obj.extAddr.length) {
            [dic setObject:obj.extAddr forKey:@"extAddr"];
        }
        
        [dic setObject:@(obj.authorizedId) forKey:@"authorizedId"];
        
        if (obj.familyId.length) {
            [dic setObject:obj.familyId forKey:@"familyId"];
        }
        if (obj.name.length) {
            [dic setObject:obj.name forKey:@"name"];
        }
        if (obj.pwd2) {
            [dic setObject:obj.pwd2 forKey:@"pwd2"];
        }
        if (obj.pwd1) {
            [dic setObject:obj.pwd1 forKey:@"pwd1"];
        }
        if (obj.fp1) {
            [dic setObject:obj.fp1 forKey:@"fp1"];
        }
        if (obj.fp2) {
            [dic setObject:obj.fp2 forKey:@"fp2"];
        }
        if (obj.fp3) {
            [dic setObject:obj.fp3 forKey:@"fp3"];
        }
        if (obj.fp4) {
            [dic setObject:obj.fp4 forKey:@"fp4"];
        }
        if (obj.rf1) {
            [dic setObject:obj.rf1 forKey:@"rf1"];
        }
        if (obj.rf2) {
            [dic setObject:obj.rf2 forKey:@"rf2"];
        }
        if (obj.userId) {
            [dic setObject:obj.userId forKey:@"userId"];
        }
        
        [dic setObject:@(obj.uniqueId) forKey:@"uniqueId"];
        [dic setObject:@(obj.modifiedRecord) forKey:@"modifiedRecord"];
        
        if (userAccout().familyId) {
            [dic setObject:userAccout().familyId forKey:@"familyId"];
        }
       
        [dic setObject:@(obj.delFlag) forKey:@"delFlag"];
        
        [userList addObject:dic];
        
        
    }];
    
    UploadLockUsersCmd *cmd = [UploadLockUsersCmd object];
    cmd.userList = userList;
    
    
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if(returnValue == KReturnValueSuccess || returnValue == KReturnValuePartialFailure) {
          BOOL result =  [HMLocalDoorUserBind deleteExtAddrInArray:allSet];
            DLog(@"上报本地保存的门锁数据 成功，删除本地门锁数据 结果 %d",result);
        }
    });

    
}


@end
