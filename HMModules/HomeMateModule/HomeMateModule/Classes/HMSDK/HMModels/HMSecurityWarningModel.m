//
//  HMSecurityWarningModel.m
//  HomeMate
//
//  Created by orvibo on 16/6/30.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMSecurityWarningModel.h"
#import "HMConstant.h"


@implementation HMSecurityWarningModel


+ (NSString *)tableName {

    return @"securityWarning";
}


+ (NSArray*)columns
{
    return @[
             column("secWarningId","text"),
             column("familyId","text"),
             column("userId","text"),
             column("securityId","text"),
             column("warningType","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (secWarningId) ON CONFLICT REPLACE";
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

    NSString *sql = [NSString stringWithFormat:@"delete from securityWarning where secWarningId = '%@'",self.secWarningId];
    return [self executeUpdate:sql];
}

+ (HMSecurityWarningModel *)readTableWithSecurityId:(NSString *)securityId {

    __block HMSecurityWarningModel *model;
    NSString *sql = [NSString stringWithFormat:@"select * from securityWarning where securityId = '%@' and delFlag = 0 order by updateTime asc",securityId];
    queryDatabase(sql, ^(FMResultSet *rs) {
        model = [HMSecurityWarningModel object:rs];
    });
    return model;
}


@end
