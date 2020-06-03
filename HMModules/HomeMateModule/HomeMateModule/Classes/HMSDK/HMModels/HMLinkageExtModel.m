//
//  HMLinkageExtModel.m
//  HomeMateSDK
//
//  Created by orvibo on 16/10/8.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMLinkageExtModel.h"
#import "HMConstant.h"
#import "HMLinkage.h"
#import "HMDatabaseManager.h"


@implementation HMLinkageExtModel

+ (NSString *)tableName {

    return @"linkageExt";
}

+ (NSArray*)columns
{
    return @[column("linkageId","text"),
             column("sequence","Integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (linkageId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject {

    NSString * sql = [NSString stringWithFormat:@"delete from linkageExt where linkageId = '%@'", self.linkageId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (void)insertObjectWithLinkageId:(NSString *)linkageId isInsertTail:(BOOL)insertTail {

    if (insertTail) {  // 插到尾部
        NSString *sql = [NSString stringWithFormat:@"select max(sequence) as max from linkageExt"];

        __block int max;
        queryDatabase(sql, ^(FMResultSet *rs) {
            max = [rs intForColumn:@"max"];
        });
        self.sequence = max + 1;

    } else {    // 否则插到头部

        NSString *sql = [NSString stringWithFormat:@"select min(sequence) as min from linkageExt"];

        __block int min;
        queryDatabase(sql, ^(FMResultSet *rs) {
            min = [rs intForColumn:@"min"];
        });
        self.sequence = min - 1;
    }

    self.linkageId = linkageId;
    [self updateObject];

}

+ (void)deleteObjectWithLinkageId:(NSString *)linkageId {

    NSString *sql = [NSString stringWithFormat:@"delete from linkageExt where linkageId = '%@'", linkageId];

    [self executeUpdate:sql];
}

+ (NSArray *)readAllLinkageArray {

    // 联合查询 (查出有排序的联动)

    // 2.4 新需求，允许有空条件的联动存在
        NSString *sql = [NSString stringWithFormat:@"select distinct l.* from linkage l, linkageExt ext where l.familyId = '%@' and l.delFlag = 0 and ext.linkageId = l.linkageId order by ext.sequence asc", userAccout().familyId];

    __block NSMutableArray *unionLinkageArray =  [NSMutableArray array];

    queryDatabase(sql, ^(FMResultSet *rs) {

        HMLinkage *linkage = [HMLinkage object:rs];
        if (linkage) {
            [unionLinkageArray addObject:linkage];
        }
    });
    if (!unionLinkageArray.count) {     // 如果联合查询没有数据，说明，本次查询为首次查询，排序表没有数据，直接把联动返回
        return [HMLinkage allLinkagesArr];
    }

    NSArray *allLinkageArray = [HMLinkage allLinkagesArr];


    if (allLinkageArray.count > unionLinkageArray.count) {

        // 所有的有排序的 linkageId
        NSArray *unionLinkageId = [unionLinkageArray valueForKey:@"linkageId"];

        // 所有的没排序的联动
        NSPredicate *notSortedLinkagePred = [NSPredicate predicateWithFormat:@"NOT (self.linkageId in %@)", unionLinkageId];
        NSArray *notSortedLinkage = [allLinkageArray filteredArrayUsingPredicate:notSortedLinkagePred];
        NSMutableArray *totalArray = [[NSMutableArray alloc] init];
        totalArray = [NSMutableArray arrayWithArray:unionLinkageArray];
        [totalArray addObjectsFromArray:notSortedLinkage];
        return totalArray;
    }
    return unionLinkageArray;
}

+ (HMLinkageExtModel *)objectWithLinakgeId:(NSString *)linkageId {
    NSString *sql = [NSString stringWithFormat:@"select * from linkageExt where linkageId = '%@'",linkageId];

    __block HMLinkageExtModel *extModel;
    queryDatabase(sql, ^(FMResultSet *rs) {
        extModel = [HMLinkageExtModel object:rs];
    });
    return extModel;
}

@end
