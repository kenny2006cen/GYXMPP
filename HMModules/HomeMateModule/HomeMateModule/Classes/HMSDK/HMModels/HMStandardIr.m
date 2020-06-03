//
//  VihomeStandardIR.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMStandardIr.h"

@implementation HMStandardIr
+(NSString *)tableName
{
    return @"standardIr";
}

+ (NSArray*)columns
{
    return @[
             column("standardIrId","text"),
             column("uid","text"),
             column("irDeviceId","text"),
             column("bindOrder","text"),
             column("ir","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}


+ (NSString*)constrains
{
    return @"UNIQUE (standardIrId, uid) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from standardIr where standardIrId = '%@' and uid = '%@'",self.standardIrId,self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}


- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:self.standardIrId forKey:@"standardIrId"];
    [dic setObject:self.uid forKey:@"uid"];
    [dic setObject:self.irDeviceId forKey:@"irDeviceId"];
    [dic setObject:self.bindOrder forKey:@"order"];
    [dic setObject:self.ir forKey:@"ir"];
    [dic setObject:self.updateTime forKey:@"updateTime"];
    [dic setObject:[NSNumber numberWithInt:self.delFlag] forKey:@"delFlag"];
    
    return dic;
}

@end
