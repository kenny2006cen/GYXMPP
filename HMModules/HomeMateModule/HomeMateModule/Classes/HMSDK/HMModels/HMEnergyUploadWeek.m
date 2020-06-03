//
//  HMEnergyUploadWeek.m
//  HomeMate
//
//  Created by orvibo on 16/7/4.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMEnergyUploadWeek.h"
#import "HMConstant.h"


@implementation HMEnergyUploadWeek

+ (NSString *)tableName {

    return @"energyUploadWeek";
}

+ (NSArray*)columns
{
    return @[column("energyUploadWeekId","text"),
             column("familyId","text"),
             column("uid","text"),
             column("deviceId","text"),
             column("energy","text"),
             column("workingTime","integer"),
             column("week","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","Integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (energyUploadWeekId) ON CONFLICT REPLACE";
}

- (void)prepareStatement {

    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

-(void)deleteHistoryData:(FMDatabase *)db
{
    // 如果存在有本周的数据，则先删除旧的，保证本周数据只有一条。
    
    NSMutableString *deleteOldData = [NSMutableString string];
    
    if (self.deviceId) {
        [deleteOldData appendFormat:@"delete from energyUploadWeek where deviceId = '%@' and week = '%@'",self.deviceId, self.week];
    }else{
        [deleteOldData appendFormat:@"delete from energyUploadWeek where uid = '%@' and week = '%@'",self.uid, self.week];
    }
    
    [db executeUpdate:deleteOldData];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self deleteHistoryData:db];
    [self insertModel:db];
}


- (BOOL)deleteObject {

    NSString *sql = [NSString stringWithFormat:@"delete from energyUploadWeek where energyUploadWeekId = '%@'",_energyUploadWeekId];
    return [self executeUpdate:sql];
}

@end
