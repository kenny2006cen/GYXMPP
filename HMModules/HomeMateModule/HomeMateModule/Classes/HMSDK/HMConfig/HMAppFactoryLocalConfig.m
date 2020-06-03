//
//  HMAppFactoryLocalConfig.m
//  HomeMateSDK
//
//  Created by liqiang on 17/5/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppFactoryLocalConfig.h"
#import "HMConstant.h"

@implementation HMAppFactoryLocalConfig

// 内置数据版本号，默认从1.0开始，如果内置数据有更新则更改此版本号
+(NSString *)appFactoryInAppVersion
{
    return @"v4.4.0.301";
}
// 数据库中数据的版本号
+(NSString *)appFactoryInDbVersion
{
    NSString * sql = [NSString stringWithFormat:@"select dbVersion from dbVersion where versionId = 3"];
    
    FMResultSet * rs = [[HMDatabaseManager shareDatabase]executeQuery:sql];
    if ([rs next]) {
        
        NSString *version = [rs stringForColumn:@"dbVersion"];
        
        [rs close];
        
        return version;
    }
    [rs close];
    
    return nil;
}
+(NSArray *)localConfigSQL
{
    NSString *localDescSQL = [[[self class]createTableSQL]stringByAppendingString:[[self class]tableContentSQL]];
    NSArray *SQLs = [localDescSQL componentsSeparatedByString:@";"];
    return SQLs;
}

+(BOOL)localConfigDataChange {
    LogFuncName();
    
    NSString *dataInAppVersion = [[self class]appFactoryInAppVersion];
    NSString *dataInDbVersion = [[self class]appFactoryInDbVersion];
    
    BOOL changed = ![dataInAppVersion isEqualToString:dataInDbVersion];
    
    DLog(@"appfactory dataInAppVersion = %@ appfactory dataInDbVersion = %@ %@",dataInAppVersion,dataInDbVersion,changed ? @"appfactory版本号发生变化":@"appfactory版本号未发生变化");
    return changed;
}


+(NSString *)createTableSQL
{
    return[NSString stringWithFormat:@""
           
           "DELETE FROM appNaviTab;"
           "DELETE FROM appNaviTabLanguage;"
           "DELETE FROM appProductType;"
           "DELETE FROM appProductTypeLanguage;"
           "DELETE FROM appSetting;"
           "DELETE FROM appSettingLanguage;"
           "DELETE FROM appMyCenter;"
           "DELETE FROM appMyCenterLanguage;"
           "DELETE FROM appService;"
           "DELETE FROM appServiceLanguage;"
           "INSERT INTO dbVersion (versionId,dbVersion) values (3,'%@');"//内置app工厂数据的版本号id为3
           ,[[self class]appFactoryInAppVersion]];
}
+ (NSString *)tableContentSQL {
   __unused NSString * path = [[NSBundle mainBundle] pathForResource:@"HMAPPFactoryDefaultSetting" ofType:@"sql"];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        
        NSString * sourceString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray * sourceArray = [sourceString componentsSeparatedByString:@";"];
        NSMutableArray * desArray = [NSMutableArray array];
        [sourceArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj = [obj stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            obj = [obj stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            obj = [obj stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            [desArray addObject:obj];
        }];
        NSString * desString = [desArray componentsJoinedByString:@";"];
        if (desString.length) {
            return desString;
        }
    }
    
    return @"";
}


@end
