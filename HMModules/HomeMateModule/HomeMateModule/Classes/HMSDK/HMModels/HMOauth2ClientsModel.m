//
//  HMOauth2ClientsModel.m
//  HomeMateSDK
//
//  Created by orvibo on 2019/9/29.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMOauth2ClientsModel.h"
#import "HMConstant.h"


@implementation HMOauth2ClientsModel
+ (NSString *)tableName {
    
    return @"oauth2Clients";
}

+ (NSArray*)columns
{
    return @[
             column("userId","text"),
             column("familyId","text"),
             column("clientId","text"),
             column("skillName","text"),
             column("logoUrl","text"),
             column("skillNo","integer"),
             column("flag","integer"),
             
             column("loginArgUrl","text"),
             column("skillProfile","text"),
             column("company","integer"),
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (userId,familyId,clientId) ON CONFLICT REPLACE";
}
- (void)prepareStatement
{
    if (!self.userId) {
        self.userId = userAccout().userId;
    }
    
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
    self.skillName = self.skillName ?:@"";
    self.loginArgUrl = self.loginArgUrl ?:@"";
    self.logoUrl = self.logoUrl ?:@"";
    self.skillProfile = self.skillProfile ?:@"";
    self.company = self.company ?:@"";
}

- (NSString *)updateStatement
{
    /**
     如果字段没有数据，则使用旧数据
     */
    [self prepareStatement];
    NSString * sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO oauth2Clients "
                      "SELECT '%@' AS userId,'%@' as familyId,'%@' AS clientId,'%@' AS skillName,'%@' AS logoUrl,%d AS skillNo,%d AS flag"
                      ",CASE _loginArgUrl  WHEN '' THEN loginArgUrl ELSE _loginArgUrl end as loginArgUrl"
                      ",CASE _skillProfile  WHEN '' THEN skillProfile ELSE _skillProfile end as skillProfile"
                      ",CASE _company  WHEN '' THEN company ELSE _company end as company"
                      " from ("
                      "SELECT * FROM (SELECT '%@' AS _clientId,'%@' AS _loginArgUrl,'%@' AS _skillProfile,'%@' AS _company) AS newdata "
                      "LEFT JOIN oauth2Clients AS olddata ON newdata._clientId = olddata.clientId"
                      ")"
                      ,self.userId,self.familyId,self.clientId,self.skillName,self.logoUrl,self.skillNo,self.flag,self.clientId,self.loginArgUrl,self.skillProfile,self.company];
    return sql;
}
-(void)setInsertWithDb:(FMDatabase *)db{
    [self insertModel:db];
}
-(BOOL)insertModel:(FMDatabase *)db{
    return [db executeUpdate:self.sql]; // self.sql == [self updateStatement]
}
- (BOOL)insertObject{
    return [self executeUpdate:self.sql]; // self.sql == [self updateStatement]
}
@end
