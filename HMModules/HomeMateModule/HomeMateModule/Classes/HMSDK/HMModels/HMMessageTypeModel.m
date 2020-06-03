//
//  HMMessageTypeModel.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2018/2/6.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMMessageTypeModel.h"
#import "HomeMateSDK.h"

@implementation HMMessageTypeModel

+ (NSString *)tableName {
    
    return @"messageType";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("typeId","text","UNIQUE ON CONFLICT REPLACE"),
             column("familyId","text"),
             column("type","integer"), // 列表项分组序号
             column("delFlag","integer"),
             column("updateTime","text"),
             column("createTime","text")
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+ (NSMutableArray *)messageTypesArrOfFamilyId:(NSString *)familyId
{
    NSString *sql = [NSString stringWithFormat:@"select distinct type from messageType where familyId = '%@' and delFlag= 0 and type != -1 order by type asc",familyId];
    NSMutableArray *tmpArray = [NSMutableArray array];
    queryDatabase(sql, ^(FMResultSet *rs) {
        int type = [rs intForColumn:@"type"];
        [tmpArray addObject:@(type)];
    });
    return tmpArray;
}

@end
