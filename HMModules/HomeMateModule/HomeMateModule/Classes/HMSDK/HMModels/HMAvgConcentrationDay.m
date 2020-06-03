//
//  HMAvgConcentrationDay.m
//  HomeMate
//
//  Created by JQ on 16/8/8.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMAvgConcentrationDay.h"
#import "HMDevice.h"
#import "HMConstant.h"

@implementation HMAvgConcentrationDay

+ (NSString *)tableName
{
    return @"sensorDataDay";
}

+ (NSArray*)columns
{
    return [self columnsWithPrimaryKey:"sensorDataDayId" column1:"day"];
}

+ (NSString*)constrains
{
    return @"UNIQUE (uid, day) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject {
    
    return [self deleteObjectWithPrimaryKey:@"sensorDataDayId" primaryKeyValue:self.sensorDataDayId];
}

+ (NSString *)getAllDataSql:(HMDevice *)device
{
    NSString *sql = [NSString stringWithFormat:@"select * from sensorDataDay where uid = '%@' and familyId = '%@' and delFlag = 0 order by day asc", device.uid, userAccout().familyId];
    return sql;
}


@end
