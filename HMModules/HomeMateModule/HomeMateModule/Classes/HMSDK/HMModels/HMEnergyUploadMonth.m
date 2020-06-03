//
//  HMEnergyUploadMonth.m
//  HomeMate
//
//  Created by orvibo on 16/7/4.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMEnergyUploadMonth.h"
#import "HMConstant.h"


@implementation HMEnergyUploadMonth

+ (NSString *)tableName {

    return @"energyUploadMonth";
}

+ (NSArray*)columns
{
    return @[
             column("energyUploadMonthId","text"),
             column("familyId","text"),
             column("uid","text"),
             column("deviceId","text"),
             column("energy","text"),
             column("workingTime","integer"),
             column("month","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","Integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (energyUploadMonthId) ON CONFLICT REPLACE";
}


- (void)prepareStatement {

    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

-(void)deleteHistoryData:(FMDatabase *)db
{
    // 如果存在有本月的数据，则先删除旧的，保证本月数据只有一条。
    
    NSMutableString *deleteOldData = [NSMutableString string];
    
    if (self.deviceId) {
        [deleteOldData appendFormat:@"delete from energyUploadMonth where deviceId = '%@' and month = '%@'",self.deviceId, self.month];
    }else{
        [deleteOldData appendFormat:@"delete from energyUploadMonth where uid = '%@' and month = '%@'",self.uid, self.month];
    }
    
    [db executeUpdate:deleteOldData];
}


-(void)setInsertWithDb:(FMDatabase *)db
{
    [self deleteHistoryData:db];
    [self insertModel:db];
}


- (BOOL)deleteObject {

    NSString *sql = [NSString stringWithFormat:@"delete from energyUploadMonth where energyUploadMonthId = '%@'",_energyUploadMonthId];
   return [self executeUpdate:sql];
}

/**
 *  本月用电
 */
+ (CGFloat)currMonEnergyUseWithDeviceId:(NSString *)deviceId {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *compsCurrentMY = [calendar components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currentMonth = [compsCurrentMY month];
    NSInteger currentYear = [compsCurrentMY year];
    
    NSString *monthStr = [NSString stringWithFormat:@"%ld-%02ld",(long)currentYear,(long)currentMonth];

    __block CGFloat currMonEnergyUse = 0;
    NSString *sql = [NSString stringWithFormat:@"select energy from energyUploadMonth where deviceId = '%@' and month = '%@'",deviceId,monthStr];
    queryDatabase(sql, ^(FMResultSet *rs) {
        currMonEnergyUse = [[rs stringForColumn:@"energy"] floatValue];
    });
    return currMonEnergyUse;
}

+ (BOOL)isHasCurrMonEnergyUseWithDeviceId:(NSString *)deviceId {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *compsCurrentMY = [calendar components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currentMonth = [compsCurrentMY month];
    NSInteger currentYear = [compsCurrentMY year];
    
    NSString *monthStr = [NSString stringWithFormat:@"%ld-%02ld",(long)currentYear,(long)currentMonth];
    
    __block BOOL isHasCurrMonEnergyUse = NO;
    NSString *sql = [NSString stringWithFormat:@"select energy from energyUploadMonth where deviceId = '%@' and month = '%@'",deviceId,monthStr];
    queryDatabase(sql, ^(FMResultSet *rs) {
        isHasCurrMonEnergyUse = YES;
    });
    return isHasCurrMonEnergyUse;
}

@end
