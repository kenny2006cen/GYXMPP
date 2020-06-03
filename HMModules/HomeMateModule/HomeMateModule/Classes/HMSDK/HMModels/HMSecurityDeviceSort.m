//
//  HMSecurityDeviceSort.m
//  HomeMateSDK
//
//  Created by Feng on 2017/12/11.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMSecurityDeviceSort.h"

@implementation HMSecurityDeviceSort

+(NSString *)tableName
{
    return @"securityDeviceSort";
}

+ (NSArray*)columns
{
    return @[column("sortUserId","text"),
             column("sortFamilyId","text"),
             column("sortDeviceId","text"),
             column("sortTime","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE(sortUserId, sortFamilyId, sortDeviceId) ON CONFLICT REPLACE";
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from securityDeviceSort where sortUserId = '%@' and sortFamilyId = '%@' and sortDeviceId = '%@'",self.sortUserId, self.sortFamilyId, self.sortDeviceId];
    BOOL result =  [self executeUpdate:sql];
    return result;
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

@end
