//
//  DoorUserModel.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "HMDoorUserModel.h"

#import "HMDevice.h"
#import "HMConstant.h"

@implementation HMDoorUserModel

+(NSString *)tableName
{
    return @"doorUser";
}

+ (NSArray*)columns
{
    return @[
             column("doorUserId","text"),
             column("uid","text"),
             column("deviceId","text"),
             column("authorizedId","integer"),
             column("type","integer"),
             column("name","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (doorUserId, uid) ON CONFLICT REPLACE";
}


-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from doorUser where doorUserId = '%@'",self.doorUserId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+(int)memberNumForDevice:(HMDevice *)device
{
    
    NSString *sql = [NSString stringWithFormat:@"select count() as count from doorUser where uid = '%@' and deviceId = '%@' and authorizedId != 10 and delFlag = 0",device.uid,device.deviceId];
    __block NSInteger count = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {
        count = [rs intForColumn:@"count"];
        
    });
     NSString *sql1 = [NSString stringWithFormat:@"select count() as count from doorUser where uid = '%@' and deviceId = '%@' and authorizedId = 10 and delFlag = 0 ",device.uid,device.deviceId];
    queryDatabase(sql1, ^(FMResultSet *rs) {
            count = MIN(1, [rs intForColumn:@"count"])+count;
    });
    return (int)count;
}

+(NSMutableArray *)selectAllWith:(NSString *)deviceID{
    NSMutableArray *arr = [NSMutableArray new];    
//    NSString *sql = [NSString stringWithFormat:@"select * from doorUser where uid = '%@' and deviceId = '%@' type!=4 UNION select * from (select * from doorUser where uid = '%@' and deviceId = '%@' and type = 4 order by updateTime desc limit 1) order by authorizedId asc",UID(),deviceID,UID(),deviceID];
    HMDevice *device = [HMDevice objectWithDeviceId:deviceID uid:nil];

    NSString *sql = [NSString stringWithFormat:@"select * from doorUser where uid = '%@' and deviceId = '%@' and type!=4 and delFlag = 0 order by authorizedId asc, updateTime desc",device.uid,deviceID];
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        HMDoorUserModel *user = [HMDoorUserModel object:rs];
        
        
        // 霸菱门锁如果是超级管理员且开门类型为关门时不显示
        if (user.type == 0 && user.authorizedId==0 && isBaLingModel(device.model)) {
            
        }else {
            [arr addObject:user];
        }
        
    });
    NSString *sql1 = [NSString stringWithFormat:@"select * from doorUser where uid = '%@' and deviceId = '%@' and type = 4 and delFlag = 0 order by updateTime desc limit 1",device.uid,deviceID];
    queryDatabase(sql1, ^(FMResultSet *rs) {
        if ([self getLeftTimeWithDeviceId:deviceID]) {
            
            HMDoorUserModel *user = [HMDoorUserModel object:rs];
            [arr addObject:user];
            
        }
        
    });
    // 临时用户放到第二位
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"self.type = %d",0];
    NSArray * superUserArray = [arr filteredArrayUsingPredicate:pre]; //超级用户
    
    pre = [NSPredicate predicateWithFormat:@"self.type = %d",4];
    NSArray * tempUserArray = [arr filteredArrayUsingPredicate:pre]; //临时用户
    
    [arr removeObjectsInArray:superUserArray];
    [arr removeObjectsInArray:tempUserArray];
    

    NSMutableArray * sorttArray = [NSMutableArray array];
    
    [sorttArray addObjectsFromArray:superUserArray];
    [sorttArray addObjectsFromArray:tempUserArray];
    [sorttArray addObjectsFromArray:arr];
    
    
    return sorttArray;
}

+(NSMutableArray *)selectAllWithOrder:(NSString *)deviceID {
    NSMutableArray *arr = [NSMutableArray new];
    HMDevice *device = [HMDevice objectWithDeviceId:deviceID uid:nil];

    //非临时用户
    NSString *sql = [NSString stringWithFormat:@"select * from doorUser where uid = '%@' and deviceId = '%@' and type!=4 and delFlag = 0 order by authorizedId asc, updateTime desc",device.uid,deviceID];
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        HMDoorUserModel *user = [HMDoorUserModel object:rs];

        // 霸菱门锁如果是超级管理员且开门类型为关门时不显示
        if (user.type == 0 && user.authorizedId==0 && isBaLingModel(device.model)) {
            
        }else {
            user.showRecord = YES;
            //查询 HMDoorUserBind 的开锁记录设置
            NSString *showRecordSQL = [NSString stringWithFormat:@"select * from deviceSetting where paramId = '%@'",user.doorUserId];
            queryDatabase(showRecordSQL, ^(FMResultSet *rs) {
                HMDeviceSettingModel *deviceSetting = [HMDeviceSettingModel object:rs];
                if ([deviceSetting.paramValue isEqualToString:@"1"]) {
                    user.showRecord = NO;
                }
            });
           [arr addObject:user];
        }
    });
    
    //临时用户
    
    if (![device.model isEqualToString:k9113DoorModelId]) {//9113不显示临时用户
        NSString *sql1 = [NSString stringWithFormat:@"select * from doorUser where uid = '%@' and deviceId = '%@' and type = 4 and delFlag = 0 order by updateTime desc limit 1",device.uid,deviceID];
        queryDatabase(sql1, ^(FMResultSet *rs) {
            if ([self getLeftTimeWithDeviceId:deviceID]) {
                
                HMDoorUserModel *user = [HMDoorUserModel object:rs];
                [arr addObject:user];
                
            }
            
        });
    }
    
   
    NSMutableArray *_dataArr = [NSMutableArray new];
    NSMutableArray *array = [NSMutableArray new];
    if (arr.count == 0) {
        return _dataArr;
    }
    [array addObject:arr[0]];
    [_dataArr addObject:array];
    BOOL superAdmin = 0;
    for (NSInteger i=0; i<arr.count-1; i++) {
        HMDoorUserModel *user1 = arr[i];
        HMDoorUserModel *user2 = arr[i+1];
        if (user1.authorizedId == 0) {
            superAdmin = YES;
        }
        if (user2.type == 4) {
            NSMutableArray *array2 = [NSMutableArray new];
            [array2 addObject:user2];
            [_dataArr insertObject:array2 atIndex:superAdmin];
        }else if (user1.authorizedId == user2.authorizedId) {
            
            [[_dataArr lastObject] addObject:user2];
        }else{
            NSMutableArray *array3 = [NSMutableArray new];
            [array3 addObject:user2];
            [_dataArr addObject:array3];
        }
    }
    
    return _dataArr;
}

