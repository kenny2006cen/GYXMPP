//
//  HMCustomNotificationAuthority.m
//  HomeMateSDK
//
//  Created by orvibo on 2018/9/5.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMAuthority.h"
#import "HMBaseModel+Extension.h"
#import "HMDatabaseManager.h"
#import "HMFamilyUsers.h"

@implementation HMAuthority

+(NSString *)tableName
{
    return @"authorityNew";
}

+ (NSArray*)columns
{
    return @[
             column("userId", "text"),
             column("familyId", "text"),
             column("objId", "text"),
             column("authorityType", "integer"),
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (userId,familyId,objId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


+(NSArray *)authorityWithObjectId:(NSString *)objId authorityType:(int)authorityType familyId:(NSString *)familyId
{
    NSMutableString *sql = [[NSMutableString alloc]init];
    // 查询指定的对象的特定权限类型的权限
    if (objId) {
        [sql appendFormat:@"select * from familyUsers where userId in (select DISTINCT userId from authorityNew where objId = '%@' and authorityType = %d and familyId = '%@') and familyId = '%@'",objId,authorityType,familyId,familyId];
    }else{
        // 查询指定的权限类型的所有对象的权限
        [sql appendFormat:@"select * from familyUsers where userId in (select DISTINCT userId from authorityNew where authorityType = %d and familyId = '%@')  and familyId = '%@'",authorityType,familyId,familyId];
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    queryDatabase(sql, ^(FMResultSet *rs) {
        [array addObject:[HMFamilyUsers object:rs]];
    });
    
    return array;
}

+(void)deleteAuthorityWithObjectId:(NSString *)objId authorityType:(int)authorityType familyId:(NSString *)familyId
{
    NSMutableString *sql = [[NSMutableString alloc]init];
    
    if (objId) {
        [sql appendFormat:@"delete from authorityNew where authorityType = %d and objId = '%@' and familyId = '%@'",authorityType,objId,familyId];
    }else{
        [sql appendFormat:@"delete from authorityNew where authorityType = %d and familyId = '%@'",authorityType,familyId];
    }
    
    executeUpdate(sql);
}

+(instancetype)authorityWithObjectId:(NSString *)objId authorityType:(int)authorityType familyId:(NSString *)familyId userId:(NSString *)userId{
    
    HMAuthority *authority = [[HMAuthority alloc]init];
    authority.userId = userId;
    authority.familyId = familyId;
    authority.objId = objId;
    authority.authorityType = authorityType;
    return authority;
}
@end
