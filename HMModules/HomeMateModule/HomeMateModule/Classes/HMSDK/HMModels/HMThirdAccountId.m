//
//  HMThirdAccountId.m
//  HomeMate
//
//  Created by orvibo on 16/3/31.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMThirdAccountId.h"
#import "HMDatabaseManager.h"


@implementation HMThirdAccountId

+(NSString *)tableName
{
    return @"thirdAccount";
}

+ (NSArray*)columns
{
    return @[
             column("thirdAccountId","text"),
             column("userId","text"),
             column("thirdId","text"),
             column("thirdUserName","text"),
             column("token","text"),
             column("file","text"),
             column("userType","integer"),
             column("registerType","integer"),
             column("phone","text default ''"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (thirdAccountId) ON CONFLICT REPLACE";
}

+ (NSArray<NSDictionary *>*)newColumns {
    return  @[column("phone","text default ''")];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+ (NSString *)selectUserIdByThirdId:(NSString *)thirdId{
    __block NSString *userId ;
    NSString *sql = [NSString stringWithFormat:@"select userId from thirdAccount where thirdId = '%@' and delFlag = 0",thirdId];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        userId = [rs stringForColumn:@"userId"];
    });
    return userId;
}

+ (NSMutableArray *)selectRegisterTypeByUserId:(NSString *)userId{
    NSMutableArray *regiserArr = [NSMutableArray new];
    NSString *sql = [NSString stringWithFormat:@"select registerType from thirdAccount where userId = '%@' and delFlag = 0 order by updateTime asc",userId];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        [regiserArr addObject:@([rs intForColumn:@"registerType"])];
    });
    return regiserArr;
}

+ (NSMutableArray *)selectThirdAccountIdByUserId:(NSString *)userId{
    NSMutableArray *thirdAccount = [NSMutableArray new];
    NSString *sql = [NSString stringWithFormat:@"select * from thirdAccount where userId = '%@' and delFlag = 0 order by registerType asc",userId];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        [thirdAccount addObject:[HMThirdAccountId object:rs]];
    });
    return thirdAccount;
}


+ (NSString *)getUrlStringByUserId:(NSString *)userId{
    __block NSString *urlString ;
    NSString *sql = [NSString stringWithFormat:@"select file from thirdAccount where userId = '%@'and delFlag = 0",userId];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        urlString = [rs stringForColumn:@"file"];
    });
    return urlString;
}

+(HMThirdAccountId *)selectThirdAccountByUserId:(NSString *)userId AndRegiseterType:(int )registerType{
    __block HMThirdAccountId *thirdAccount ;

    NSString *sql = [NSString stringWithFormat:@"select * from thirdAccount where userId = '%@' and registerType = %d and delFlag = 0",userId,registerType];
    queryDatabase(sql, ^(FMResultSet *rs) {
        thirdAccount = [HMThirdAccountId object:rs];
    });
    return thirdAccount;
}

@end
