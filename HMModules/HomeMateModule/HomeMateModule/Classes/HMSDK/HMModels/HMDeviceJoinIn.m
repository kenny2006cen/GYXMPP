//
//  VihomeDeviceJoinIn.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMDeviceJoinIn.h"

@implementation HMDeviceJoinIn
+(NSString *)tableName
{
    return @"deviceJoinIn";
}

+ (NSArray*)columns
{
    return @[column("joinInId","text"),
             column("uid","text"),
             column("extAddr","text"),
             column("capabilities","integer"),
             column("activeType","integer"),
             column("endpointNum","integer"),
             column("actualNum","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (joinInId, uid) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from deviceJoinIn where joinInId = '%@' and uid = '%@'",self.joinInId,self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    return dic;
}


@end