+(NSMutableArray *)selectAllExceptTemporaryUserWithOrder:(NSString *)deviceID {
    NSMutableArray *arr = [NSMutableArray new];
    HMDevice *device = [HMDevice objectWithDeviceId:deviceID uid:nil];
    
    //非临时用户
    NSString *sql = [NSString stringWithFormat:@"select * from doorUser where uid = '%@' and deviceId = '%@' and type!=4 and delFlag = 0  order by authorizedId asc, updateTime desc, createTime asc",device.uid,deviceID];
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        HMDoorUserModel *user = [HMDoorUserModel object:rs];
        
        // 霸菱门锁如果是超级管理员且开门类型为关门时不显示
        if (user.type == 0 && user.authorizedId==0 && isBaLingModel(device.model)) {
            
        }else {
            user.showRecord = YES;
            //查询 HMDoorUserBind 的开锁记录设置
            NSString *showRecordSQL = [NSString stringWithFormat:@"select * from deviceSetting where paramId = '%@'",user.doorUserId];
            queryDatabase(showRecordSQL, ^(FMResultSet *rs) {
                HMDeviceSettingModel *deviceSetting = [HMDeviceSettingModel object:rs];
                if ([deviceSetting.paramValue isEqualToString:@"1"]) {
                    user.showRecord = NO;
                }
            });
            [arr addObject:user];
        }
    });
    
    //过滤重复用户
    NSMutableArray *_dataArr = [NSMutableArray new];
    NSMutableArray *array = [NSMutableArray new];
    if (arr.count == 0) {
        return _dataArr;
    }
    [array addObject:arr.firstObject];
    [_dataArr addObject:array];
    for (NSInteger i=0; i<arr.count-1; i++) { //把相同authorizedId的用户放到一个分组
        HMDoorUserModel *user1 = arr[i];
        HMDoorUserModel *user2 = arr[i+1];
        if (user1.authorizedId == user2.authorizedId) {
            [[_dataArr lastObject] addObject:user2];
        }else{
            NSMutableArray *array3 = [NSMutableArray new];
            [array3 addObject:user2];
            [_dataArr addObject:array3];
        }
    }
    NSMutableArray *finalArr = [NSMutableArray array];
    for (NSMutableArray *arr in _dataArr) {//留下每组第一个用户
        if (arr.count) {
            [finalArr addObject:arr.firstObject];
        }
    }
   
    return finalArr;
}


+(HMDoorUserModel *)selectUserWithDoorUserId:(NSString *)doorUserId{
    __block HMDoorUserModel *user = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from doorUser where doorUserId = '%@' ",doorUserId];
    queryDatabase(sql, ^(FMResultSet *rs) {
          user = [HMDoorUserModel object:rs];
        
    });
    return user;
}

+(HMDoorUserModel *)selectUserWithDeviceId:(NSString *)deviceId authorizedId:(int)authorizedId {
    __block HMDoorUserModel *user = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from doorUser where deviceId = '%@' and authorizedId = %d ",deviceId,authorizedId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        user = [HMDoorUserModel object:rs];
        
    });
    return user;
}


+(BOOL )getLeftTimeWithDeviceId:(NSString *)deviceId{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval currentTime=[dat timeIntervalSince1970];
    HMAuthorizedUnlockModel *unlock = [HMAuthorizedUnlockModel SelectRecentUserWithDeviceId:deviceId];
    if (unlock == nil) {
        return 0;
    }
    if (unlock.authorizeStatus == 0) {
        NSInteger endTime =  unlock.startTime +unlock.time*60;
        return endTime>currentTime?1:0;
    }
    return 0;
    
}

+ (NSMutableArray *)getTempUserDevice:(HMDevice *)device {
    NSMutableArray * array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from  doorUser where deviceId = '%@' and type = 4 order by createTime desc",device.deviceId];
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        [array addObject:[HMDoorUserBind object:rs]];
    }
    [rs close];
    return array;
}
@end
