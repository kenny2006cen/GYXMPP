//
//  HMRoomOrderModel.m
//  HomeMate
//
//  Created by user on 16/9/23.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMRoomOrderModel.h"
#import "HMDatabaseManager.h"
@implementation HMRoomOrderModel
+ (NSString *)tableName
{
    return @"roomExt";
}

+ (NSArray*)columns
{
    return @[
             column("roomId","text"),
             column("sequence","integer"),
             column("imgUrl","text")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (roomId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


+(HMRoomOrderModel *)readObjectByRoomId:(NSString *)roomId AndIndex:(NSInteger )index{
    __block HMRoomOrderModel *model;
    NSString *sql = [NSString stringWithFormat:@"select * from roomExt where roomId = '%@'",roomId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        model = [HMRoomOrderModel object:rs];
    });
    if (model == nil) {
        model = [HMRoomOrderModel new];
        model.roomId = roomId;
        model.sequence = index;
        model.imgUrl = @"0";
        [model insertObject];
    }
    return model;
}

+(NSString *)imgUrlWithRoomId:(NSString *)roomId {
    
    __block NSString *imgUrl = @"0";
    NSString *sql = [NSString stringWithFormat:@"select imgUrl from roomExt where roomId = '%@'",roomId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        imgUrl = [rs stringForColumn:@"imgUrl"];
    });
    return imgUrl;
}



@end
