//
//  ClotheshorseCutdown.m
//  HomeMate
//
//  Created by Air on 15/11/18.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMClotheshorseCutdown.h"
#import "HMDatabaseManager.h"


@implementation HMClotheshorseCutdown

+(NSString *)tableName
{
    return @"clotheshorseCutdown";
}

+ (NSArray*)columns
{
    return @[column_constrains("deviceId"," text","UNIQUE ON CONFLICT REPLACE"),
             column("lightingTime","integer"),
             column("sterilizingTime","integer"),
             column("heatDryingTime","integer"),
             column("windDryingTime","integer")
             ];
    
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from clotheshorseCutdown where deviceId = '%@'",self.deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (HMClotheshorseCutdown *)objectWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select * from clotheshorseCutdown where deviceId = '%@'",deviceId];
    __block HMClotheshorseCutdown *chCutDown = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        chCutDown = [HMClotheshorseCutdown object:rs];
    });
    return chCutDown;
}

+ (void)updateObjWithDeviceId:(NSString *)deviceId countDownTime:(NSInteger)cdTime countDownType:(KCountDownTimeType)cdType
{
    NSMutableString *sql = [NSMutableString stringWithString:@"update clotheshorseCutdown set "];
    switch (cdType) {
        case KCountDownTimeAirDry:
            [sql appendFormat:@"windDryingTime = '%ld' ",(long)cdTime];
            break;
        case KCountDownTimeHeatDry:
            [sql appendFormat:@"heatDryingTime = '%ld' ",(long)cdTime];
            break;
        case KCountDownTimeSterilize:
            [sql appendFormat:@"sterilizingTime = '%ld' ",(long)cdTime];
            break;
        case KCountDownTimeLight:
            [sql appendFormat:@"lightingTime = '%ld' ",(long)cdTime];
            break;
            
        default:
            break;
    }
    [sql appendFormat:@"where deviceId = '%@'",deviceId];
    [self executeUpdate:sql];
}



@end
