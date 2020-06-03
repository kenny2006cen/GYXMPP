//
//  FrequentlyModeModel.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "HMFrequentlyModeModel.h"

@implementation HMFrequentlyModeModel

+(NSString *)tableName
{
    return @"frequentlyMode";
}

+ (NSArray*)columns
{
    return @[column("frequentlyModeId","text"),
             column("uid","text"),
             column("modeId","integer"),
             column("name","text"),
             column("deviceId","text"),
             column("bindOrder","text"),
             column("value1","integer"),
             column("value2","integer"),
             column("value3","integer"),
             column("value4","integer"),
             column("pic","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

/**不改版本号的情况下，新增的一个column*/
+ (NSArray<NSDictionary *>*)newColumns {
    return @[column("pic","integer")];
}

+ (NSString*)constrains
{
    return @"UNIQUE (frequentlyModeId, uid) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from frequentlyMode where frequentlyModeId = '%@'",self.frequentlyModeId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

/**
 根据value1的百分比匹配模式
 */
+ (instancetype)curtainModelWithDevice:(HMDevice *)device action:(HMAction *)action
{
    HMFrequentlyModeModel *object = nil;
    
    NSString *sql = [NSString stringWithFormat:@"select * from frequentlyMode where deviceId = '%@' and uid = '%@' and value1 = %d and delFlag = 0 order by modeId asc",device.deviceId,device.uid,action.value1];
    
    FMResultSet * rs = [self executeQuery:sql];
    
    if([rs next]){
        object = [HMFrequentlyModeModel object:rs];
    }
    [rs close];
    
    return object;
}

+ (HMFrequentlyModeModel *)frequentlyModeWithFrequentlyModeId:(NSString *)frequentlyModeId
{
    NSString *sql = [NSString stringWithFormat:@"select * from frequentlyMode where frequentlyModeId = '%@' and delFlag = 0",frequentlyModeId];
    
    FMResultSet * rs = [self executeQuery:sql];
    
    if([rs next])
    {
        HMFrequentlyModeModel *object = [HMFrequentlyModeModel object:rs];
        
        [rs close];
        
        return object;
    }
    [rs close];
    
    return nil;
}

+ (instancetype)objectWithDeviceId:(NSString *)deviceId uid:(NSString *)uid
{
    NSString *sql = [NSString stringWithFormat:@"select * from frequentlyMode where deviceId = '%@' and uid = '%@' and delFlag = 0",deviceId,uid];
    
    FMResultSet * rs = [self executeQuery:sql];
    
    if([rs next])
    {
        HMFrequentlyModeModel *object = [HMFrequentlyModeModel object:rs];
        
        [rs close];
        
        return object;
    }
    [rs close];
    
    return nil;
}

+ (NSMutableArray <HMFrequentlyModeModel *>*)allFrequentlyModeForDevice:(HMDevice *)device {
    NSMutableArray * array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from frequentlyMode where deviceId = '%@' and uid = '%@' and delFlag = 0",device.deviceId,device.uid];
    
    if (device.deviceType == KDeviceTypeDeviceGroup) {
        sql = [NSString stringWithFormat:@"select * from frequentlyMode where deviceId = '%@'  and delFlag = 0",device.deviceId];
    }
    
    FMResultSet * rs = [self executeQuery:sql];
    
    while([rs next])
    {
        HMFrequentlyModeModel *object = [HMFrequentlyModeModel object:rs];
        
        [array addObject:object];
        
    }
    [rs close];
    
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        HMFrequentlyModeModel * model1 = (HMFrequentlyModeModel *)obj1;
        HMFrequentlyModeModel * model2 = (HMFrequentlyModeModel *)obj2;
        
        return model1.modeId > model2.modeId;
    }];
    
    return array;
}

+ (BOOL)deleteAllCurtainModeWithDevice:(HMDevice *)device {
    NSString * sql = [NSString stringWithFormat:@"delete from frequentlyMode where deviceId = '%@' and uid = '%@'",device.deviceId, device.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (HMFrequentlyModeModel *)frequentlyModeModelForDevice:(HMDevice*)device andValue:(CGFloat)value {
    NSString *sql = [NSString stringWithFormat:@"select * from frequentlyMode where deviceId = '%@' and uid = '%@' and value1 = %.lf and delFlag = 0",device.deviceId,device.uid,value];
    
    FMResultSet * rs = [self executeQuery:sql];
    HMFrequentlyModeModel *object = nil;
    if ([rs next])
    {
        object = [HMFrequentlyModeModel object:rs];
        
        
    }
    [rs close];
    
    
    return object;
    
}
@end
