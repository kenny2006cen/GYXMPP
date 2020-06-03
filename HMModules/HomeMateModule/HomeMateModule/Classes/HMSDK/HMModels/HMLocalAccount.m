//
//  LocalAccount.m
//  HomeMate
//
//  Created by Air on 15/8/11.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMLocalAccount.h"
#import "HMConstant.h"

@implementation HMLocalAccount

+(NSString *)tableName
{
    return @"localAccount";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("userId","text","PRIMARY KEY ON CONFLICT REPLACE"),
             column("token","text"),
             column("areaCode", "text"),
             column("loginTime","Integer"),
             column("compatibleUserName","text"),
             column_constrains("lastUserName","text","UNIQUE ON CONFLICT REPLACE"),
             column("password","text")
             ];
}
/**不改版本号的情况下，新增的一个column*/
+ (NSArray<NSDictionary *>*)newColumns {
    return @[column("token","text"),column("areaCode", "text")];
}

- (void)prepareStatement
{
    NSString *maxLoginTimeSql = @"select max(loginTime) from localAccount";
    __block int loginTime = 0;
    queryDatabase(maxLoginTimeSql, ^(FMResultSet *rs) {
        loginTime = [rs intForColumn:@"max(loginTime)"];
    });
    if (self.loginTime <= loginTime) {
        self.loginTime = loginTime + 1;
    }
    
    self.compatibleUserName = @"";
    if (self.lastUserName.length == 32) {
        
        NSString *displayName = [self displayNameWithColumn:@"lastUserName"];
        if (displayName) {
            self.compatibleUserName = displayName;
        }else{
            displayName = [self displayNameWithColumn:@"compatibleUserName"];
            if (displayName) {
                self.compatibleUserName = displayName;
            }
        }
        
    }else{
        self.compatibleUserName = self.lastUserName;
    }
}


-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from localAccount where userId = '%@'",self.userId];
    BOOL result = [self executeUpdate:sql];
    return result;
}


- (NSString *)displayNameWithColumn:(NSString *)column
{
    __block NSString *displayName = nil;
    NSString *selSql = [NSString stringWithFormat:@"select %@ from localAccount where userId = '%@'", column, self.userId];
    queryDatabase(selSql, ^(FMResultSet *rs) {
        NSString *name = [rs stringForColumn:column];
        if (name.length != 32 && name.length > 0) {
            displayName = name;
        }
    });
    return displayName;
}



+ (NSArray *)getAllAccountsBySort:(NSString *)sort
{
    NSMutableArray *arr;
    NSString *sql = [NSString stringWithFormat:@"select * from localAccount order by rowid %@", sort];
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        if (!arr) {
            arr = [[NSMutableArray alloc] initWithCapacity:1];
        }
        
        HMLocalAccount *obj = [HMLocalAccount object:rs];
        [arr addObject:obj];
    }
    [rs close];
    return arr;

}

+ (NSArray *)getAllLocalAccountArr
{
    return [self getAllAccountsBySort:@"desc"];
}

+ (NSArray *)getAllFilteredLocalAccountArr
{
    NSMutableArray *arr;
    NSString *sql = [NSString stringWithFormat:@"select * from localAccount where length(compatibleUserName) > 0 and length(password) > 0 and length(compatibleUserName) != 32 order by rowid desc"];
    FMResultSet *rs = [self executeQuery:sql];
    while ([rs next]) {
        if (!arr) {
            arr = [[NSMutableArray alloc] initWithCapacity:1];
        }
        HMLocalAccount *obj = [HMLocalAccount object:rs];
        [arr addObject:obj];
    }
    [rs close];
    return arr;
}

+ (HMLocalAccount *)lastAccountInfo
{
    NSString *sql = [NSString stringWithFormat:@"select * from localAccount where loginTime = (select max(loginTime) from localAccount)"];
    FMResultSet *resultSet = [self executeQuery:sql];
    HMLocalAccount *obj = nil;
    if ([resultSet next]) {
        obj = [HMLocalAccount object:resultSet];
    }
    
    [resultSet close];
    
    return obj;
}

+(BOOL)updateEmail:(NSString *)email
{
    HMLocalAccount *account = [HMLocalAccount lastAccountInfo];
    BOOL isUpdate = NO;
    if ([account.lastUserName rangeOfString:@"@"].location != NSNotFound) {
        isUpdate = YES;
        userAccout().currentUserName = email;//重新绑定了邮箱、手机号之后，_currentUserName要重新复制
    }
    if (isUpdate) {
        NSString *sql = [NSString stringWithFormat:@"update localAccount set lastUserName = '%@',compatibleUserName = '%@' where userId = '%@'",email,email,account.userId];
        BOOL result = [self executeUpdate:sql] && [HMAccount updateEmail:email];
        return result;
    }
    return NO;
}

/// 更新国家区号
/// @param areaCode 国家区号
+(BOOL)updateAreaCode:(NSString *)areaCode {
    HMLocalAccount *account = [HMLocalAccount lastAccountInfo];
    NSString *sql = [NSString stringWithFormat:@"update localAccount set areaCode = '%@' where userId = '%@'",areaCode,account.userId];
    BOOL result = [self executeUpdate:sql];
    return result;
}


+(BOOL)updatePhone:(NSString *)phone
{
    HMLocalAccount *account = [HMLocalAccount lastAccountInfo];
    BOOL isUpdate = NO;
    if ([account.lastUserName rangeOfString:@"@"].location == NSNotFound) {
        isUpdate = YES;
        userAccout().currentUserName = phone;//重新绑定了邮箱、手机号之后，_currentUserName要重新复制
    }
    if (isUpdate) {
        NSString *sql = [NSString stringWithFormat:@"update localAccount set lastUserName = '%@',compatibleUserName = '%@' where userId = '%@'",phone,phone,account.userId];
        BOOL result = [self executeUpdate:sql] && [HMAccount updatePhone:phone];
        return result;
    }
    return NO;
}

+(BOOL)updatePassword:(NSString *)password
{
    NSString *userId = userAccout().userId;
    NSString *sql = [NSString stringWithFormat:@"update localAccount set password = '%@' where userId = '%@'",password,userId];
    BOOL result = [self executeUpdate:sql];
    
    return result && [HMAccount updatePasswordNew:password];
}

+ (instancetype)objectWithUserName:(NSString *)name
{
    __block HMLocalAccount *localAccount = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from localAccount where lastUserName = '%@' or compatibleUserName = '%@'",name, name];
    queryDatabaseStop(sql, ^(FMResultSet *rs, BOOL *stop) {
        localAccount = [HMLocalAccount object:rs];
        *stop = YES;
    });
    return localAccount;
}
+ (instancetype)objectWithUserId:(NSString *)userId{
    __block HMLocalAccount *localAccount = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from localAccount where userId = '%@'",userId];
    queryDatabaseStop(sql, ^(FMResultSet *rs, BOOL *stop) {
        localAccount = [HMLocalAccount object:rs];
        *stop = YES;
    });
    return localAccount;
}

+(BOOL)removeTokenWithUserId:(NSString *)userId{
    NSString *sql = [NSString stringWithFormat:@"update localAccount set token = '' where userId = '%@'",userId];
    return [self executeUpdate:sql];
}
@end





