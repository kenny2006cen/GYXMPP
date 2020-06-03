//
//  VersionModel.m
//  HomeMate
//
//  Created by Air on 15/8/25.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMVersionModel.h"
#import "HMTypes.h"
#import "HMConstant.h"

@implementation HMVersionModel
+(NSString *)tableName
{
    return @"dbVersion";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("versionId","integer","UNIQUE ON CONFLICT REPLACE DEFAULT 1"),
             column("dbVersion","text"),
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}


+ (BOOL)saveCurrentDbVersion
{
    NSString * sql = [NSString stringWithFormat:@"insert into dbVersion (dbVersion) "
                      "values('%@')",kDbVersion];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (HMVersionModel *)oldVersion
{
    // 如果版本号表不存在，则返回当前最新版本
    if (![[HMDatabaseManager shareDatabase]tableExists:[self tableName]]) {
        
        // 表不存在，则先创建表
        [[self class]createTable];
        
        HMVersionModel * ver = [[HMVersionModel alloc]init];
        ver.dbVersion = kDbVersion;
        [ver insertObject];
        
        return ver;
    }
    
    NSString * sql = [NSString stringWithFormat:@"select dbVersion from dbVersion where versionId = 1"];
    
    FMResultSet * rs = [[HMDatabaseManager shareDatabase]executeQuery:sql];
    if ([rs next]) {
        HMVersionModel *version = [HMVersionModel object:rs];
        [rs close];
        return version;
    }else{
        HMVersionModel * ver = [[HMVersionModel alloc]init];
        ver.dbVersion = kDbVersion;
        return ver;
    }
}

- (NSString *)updateStatement
{
    NSString * sql = [NSString stringWithFormat:@"insert into dbVersion (versionId,dbVersion) "
                      "values(1,'%@')",self.dbVersion];
    return sql;
}
- (BOOL)insertObject
{
    NSString * sql = [self updateStatement];
    BOOL result = [self executeUpdate:sql];
    return result;
}

-(BOOL)insertModel:(FMDatabase *)db
{
    NSString * sql = [self updateStatement];
    BOOL result = [db executeUpdate:sql];
    return result;
}


- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from dbVersion where dbVersion = '%@'",self.dbVersion];
    BOOL result = [self executeUpdate:sql];
    return result;
}


@end
