//
//  HMAvgConcentrationWeek.m
//  HomeMate
//
//  Created by JQ on 16/8/8.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMAvgConcentrationWeek.h"
#import "HMDevice.h"
#import "HMConstant.h"


@implementation HMAvgConcentrationWeek

+ (NSString *)tableName
{
    return @"sensorDataWeek";
}

+ (NSArray*)columns
{
    return [self columnsWithPrimaryKey:"sensorDataWeekId" column1:"week"];
}

+ (NSString*)constrains
{
    return @"UNIQUE (uid, week) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject {
    
    return [self deleteObjectWithPrimaryKey:@"sensorDataWeekId" primaryKeyValue:self.sensorDataWeekId];
}

+ (NSString *)getAllDataSql:(HMDevice *)device
{
    NSString *sql = [NSString stringWithFormat:@"select * from sensorDataWeek where uid = '%@' and familyId = '%@' and delFlag = 0 order by week asc", device.uid, userAccout().familyId];
    return sql;
}


@end
