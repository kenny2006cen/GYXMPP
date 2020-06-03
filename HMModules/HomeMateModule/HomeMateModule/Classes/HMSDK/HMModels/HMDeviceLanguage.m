//
//  DeviceLanguage.m
//  HomeMate
//
//  Created by liuzhicai on 16/1/13.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMDeviceLanguage.h"
#import "HMBaseModel+Extension.h"
#import "RunTimeLanguage.h"
#import "NSObject+MJKeyValue.h"
#import "HMUtil.h"

@implementation HMDeviceLanguage
+(NSString *)tableName
{
    return @"deviceLanguage";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("deviceLanguageId","text","UNIQUE ON CONFLICT REPLACE"),
             column("dataId","text"),
             column("language","text"),
             column("productName","text"),
             column("defaultName","text"),
             column("manufacturer","text"),
             column("stepInfo","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from deviceLanguage where deviceLanguageId = '%@'",self.deviceLanguageId];
    BOOL result =  [self executeUpdate:sql];
    return result;
}

+ (HMDeviceLanguage *)objectWithDataId:(NSString *)dataId
{
    return [self objectWithDataId:dataId sysLanguage:[RunTimeLanguage deviceLanguage]];
}

+ (NSString *)sqlWithDataId:(NSString *)dataId sysLanguage:(NSString *)sysLanguage
{
    return [NSString stringWithFormat:@"select * from deviceLanguage where dataId = '%@' and delFlag = 0 and language = '%@'",dataId,sysLanguage];
}

+ (HMDeviceLanguage *)objectWithDataId:(NSString *)dataId sysLanguage:(NSString *)sysLanguage
{
    NSString *sql = [self sqlWithDataId:dataId sysLanguage:sysLanguage];
    HMDeviceLanguage *model = nil;
    FMResultSet *set = [self executeQuery:sql];
    
    // 首先根据系统语言查询(如果地区性的语言包存在的话就以地区性的为准)
    if ([set next]) {
        model = [[self class] mj_objectWithKeyValues:[set resultDictionary]];
    }
    
    // 不存在的话就以这种语言的通用语言为准 eg:fr-CA 不存在，则以 fr 去查
    if (!model && [sysLanguage rangeOfString:@"-"].location != NSNotFound) {
        
        sql = [self sqlWithDataId:dataId sysLanguage:[[sysLanguage componentsSeparatedByString:@"-"] firstObject]];
        set = [self executeQuery:sql];
        if ([set next]) {
            model = [[self class] mj_objectWithKeyValues:[set resultDictionary]];
        }
    }
    
    // 都不存在，默认英文 （前提是系统语言非中文）
    if (!model && !CHinese) {
        
        sql = [self sqlWithDataId:dataId sysLanguage:@"en"];
        set = [self executeQuery:sql];
        if ([set next]) {
            model = [[self class] mj_objectWithKeyValues:[set resultDictionary]];
        }
    }
    
    // 都不存在, 默认中文
    if (!model) {
        sql = [self sqlWithDataId:dataId sysLanguage:@"zh"];
        set = [self executeQuery:sql];
        if ([set next]) {
            model = [[self class] mj_objectWithKeyValues:[set resultDictionary]];
        }

    }
    
    [set close];
    return model;

}

+ (instancetype)objectFromDictionary:(NSDictionary *)dict
{
    HMDeviceLanguage *obj = [[self class] mj_objectWithKeyValues:dict];
    return obj;
}

@end
