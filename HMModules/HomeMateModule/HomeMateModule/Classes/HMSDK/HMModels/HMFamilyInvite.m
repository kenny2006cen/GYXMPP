//
//  HMFamilyInvite.m
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMFamilyInvite.h"
#import "HMConstant.h"

@implementation HMFamilyInvite

+ (NSString *)tableName {
    
    return @"familyInvite";
}

+ (NSArray*)columns
{
    return @[
             column("familyInviteId","text"),
             column("familyId","text"),
             column("sendUserId","text"),
             column("receiveUserId","text"),
             column("status","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (familyInviteId) ON CONFLICT REPLACE";
}

- (void)prepareStatement {
    
    if (!self.familyId) {
        self.familyId = userAccout().familyId;
    }
}

- (BOOL)deleteObject {
    
    NSString * sql = [NSString stringWithFormat:@"delete from familyInvite where familyInviteId = '%@' ",self.familyInviteId];
    BOOL result = [self executeUpdate:sql];
    return result;
}


@end
