//
//  HMAMapTip.m
//  HomeMateSDK
//
//  Created by peanut on 2018/8/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMAMapTip.h"
#import "HMBaseModel+Extension.h"


@implementation HMAMapTip
+(NSString *)tableName
{
    return @"maptip";
}

+ (NSArray*)columns
{
    return @[
             column("uid", "text"),
             column("name", "text"),
             column("adcode", "text"),
             column("district", "integer"),
             column("address", "text"),
             column("typecode", "integer"),
             column("latitude", "float"),
             column("longitude", "float"),
             column("createTime", "text"),
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (uid) ON CONFLICT REPLACE";
}



+ (NSMutableArray *)allTips {
    NSMutableArray * array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from maptip order by createTime desc limit 10"];
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        [array addObject:[HMAMapTip object:rs]];
    }
    [rs close];
    return array;
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}
- (BOOL)deleteObject {
    
    NSString * sql = [NSString stringWithFormat:@"delete from HMAMaptip where uid = '%@' ",self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}
@end
