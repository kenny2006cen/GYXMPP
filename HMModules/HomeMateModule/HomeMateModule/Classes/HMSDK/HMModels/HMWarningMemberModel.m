//
//  HMWarningMemberModel.m
//  HomeMate
//
//  Created by orvibo on 16/6/30.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMWarningMemberModel.h"
#import "HMConstant.h"


@implementation HMWarningMemberModel

+ (NSString *)tableName {

    return @"warningMember";
}

+ (NSArray*)columns
{
    return @[
             column("warningMemberId","text"),
             column("familyId","text"),
             column("secWarningId","text"),
             column("memberSortNum","integer"),
             column("memberName","text"),
             column("memberPhone","text"),
             column("deviceId","text"),
             column("authorizedId","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSArray<NSDictionary *>*)newColumns
{
    return @[column("deviceId","text"),
             column("authorizedId","integer")];
}

+ (NSString*)constrains
{
    return @"UNIQUE (warningMemberId) ON CONFLICT REPLACE";
}

- (void)prepareStatement {

    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject {

    NSString * sql = [NSString stringWithFormat:@"delete from warningMember where warningMemberId = '%@' and secWarningId = '%@'",_warningMemberId,_secWarningId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (NSUInteger)readMaxMemberSortNumWithSecWarningId:(NSString *)secWarningId {

     __block NSUInteger count = 0;
    NSString *sql = [NSString stringWithFormat:@"select max(memberSortNum) as max from warningMember where secWarningId = '%@' and delFlag = 0",secWarningId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        count = [rs intForColumn:@"max"];
    });
    return  count;
}

+ (NSUInteger)readMemberCountWithSecWarningId:(NSString *)secWarningId {

    __block NSUInteger count = 0;
    NSString *sql = [NSString stringWithFormat:@"select count() as count from warningMember where secWarningId = '%@' and delFlag = 0",secWarningId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        count = [rs intForColumn:@"count"];
    });
    return  count;
}

+ (NSMutableArray *)readTableWithSecWarningId:(NSString *)secWarningId {

    NSMutableArray *array = [NSMutableArray new];
    NSString *sql = [NSString stringWithFormat:@"select * from warningMember where secWarningId = '%@' and delFlag = 0 order by memberSortNum asc", secWarningId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMWarningMemberModel *model = [HMWarningMemberModel object:rs];
        [array addObject:model];
    });

    return  [self deleteArraytoFiveCount:array];
}

+ (NSMutableArray *)deleteArraytoFiveCount:(NSMutableArray *)array {
    while (array.count > 5) {
        [array removeLastObject];
        [self deleteArraytoFiveCount:array];
    }
    return array;
}

+ (BOOL)existMemberWithWarningMemberId:(NSString *)memberId {

    NSString *sql = [NSString stringWithFormat:@"select * from warningMember where warningMemberId = '%@' and delFlag = 0", memberId];
    __block BOOL exist = NO;
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMWarningMemberModel *model = [HMWarningMemberModel object:rs];
        if (model) {
            exist = YES;
        }
    });
    return exist;
}



@end
