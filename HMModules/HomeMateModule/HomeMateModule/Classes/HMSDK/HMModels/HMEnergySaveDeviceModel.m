//
//  EnergySaveDeviceModel.m
//  HomeMate
//
//  Created by liuzhicai on 15/12/22.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "HMEnergySaveDeviceModel.h"

@implementation HMEnergySaveDeviceModel

+(NSString *)tableName
{
    return @"deviceEnergySave";
}

+ (NSArray*)columns
{
    return @[column_constrains("deviceId","text","UNIQUE ON CONFLICT REPLACE"),
             column("energySaveFlag","integer"),
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}



- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from deviceEnergySave where deviceId = '%@'",self.deviceId];
    BOOL result = [self executeUpdate:sql];
    return result;
}



@end
