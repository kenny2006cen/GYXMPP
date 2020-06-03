//
//  HMAvgConcentrationBaseModel.m
//  HomeMate
//
//  Created by JQ on 16/8/9.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMAvgConcentrationBaseModel.h"
#import "HMConstant.h"

@implementation HMAvgConcentrationBaseModel

- (void)setAvgCO:(float)avgCO
{
    _avgCO = avgCO;
    if (![_avgCOStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%.0f",self.avgCO];
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _avgCOStr = str;
    }
}

- (void)setMinCO:(int)minCO
{
    _minCO = minCO;
    if (![_minCOStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%d",self.minCO];
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _minCOStr = str;
    }

}

- (void)setMaxCO:(int)maxCO
{
    _maxCO = maxCO;
    if (![_maxCOStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%d",self.maxCO];
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _maxCOStr = str;
    }
}

- (void)setAvgHCHO:(float)avgHCHO
{
    _avgHCHO = avgHCHO;
    if (![_avgHCHOStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%.2f",self.avgHCHO/100.0];
        str = [NSString stringWithFormat:@"%@",@(str.floatValue)];//把小数点后面的0去掉
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _avgHCHOStr = str;
    }
}
- (void)setMinHCHO:(int)minHCHO
{
    _minHCHO = minHCHO;
    if (![_minHCHOStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%.2f",self.minHCHO/100.0];
        str = [NSString stringWithFormat:@"%@",@(str.floatValue)];
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _minHCHOStr = str;
    }
}
- (void)setMaxHCHO:(int)maxHCHO
{
    _maxHCHO = maxHCHO;
    if (![_maxHCHOStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%.2f",self.maxHCHO/100.0];
        str = [NSString stringWithFormat:@"%@",@(str.floatValue)];
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _maxHCHOStr = str;
    }
}

- (void)setAvgTemp:(float)avgTemp
{
    _avgTemp = avgTemp;
    if (![_avgTempStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%.0f",self.avgTemp/10.0];
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _avgTempStr = str;
    }
}

- (void)setMinTemp:(int)minTemp
{
    _minTemp = minTemp;
    if (![_minTempStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%.0f",self.minTemp/10.0];
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _minTempStr = str;
    }
}

- (void)setMaxTemp:(int)maxTemp
{
    _maxTemp = maxTemp;
    if (![_maxTempStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%.0f",self.maxTemp/10.0];
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _maxTempStr = str;
    }
}

- (void)setAvgHumidity:(float)avgHumidity
{
    _avgHumidity = avgHumidity;
    if (![_avgHumidityStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%.0f",self.avgHumidity];
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _avgHumidityStr = str;
    }
}

- (void)setMinHumidity:(int)minHumidity
{
    _minHumidity = minHumidity;
    if (![_minHumidityStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%d",self.minHumidity];
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _minHumidityStr = str;
    }
}

- (void)setMaxHumidity:(int)maxHumidity
{
    _maxHumidity = maxHumidity;
    if (![_maxHumidityStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%d",self.maxHumidity];
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _maxHumidityStr = str;
    }
}

- (void)setAvgDistBoxPower:(float)avgDistBoxPower
{
    _avgDistBoxPower = avgDistBoxPower;
    if (![_avgDistBoxPowerStr isEqual:[NSNull null]]) {
        NSString *str = [NSString stringWithFormat:@"%f",self.avgDistBoxPower/10.0];
        if ([str isEqualToString:@"-0"]) {
            str = @"0";
        }
        _avgDistBoxPowerStr = str;
    }

}


#pragma mark -数据库操作
+ (NSArray *)columnsWithPrimaryKey:(char *)primaryKey column1:(char *)column1
{
    return @[
             column(primaryKey,"text"),
             column("familyId","text"),
             column("userId","text"),
             column("uid","text"),
             column("deviceId","text"),
             column("avgCO","float"),
             column("avgHCHO","float"),
             column("avgTemp","float"),
             column("avgHumidity","float"),
             column("minCO","integer"),
             column("maxCO","integer"),
             column("minHCHO","integer"),
             column("maxHCHO","integer"),
             column("minTemp","integer"),
             column("maxTemp","integer"),
             column("minHumidity","integer"),
             column("maxHumidity","integer"),
             column(column1,"text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}
+ (NSString *)createTableStirngWithPrimaryKey:(NSString *)primaryKey column1:(NSString *)column1 uniqueColumn:(NSString *)uniqueColumn
{
    return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ("
            "%@             text,"
            "familyId       text,"
            "userId         text,"
            "uid            text,"
            "deviceId       text,"
            "avgCO          float,"
            "avgHCHO        float,"
            "avgTemp        float,"
            "avgHumidity    float,"
            "minCO          integer,"
            "maxCO          integer,"
            "minHCHO        integer,"
            "maxHCHO        integer,"
            "minTemp        integer,"
            "maxTemp        integer,"
            "minHumidity    integer,"
            "maxHumidity    integer,"
            "%@             text,"
            "createTime     text,"
            "updateTime     text,"
            "delFlag        integer,"
            "unique (uid, %@) on conflict replace)",
            [self tableName],primaryKey,column1,uniqueColumn];
}

- (NSString *)updateStatementStringWithPrimaryKey:(NSString *)primaryKey primaryKeyValue:(NSString *)primaryKeyValue column1:(NSString *)colum1 column1Value:(NSString *)column1Value
{
    if (!self.deviceId) {
        self.deviceId = @"";
    }
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@ \
                     (%@, familyId, uid, avgCO, avgHCHO, avgTemp, avgHumidity, minCO, maxCO, minHCHO, maxHCHO, minTemp, maxTemp, minHumidity, maxHumidity, %@,  createTime, updateTime, delFlag, userId, deviceId) values\
                     ('%@','%@','%@', %f,    %f,      %f,      %f,          %d,    %d,    %d,      %d,      %d,      %d,      %d,          %d,          '%@','%@',       '%@',       %d,'%@','%@')",
                     [[self class] tableName],
                     primaryKey, colum1,
                     primaryKeyValue, self.familyId, self.uid, self.avgCO, self.avgHCHO, self.avgTemp, self.avgHumidity, self.minCO, self.maxCO, self.minHCHO, self.maxHCHO, self.minTemp, self.maxTemp, self.minHumidity, self.maxHumidity, column1Value, self.createTime, self.updateTime, self.delFlag, self.userId, self.deviceId];
    return sql;
}



- (BOOL)deleteObjectWithPrimaryKey:(NSString *)primaryKey primaryKeyValue:(NSString *)primaryKeyValue
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@' or uid = '%@'",[[self class] tableName], primaryKey, primaryKeyValue, self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}


- (BOOL)insertObject
{
    NSString *sql  = [self updateStatement];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (BOOL)updateObject {
    
    return [self insertObject];
}

+ (NSString *)getAllDataSql:(HMDevice *)device
{
    return nil;
}

+ (NSArray *)allDataWithDevice:(HMDevice *)device
{
    __block NSMutableArray *dataArray;
    
    NSString *sql = [self getAllDataSql:device];
    if (sql) {
        
        queryDatabase(sql, ^(FMResultSet *rs) {
            if (!dataArray) {
                dataArray = [[NSMutableArray alloc] init];
            }
            [dataArray addObject:[[self class] object:rs]];
        });
    }
    return dataArray;
}

@end

