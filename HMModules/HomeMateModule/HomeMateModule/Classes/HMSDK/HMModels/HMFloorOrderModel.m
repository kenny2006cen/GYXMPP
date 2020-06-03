//
//  HMFloorOrderModel.m
//  HomeMate
//
//  Created by user on 16/9/22.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMFloorOrderModel.h"
#import "HMDatabaseManager.h"

@implementation HMFloorOrderModel

+ (NSString *)tableName
{
    return @"floorExt";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("floorId","text","UNIQUE ON CONFLICT REPLACE"),
             column("sequence","integer")
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+(HMFloorOrderModel *)readObjectByFloorId:(NSString *)floorId AndIndex:(NSInteger )index{
    __block HMFloorOrderModel *model;
    NSString *sql = [NSString stringWithFormat:@"select * from floorExt where floorId = '%@'",floorId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        model = [HMFloorOrderModel object:rs];
    });
    if (model == nil) {
        model = [HMFloorOrderModel new];
        model.floorId = floorId;
        model.sequence = index;
        [model insertObject];
    }
    
    
    return model;
}

@end
