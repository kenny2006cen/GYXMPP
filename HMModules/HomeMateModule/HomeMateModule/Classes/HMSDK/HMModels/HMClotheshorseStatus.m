//
//  ClotheshorseStatus.m
//  HomeMate
//
//  Created by Air on 15/11/18.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMClotheshorseStatus.h"
#import "HMDatabaseManager.h"


@implementation HMClotheshorseStatus

+(NSString *)tableName
{
    return @"clotheshorseStatus";
}

+ (NSArray*)columns
{
    return @[column_constrains("deviceId","text","UNIQUE ON CONFLICT REPLACE"),
             column("motorState","text"),
             column("motorStateTime","text"),
             column("motorPosition","integer"),
             column("motorPositionTime","text"),
             column("lightingState","text"),
             column("lightingStateTime","text"),
             column("sterilizingState","text"),
             column("sterilizingStateTime","text"),
             column("heatDryingState","text"),
             column("heatDryingStateTime","text"),
             column("windDryingState","text"),
             column("windDryingStateTime","text"),
             column("mainSwitchState","text"),
             column("mainSwitchStateTime","text"),
             column("exceptionInfo","text"),
             column("exceptionInfoTime","text")
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from clotheshorseStatus where deviceId = '%@'",self.deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (HMClotheshorseStatus *)objectWithDeviceId:(NSString *)deviceId
{
    NSString *sql = [NSString stringWithFormat:@"select * from clotheshorseStatus where deviceId = '%@'",deviceId];
    __block HMClotheshorseStatus *chStatus = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        chStatus = [HMClotheshorseStatus object:rs];
    });
    return chStatus;
}

+ (BOOL)updateStatusType:(KStatusType)type ctrlTime:(NSString *)ctrlTime status:(int)status deviceId:(NSString *)deviceId
{
    NSString *sql = nil;
    NSString *order = (status == 1) ? @"on" : @"off";
    switch (type) {
        case KStatusTypeWindDry:
            sql = [NSString stringWithFormat:@"update clotheshorseStatus set windDryingState = '%@',windDryingStateTime = '%@' where deviceId = '%@'",order,ctrlTime,deviceId];
            break;
        case KStatusTypeHeatDry:
            sql = [NSString stringWithFormat:@"update clotheshorseStatus set heatDryingState = '%@',heatDryingStateTime = '%@' where deviceId = '%@'",order,ctrlTime,deviceId];
            break;
        case KStatusTypeLight:
            sql = [NSString stringWithFormat:@"update clotheshorseStatus set lightingState = '%@',lightingStateTime = '%@' where deviceId = '%@'",order,ctrlTime,deviceId];
            break;
        case KStatusTypeSterilize:
            sql = [NSString stringWithFormat:@"update clotheshorseStatus set sterilizingState = '%@',sterilizingStateTime = '%@' where deviceId = '%@'",order,ctrlTime,deviceId];
            break;
        case KStatusTypeMainCtrl:
            sql = [NSString stringWithFormat:@"update clotheshorseStatus set mainSwitchState = '%@',mainSwitchStateTime = '%@' where deviceId = '%@'",order,ctrlTime,deviceId];
            break;
        default:
            break;
    }
    
    return [self executeUpdate:sql];
}



@end
