//
//  HMEnergyUploadDay.m
//  HomeMate
//
//  Created by orvibo on 16/7/4.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMEnergyUploadDay.h"
#import "HMConstant.h"

@implementation HMEnergyUploadDay

+ (NSString *)tableName {

    return @"energyUploadDay";
}

+ (NSArray*)columns
{
    return @[column("energyUploadDayId","text"),
             column("familyId","text"),
             column("uid","text"),
             column("deviceId","text"),
             column("energy","text"),
             column("workingTime","integer"),
             column("day","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","Integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (energyUploadDayId) ON CONFLICT REPLACE";
}

- (void)prepareStatement {

    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

-(void)deleteHistoryData:(FMDatabase *)db
{
    // 如果存在有今天的数据，则先删除旧的，保证，当天数据只有一条。
    
    NSMutableString *deleteOldData = [NSMutableString string];
    
    if (self.deviceId) {
        [deleteOldData appendFormat:@"delete from energyUploadDay where deviceId = '%@' and day = '%@'",self.deviceId, _day];
    }else{
        [deleteOldData appendFormat:@"delete from energyUploadDay where uid = '%@' and day = '%@'",self.uid, _day];
    }
    
    [db executeUpdate:deleteOldData];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self deleteHistoryData:db];
    [self insertModel:db];
}


- (BOOL)deleteObject {

    NSString *sql = [NSString stringWithFormat:@"delete from energyUploadDay where energyUploadDayId = '%@'",_energyUploadDayId];
    return [self executeUpdate:sql];
}

@end
