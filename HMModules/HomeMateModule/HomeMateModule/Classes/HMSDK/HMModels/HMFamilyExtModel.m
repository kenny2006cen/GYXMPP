//
//  HMFamilyExtModel.m
//  HomeMateSDK
//
//  Created by peanut on 2017/5/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMFamilyExtModel.h"
#import "HMFamily.h"
#import "HMConstant.h"

@implementation HMFamilyExtModel

+ (NSString *)tableName {
    return @"familyExt";
}

+ (NSArray*)columns
{
    return @[column("userId","text"),
             column("familyId","text"),
             column("sequence","integer"),
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (userId, familyId) ON CONFLICT REPLACE";
}


-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject {
    NSString * sql = [NSString stringWithFormat:@"delete from familyExt where familyId = '%@' and userId = '%@'", self.familyId, self.userId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+(NSString *)sequenceTable
{
    return @"(select family.*,familyExt.sequence from family left JOIN  familyExt on family.userId = familyExt.userId and family.familyId = familyExt.familyId)";
}

+ (HMFamily *_Nullable)defaultFamily
{
    __block HMFamily *family;
    
    NSString * sql = [NSString stringWithFormat:@"select * from %@ where userId = '%@' order by sequence asc limit 1", [self sequenceTable],userAccout().userId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        family = [HMFamily object:rs];
    });
    return family;
}
+ (NSMutableArray<HMFamily *> *)readAllFamilys {
    
    NSMutableArray<HMFamily *> *familys = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where userId = '%@' order by sequence asc", [self sequenceTable],userAccout().userId];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMFamily *model = [HMFamily object:rs];
        [familys addObject:model];
    });
    return familys;
}

+ (instancetype)objectWithFamily:(HMFamily *)family sequence:(int)sequence
{
    HMFamilyExtModel *model = [[HMFamilyExtModel alloc]init];
    model.userId = family.userId;
    model.familyId = family.familyId;
    model.sequence = sequence;
    return model;
}
@end
