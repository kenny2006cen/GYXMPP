//
//  HMAvgConcentrationMonth.m
//  HomeMate
//
//  Created by JQ on 16/8/8.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMAvgConcentrationMonth.h"
#import "HMConstant.h"

@implementation HMAvgConcentrationMonth

+ (NSString *)tableName
{
    return @"sensorDataMonth";
}

+ (NSArray*)columns
{
    return [self columnsWithPrimaryKey:"sensorDataMonthId" column1:"month"];
}

+ (NSString*)constrains
{
    return @"UNIQUE (uid, month) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject {
    
    return [self deleteObjectWithPrimaryKey:@"sensorDataMonthId" primaryKeyValue:self.sensorDataMonthId];
}

+ (NSString *)getAllDataSql:(HMDevice *)device
{
    NSString *sql = [NSString stringWithFormat:@"select * from sensorDataMonth where uid = '%@' and familyId = '%@' and delFlag = 0 order by month asc", device.uid, userAccout().familyId];
    return sql;
}

@end
