//
//  CountdownModel.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "HMCountdownModel.h"
#import "HMConstant.h"

@implementation HMCountdownModel

+(NSString *)tableName
{
    return @"countdown";
}

+ (NSArray*)columns
{
    return @[column("countdownId","text"),
             column("uid","text"),
             column("name","text"),
             column("deviceId","text"),
             column("bindOrder","text"),
             column("pluseData","text"),
             column("freq","integer"),
             column("pluseNum","integer"),
             column("value1","integer"),
             column("value2","integer"),
             column("value3","integer"),
             column("value4","integer"),
             column("time","integer"),
             column("startTime","integer"),
             column("isPause","integer"),
             column("themeId","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
    
}

+ (NSArray<NSDictionary *>*)newColumns {
    return  @[column("themeId","text default ''")];
}

+ (NSString*)constrains
{
    return @"UNIQUE (countdownId, uid) ON CONFLICT REPLACE";
}

- (void)prepareStatement
{
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }
    
    if (!self.name) {
        self.name = @"";
    }
    
    if (!self.pluseData) {
        self.pluseData = @"";
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from countdown where countdownId = '%@' and uid = '%@'",self.countdownId,self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (id)copyWithZone:(NSZone *)zone
{
    HMCountdownModel *obj = [[HMCountdownModel alloc] init];
    obj.countdownId = self.countdownId;
    obj.uid = self.uid;
    obj.name = self.name;
    obj.deviceId = self.deviceId;
    obj.bindOrder = self.bindOrder;
    obj.pluseData = self.pluseData;
    obj.freq = self.freq;
    obj.pluseNum = self.pluseNum;
    obj.value1 = self.value1;
    obj.value2 = self.value2;
    obj.value3 = self.value3;
    obj.value4 = self.value4;
    obj.time = self.time;
    obj.startTime = self.startTime;
    obj.isPause = self.isPause;
    obj.createTime = self.createTime;
    obj.updateTime = self.updateTime;
    obj.delFlag = self.delFlag;
    return obj;
}

+ (NSArray *)validCountdownArrWithDeviceId:(NSString *)deviceId
{
    NSMutableArray *countdownArr = [NSMutableArray array];
    NSInteger currentSecs = [[NSDate date] timeIntervalSince1970];
    NSString *sql = [NSString stringWithFormat:@"select * from countdown where deviceId = '%@' and delFlag = 0 and isPause = 1 and (startTime + time*60 > %ld) order by time asc",deviceId,(long)currentSecs];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMCountdownModel *model = [HMCountdownModel object:rs];
        [countdownArr addObject:model];
    });
    return countdownArr;
 
}

+ (HMCountdownModel *)objectWithCountdownId:(NSString *)countdownId
{
   __block HMCountdownModel *model = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from countdown where countdownId = '%@'",countdownId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        model = [HMCountdownModel object:rs];
    });
    return model;
}


+ (NSArray *)countdownArrWithDeviceId:(NSString *)deviceId
{
    NSMutableArray *countdownArr = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from countdown where deviceId = '%@' and deviceId in (select deviceId from device) and delFlag = 0 order by createTime asc",deviceId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMCountdownModel *model = [HMCountdownModel object:rs];
        [countdownArr addObject:model];
    });
    return countdownArr;
}

+(BOOL)updatePause:(int)isPause startTime:(int)startTime time:(int)time countdownId:(NSString *)countdownId
{
    NSString *updateSql = [NSString stringWithFormat:@"update countdown set isPause = %d, startTime = %d, time = %d where countdownId = '%@'",isPause,startTime,time,countdownId];
    BOOL result = [self executeUpdate:updateSql];
    return result;
}


+(BOOL)updatePause:(int)isPause startTime:(int)startTime countdownId:(NSString *)countdownId
{
    NSString *updateSql = [NSString stringWithFormat:@"update countdown set isPause = %d, startTime = %d where countdownId = '%@'",isPause,startTime,countdownId];
    BOOL result = [self executeUpdate:updateSql];
    return result;
}

+ (BOOL)updateStartTime:(int)startTime countdownId:(NSString *)countdownId
{
    NSString *updateSql = [NSString stringWithFormat:@"update countdown set startTime = %d where countdownId = '%@'",startTime, countdownId];
    BOOL result = [self executeUpdate:updateSql];
    return result;
}

+ (BOOL)updateStartTime:(int)startTime time:(int)time countdownId:(NSString *)countdownId
{
    NSString *updateSql = [NSString stringWithFormat:@"update countdown set startTime = %d, time = %d where countdownId = '%@'",startTime,time,countdownId];
    BOOL result = [self executeUpdate:updateSql];
    return result;
}

+ (BOOL)deleteCountdownObjWithDeviceId:(NSString *)deviceId
{
    DLog(@"deleteCountdownObjWithDeviceId:%@",deviceId);
    
    NSString * sql = [NSString stringWithFormat:@"delete from countdown where deviceId = '%@'",deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (BOOL)deleteCountdownObjWithUid:(NSString *)uid
{
    DLog(@"deleteCountdownObjWithUid:%@",uid);
    
    NSString * sql = [NSString stringWithFormat:@"delete from countdown where uid = '%@'",uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}


+ (NSArray *)sortArrByExecutedTimeWithCountdownArr:(NSArray *)countArray
{
 NSArray *array = [countArray sortedArrayUsingComparator:^NSComparisonResult(id  obj1, id  obj2) {
        
        HMCountdownModel *model1 = (HMCountdownModel *)obj1;
        HMCountdownModel *model2 = (HMCountdownModel *)obj2;
        
        int executeTime1 = model1.startTime + model1.time*60;
        int executeTime2 = model2.startTime + model2.time*60;
        
        if (executeTime1 < executeTime2) {
            return NSOrderedAscending;
        }else if (executeTime1 > executeTime2) {
            return NSOrderedDescending;
        }else {
            return NSOrderedSame;
        }
    }];
    
    return array;
}

+ (int)countDownNumWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select count() as count from countdown where deviceId = '%@'",deviceId];
    __block int countDownNum = 0;
    queryDatabase(sql, ^(FMResultSet *rs) {
        countDownNum = [rs intForColumn:@"count"];
    });
    return countDownNum;
}

@end
