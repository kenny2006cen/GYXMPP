//
//  HMDeviceBrand.m
//  HomeMateSDK
//
//  Created by peanut on 16/10/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMDeviceBrand.h"
#import "HMBaseModel+Extension.h"
#import "HMDatabaseManager.h"

@implementation HMDeviceBrand

+(NSString *)tableName
{
    return @"deviceBrand";
}

+ (NSArray*)columns
{
    return @[column("brandId","text"),
             column("brandType","integer"),
             column("deviceType","integer"),
             column("brandName","text"),
             column("language","text"),
             column("sequence","integer"),
             column("updateTimeSec","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (brandId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from deviceBrand where brandId = '%@' ",self.brandId];
    BOOL result = [[HMDatabaseManager shareDatabase] executeUpdate:sql];
    return result;
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:self.brandId forKey:@"brandId"];
    [dic setObject:[NSNumber numberWithInt:self.brandType] forKey:@"brandType"];
    [dic setObject:[NSNumber numberWithInt:self.deviceType] forKey:@"deviceType"];
    [dic setObject:self.brandName forKey:@"brandName"];
    [dic setObject:self.language forKey:@"language"];
    [dic setObject:[NSNumber numberWithInt:self.sequence] forKey:@"sequence"];
    [dic setObject:[NSNumber numberWithInt:self.updateTimeSec] forKey:@"updateTimeSec"];
    [dic setObject:self.createTime forKey:@"createTime"];
    [dic setObject:self.updateTime forKey:@"updateTime"];
    [dic setObject:[NSNumber numberWithInt:self.delFlag] forKey:@"delFlag"];
    
    return dic;
}

@end
