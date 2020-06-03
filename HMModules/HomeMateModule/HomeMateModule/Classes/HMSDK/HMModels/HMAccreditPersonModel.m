//
//  HMAccreditPersonModel.m
//  HomeMate
//
//  Created by orvibo on 15/12/10.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMAccreditPersonModel.h"
#import "HMBaseModel+Extension.h"
#import "HMDatabaseManager.h"


@implementation HMAccreditPersonModel
+(NSString *)tableName
{
    return @"recentVisitRecord";
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
    return @"UNIQUE (deviceId, phone) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from recentVisitRecord where phone  = '%@'",self.phone];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+(NSMutableArray *)selectAllWith:(NSString *)deviceID{
    NSMutableArray *arr = [NSMutableArray new];
    __block NSInteger i=0;
    NSString *sql = [NSString stringWithFormat:@"select * from recentVisitRecord where deviceId = '%@' order by updateTime",deviceID];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        i++;
        HMAccreditPersonModel *model = [HMAccreditPersonModel object:rs];
        if (i<4) {
            [arr addObject:model];
        }else{
            [model deleteObject];
        }
        
    });

    return arr;
}

@end
