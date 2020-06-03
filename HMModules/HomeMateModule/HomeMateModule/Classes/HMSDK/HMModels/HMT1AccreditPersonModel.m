//
//  HMT1AccreditPersonModel.m
//  HomeMateSDK
//
//  Created by liqiang on 2018/1/20.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMT1AccreditPersonModel.h"
#import "HMConstant.h"
#import "HMBaseModel+Extension.h"
#import "HMDatabaseManager.h"

@implementation HMT1AccreditPersonModel
+(NSString *)tableName
{
    return @"T1RecentVisitRecord";
}

+ (NSArray*)columns
{
    return @[
             column("name", "text"),
             column("uid", "text"),
             column("time", "text"),
             column("createTime", "text"),
             column("updateTime", "text"),
             column("deviceId", "text"),
             column("phone", "text")
             ];
}


+ (NSString*)constrains
{
    return @"UNIQUE (deviceId, name) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from T1RecentVisitRecord where name  = '%@'",self.name];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+(NSMutableArray *)selectAllWith:(NSString *)deviceID{
    NSMutableArray *arr = [NSMutableArray new];
    __block NSInteger i = 0;
    NSString *sql = [NSString stringWithFormat:@"select * from T1RecentVisitRecord where deviceId = '%@' order by updateTime desc",deviceID];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        i++;
        HMT1AccreditPersonModel *model = [HMT1AccreditPersonModel object:rs];
        if (i<4) {
            [arr addObject:model];
        }else{
            [model deleteObject];
        }
        
    });
    
    return arr;
}

@end
