//
//  HMSecurity.m
//  HomeMate
//
//  Created by orvibo on 16/3/4.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMSecurity.h"
#import "HMConstant.h"

@implementation HMSecurity

+(NSString *)tableName
{
    return @"security";
}

+ (NSArray*)columns
{
    return @[
              column("securityId","text"),
              column("familyId","text"),
              column("name","text"),
              column("isArm","integer"),
              column("type","integer"),
              column("secType","integer"),
              column("isOccurred","integer"),
              column("createTime","text"),
              column("updateTime","text"),
              column("delFlag","integer")
              ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (securityId, familyId) ON CONFLICT REPLACE";
}


- (void)prepareStatement
{
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }
    
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


-(id)copyWithZone:(NSZone *)zone
{
    HMSecurity *security = [[HMSecurity alloc] init];
    security.securityId = self.securityId;
    security.name = self.name;
    security.isArm = self.isArm;
    security.type = self.type;
    security.secType = self.secType;
    security.delFlag = self.delFlag;
    security.updateTime = self.updateTime;
    security.createTime = self.createTime;
    security.isOccurred = self.isOccurred;
    return security;
}


+(NSArray *)allSecurityArray
{
    NSString *familyId = userAccout().familyId;
    __block NSMutableArray *securityArr;
    NSString *sql = [NSString stringWithFormat:@"select * from security where delFlag = 0 and familyId = '%@' order by secType desc, securityId asc",familyId];

    queryDatabase(sql, ^(FMResultSet *rs) {
        if (!securityArr) {
            securityArr = [[NSMutableArray alloc] init];
        }
        HMSecurity *security = [HMSecurity object:rs];
        [securityArr addObject:security];
    });
    return securityArr;
}

+ (NSString *)getSecurityWithSecType:(int)secType {
    __block NSString *securityId;
    NSString *sql = [NSString stringWithFormat:@"select securityId from security where delFlag = 0 and familyId = '%@' and secType = %d", userAccout().familyId, secType];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        securityId = [rs stringForColumn:@"securityId"];
    });
    return securityId;
}
@end

