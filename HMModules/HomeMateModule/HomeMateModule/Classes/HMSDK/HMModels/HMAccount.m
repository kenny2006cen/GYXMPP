//
//  VihomeAccount.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAccount.h"
#import "HMConstant.h"


@interface HMAccount()

@property (nonatomic, retain)NSString *  province;

@end
@implementation HMAccount

+(NSString *)tableName
{
    return @"account";
}

+ (NSArray*)columns
{
    return @[column("userId", "text"),
             column("userName", "text"),
             column("password", "text"),
             column("phone", "text"),
             column("email", "text"),
             column("userType", "integer"),
             column("registerType", "integer"),
             column("idc", "integer"),
             column("country", "text"),
             column("state", "text"),
             column("city", "text"),
             column("fatherUserId", "text"),
             column("areaCode", "text"),
             column("passwordNew", "text"),
             column("createTime", "text"),
             column("updateTime", "text"),
             column("delFlag", "integer")
             ];
    
}
/**不改版本号的情况下，新增的一个column*/
+ (NSArray<NSDictionary *>*)newColumns {
    return @[column("areaCode", "text"),column("passwordNew", "text")];
}

+ (NSString*)constrains
{
    return @"UNIQUE(userId, fatherUserId) ON CONFLICT REPLACE";
}

- (void)prepareStatement
{
    if (!self.userId) {
        DLog(@"数据异常");
    }
    
    NSParameterAssert(self.userId);
    
    if (!self.fatherUserId) {
        self.fatherUserId = userAccout().userId;
    }
    
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }
    
    if (!self.state && self.province) {
        self.state = self.province;
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from account where userId = '%@'",self.userId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+(BOOL)deleteSubAccountUserId:(NSString *)subUserId fatherUserId:(NSString *)fatherUserId
{
    NSString *sql = [NSString stringWithFormat:@"delete from account where userId = '%@' and fatherUserId = '%@'",subUserId,fatherUserId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:self.userId forKey:@"userId"];
    [dic setObject:[self.userName lowercaseString] forKey:@"userName"];
    [dic setObject:self.password forKey:@"password"];
    [dic setObject:self.phone forKey:@"phone"];
    [dic setObject:self.email forKey:@"email"];
    [dic setObject:[NSNumber numberWithInt:self.userType] forKey:@"userType"];
    [dic setObject:[NSNumber numberWithInt:self.registerType] forKey:@"registerType"];
    [dic setObject:self.createTime forKey:@"createTime"];
    [dic setObject:self.updateTime forKey:@"updateTime"];
    [dic setObject:[NSNumber numberWithInt:self.delFlag] forKey:@"delFlag"];
    
    return dic;
}

+(BOOL)updateNickName:(NSString *)userName
{
    HMAccount *account = [HMAccount objectWithUserId:userAccout().userId];
    account.userName = userName;
   return [account insertObject];
}

+(BOOL)updateEmail:(NSString *)email
{
    NSString *userId = userAccout().currentLocalAccount.userId;
    NSString *sql = [NSString stringWithFormat:@"update account set email = '%@' where userId = '%@'",email.lowercaseString,userId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

/// 更新国家区号
/// @param areaCode 国家区号
+(BOOL)updateAreaCode:(NSString *)areaCode
{
    NSString *userId = userAccout().currentLocalAccount.userId;
    NSString *sql = [NSString stringWithFormat:@"update account set areaCode = '%@' where userId = '%@'",areaCode.lowercaseString,userId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+(BOOL)updatePhone:(NSString *)phone
{
    NSString *userId = userAccout().currentLocalAccount.userId;
    NSString *sql = [NSString stringWithFormat:@"update account set phone = '%@' where userId = '%@'",phone,userId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+(BOOL)updatePassword:(NSString *)password
{
    NSString *userId = userAccout().userId;
    NSString *sql = [NSString stringWithFormat:@"update account set password = '%@' where userId = '%@'",password,userId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+(BOOL)updatePasswordNew:(NSString *)password
{
    NSString *userId = userAccout().userId;
    NSString *sql = [NSString stringWithFormat:@"update account set passwordNew = '%@' where userId = '%@'",password,userId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+(NSString *)userIdWithName:(NSString *)name
{
    HMAccount *account = [HMAccount accountWithName:name];
    if (account) {
        return account.userId;
    }
    return @"-1";
}

+(HMAccount *)objectWithUserId:(NSString *)userId
{
    NSString *sql = [NSString stringWithFormat:@"select * from account where userId = '%@' and fatherUserId != '(null)' and delFlag = 0",userId];
    FMResultSet *rs = [self executeQuery:sql];
    HMAccount *account = nil;
    if ([rs next]) {
        account = [HMAccount object:rs];
    }
    [rs close];
    
    return account;
}
+(HMAccount *)accountWithPhoneNumber:(NSString *)phoneNumber areaCode:(NSString *)areaCode{
    
    NSString *sql = [NSString stringWithFormat:@"select * from account where phone = '%@' and areaCode = '%@' and fatherUserId = userId and delFlag = 0 order by updateTime desc",phoneNumber,areaCode];
    FMResultSet *rs = [self executeQuery:sql];
    if ([rs next]) {
        HMAccount *account = [HMAccount object:rs];
        
        [rs close];
        return account;
    }
    [rs close];
    return [self accountWithName:phoneNumber];
}

+(HMAccount *)accountWithName:(NSString *)name
{
    if (!name || [name isEqualToString:@""]) {
        return nil;
    }
    NSMutableString *sql = [NSMutableString string];
    // 手机号
    if (isPhoneNumber(name)) {
        [sql appendFormat:@"select * from account where phone = '%@' and fatherUserId = userId and delFlag = 0 order by updateTime desc",name];
        
    // 邮箱
    }else if (isValidString(name, @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}") || stringContainString(name,@"@")) {
        [sql appendFormat:@"select * from account where (email = '%@' or email = '%@') and fatherUserId = userId and delFlag = 0 order by updateTime desc",name.lowercaseString,name];
        
    }else{
        // 授权登录，userId
        [sql appendFormat:@"select * from account where (userId = '%@' or phone = '%@' or email = '%@') and fatherUserId = userId and delFlag = 0 order by updateTime desc",name,name,name];
    }
    
    
    
    FMResultSet *rs = [self executeQuery:sql];
    if ([rs next]) {
        HMAccount *account = [HMAccount object:rs];
        
        [rs close];
        return account;
    }
    
    [rs close];
    return nil;
}
/**
 *  返回家庭成员数组
 */
+(NSArray *)familyMemberArray
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *theUserId = userAccout().userId;
    
    NSString *sql = [NSString stringWithFormat:@"select * from account where "
                     "fatherUserId = '%@' and userId != '%@' and delFlag = 0 order by createTime desc",theUserId,theUserId];
    queryDatabase(sql, ^(FMResultSet *rs) {
       
        HMAccount *account = [HMAccount object:rs];
        [array addObject:account];
    });
    
    return array;
}
@end
