//
//  VihomeStandardIRDevice.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMStandardIRDevice.h"

@implementation HMStandardIRDevice
+(NSString *)tableName
{
    return @"standardIrDevice";
}

+ (NSArray*)columns
{
    return @[
             column("irDeviceId","text"),
             column("uid","text"),
             column("company","text"),
             column("model","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (irDeviceId, uid) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from standardIrDevice where irDeviceId = '%@' and uid = '%@' and delFlag=0",self.irDeviceId,self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}


- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.irDeviceId forKey:@"irDeviceId"];
    [dic setObject:self.uid forKey:@"uid"];
    [dic setObject:self.company forKey:@"company"];
    [dic setObject:self.model forKey:@"model"];
    [dic setObject:self.updateTime forKey:@"updateTime"];
    [dic setObject:self.createTime forKey:@"createTime"];
    [dic setObject:[NSNumber numberWithInt:self.delFlag] forKey:@"delFlag"];
    
    return dic;
}

@end
