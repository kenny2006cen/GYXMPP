//
//  HMFamilyUsers.m
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMFamilyUsers.h"
#import "HMConstant.h"


@implementation HMFamilyUsers

+ (NSString *)tableName {
    
    return @"familyUsers";
}

+ (NSArray*)columns
{
    return @[
             column("familyUserId","text"),
             column("familyId","text"),
             column("userId","text"),
             column("userName","text"),
             column("phone","text"),
             column("email","text"),
             column("userType","integer"),
             column("nicknameInFamily","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (familyUserId) ON CONFLICT REPLACE";
}


- (void)prepareStatement {
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
    if (!self.updateTime) {
        self.updateTime = self.createTime;
    }
    if (!self.nicknameInFamily) {
        self.nicknameInFamily = @"";
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject {
    
    NSString * sql = [NSString stringWithFormat:@"delete from familyUsers where familyUserId = '%@' ",self.familyUserId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

-(NSString *)showName
{
    //1.若选择的是管理员本人：昵称-->手机号-->邮箱-->备注。
    if([self.userId isEqualToString:userAccout().userId]) {
        if(self.userName.length > 0) {
            return self.userName; // 昵称
        }else if(self.phone.length > 0) {
            return self.phone; // 手机号
        } else if(self.email.length > 0) {
            return self.email; // 邮箱
        }else if (self.nicknameInFamily.length > 0) {
            return self.nicknameInFamily; // 备注
        }
        
    }else {//2.选择的是剩余成员：显示顺序及显示规则同家庭管理-成员与权限中的成员显示，备注-->手机号-->邮箱-->昵称。
        if (self.nicknameInFamily.length > 0) {
            return self.nicknameInFamily; // 备注
        } else if(self.phone.length > 0) {
            return self.phone; // 手机号
        } else if(self.email.length > 0) {
            return self.email; // 邮箱
        } else if(self.userName.length > 0) {
            return self.userName; // 昵称
        }
    }
    return @"";
}

+ (NSMutableArray *)selectFamilyUsersByFamilyId:(NSString *)familyId{
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from familyUsers where familyId = '%@' and userId != '%@' and delFlag = 0 order by createTime asc",familyId, userAccout().userId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        HMFamilyUsers *user = [HMFamilyUsers object:rs];
        [array addObject:user];
    });
    
    return array;
    
}

+ (HMFamilyUsers *)selectUsersByUserId:(NSString *)userId {
   __block HMFamilyUsers *user = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from familyUsers where familyId = '%@' and userId = '%@' and delFlag = 0 order by createTime asc",userAccout().familyId, userId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        user = [HMFamilyUsers object:rs];
    });
    return user;
}

+ (NSMutableArray *)selectAllFamilyUsersByFamilyId:(NSString *)familyId {
    NSMutableArray *array = [NSMutableArray array];
    
  NSString *  sql = [NSString stringWithFormat:@"select * from familyUsers where familyId = '%@' and delFlag = 0 and userId = '%@' order by userType,createTime desc limit 1",familyId,userAccout().userId];//这里面有一个问题，不知道什么情况下会产生两条familyId、userid一样的数据，这个可以修改标的约束
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        HMFamilyUsers *user = [HMFamilyUsers object:rs];
        [array addObject:user];
    });
    
   sql = [NSString stringWithFormat:@"select * from familyUsers where familyId = '%@' and delFlag = 0 and userId != '%@' order by userType,createTime asc",familyId,userAccout().userId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        HMFamilyUsers *user = [HMFamilyUsers object:rs];
        [array addObject:user];
    });
    
    return array;
}

+ (BOOL)deleteFamilyUsersOfFamilyId:(NSString *)familyId {
    NSString *sql = [NSString stringWithFormat:@"delete from familyUsers where familyId = '%@'",familyId];
    BOOL result = [self executeUpdate:sql];
    return result;
}
+ (HMFamilyUsers *)defaultFamilyMember
{
    HMFamilyUsers *user = [self selectUsersByUserId:userAccout().userId];
    if (user) {
        return user;
    }
    
    return [self memberWithLoginAccout];
}

+(HMFamilyUsers *)memberWithLoginAccout
{
    HMFamilyUsers *user = [[HMFamilyUsers alloc]init];
    user.familyId = userAccout().familyId;
    user.userId = userAccout().userId;
    user.userName = userAccout().userName;
    user.phone = userAccout().phone;
    user.email = userAccout().email;
    user.nicknameInFamily = userAccout().userName;
    return user;
}

-(BOOL)isEqual:(HMFamilyUsers *)object
{
    if ([object isKindOfClass:[self class]]) {
        BOOL userIdEqual = [self.userId isEqualToString:object.userId];
        BOOL nameEqual = [self.showName isEqualToString:object.showName];
        return (userIdEqual && nameEqual);
    }
    return [super isEqual:object];
}

-(NSUInteger)hash
{
    return self.userId.hash;
}
@end
