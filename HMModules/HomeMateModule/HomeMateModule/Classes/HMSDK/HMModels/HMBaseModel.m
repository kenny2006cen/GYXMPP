//
//  DBModel.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"
#import "HMConstant.h"
#import "HMDatabaseManager.h"
#import "NSObject+MJKeyValue.h"

@implementation HMBaseModel

+ (BOOL)createTable
{
    NSString *sql = [self createTableString];
    
    BOOL result = [self executeUpdate:sql];
    
    BOOL trigger = [self createTrigger];
    
    BOOL addColumn = [self addColumn];
    
    return result && trigger && addColumn;
    
}

+ (BOOL)createTrigger
{
    return YES;
}

+ (BOOL)addColumn
{
    for (NSDictionary *dic in [self newColumns]) {
        
        NSString *column = dic[@"name"];
        if (![self columnExists:column]) {
            
            NSString *type = dic[@"type"];
            NSString *addColumnSql = [NSString stringWithFormat:@"alter table %@ add column %@ %@",[self tableName],column,type];
            
            /*
            NSString *addColumnSql = @"alter table account add column idc integer default 0";
            NSString *addColumn_country = @"alter table account add column country text default ''";
            NSString *addColumn_state = @"alter table account add column state text default ''";
            NSString *addColumn_city = @"alter table account add column city text default ''";
            **/
            
            [self executeUpdate:addColumnSql];
        }
    }
    return YES;
}

-(NSString *)UID
{
    return [self.uid lowercaseString];
}

- (BOOL)insertObject
{
    return [self insertModel:[HMDatabaseManager shareDatabase].db];
}
- (BOOL)updateObject
{
    return [self insertObject];
}
- (BOOL)deleteObject
{
    [NSException raise:@"异常信息" format:@"子类需要自己实现此方法"];
    return YES;
}

+ (instancetype)object:(FMResultSet *)rs
{
    @try {
        
        NSDictionary *dict = [rs resultDictionary];
        HMBaseModel *obj = [[self class] mj_objectWithKeyValues:dict];
        return obj;
        
    } @catch (NSException *exception) {
        DLog(@"[%@ %@]发生了崩溃:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),exception);
    } @finally {
        
    }
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dict
{
    if ([dict.allKeys containsObject:@"order"]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dict];
        dic[@"bindOrder"] = dict[@"order"];
        
        HMBaseModel *obj = [[self class] mj_objectWithKeyValues:dic];
        return obj;
    }
    
    HMBaseModel *obj = [[self class] mj_objectWithKeyValues:dict];
    return obj;
}


-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"order"]) {
        
        [self setValue:value forKey:@"bindOrder"];
        
    }
    DLog(@"%s key : %@",__FUNCTION__,key);
}

-(id)valueForUndefinedKey:(NSString *)key
{
    
#if DEBUG
    [NSException raise:@"异常信息" format:@"缺少属性：%@",key];
#endif
    
    DLog(@"%s 未定义的 key : %@",__FUNCTION__,key);
    return nil;
}

+ (instancetype)objectFromUID:(NSString *)UID recordID:(NSString *)recordID
{
    return nil;
}

- (NSDictionary *)dictionaryFromObject
{
    return nil;
}

+(NSString *)tableName
{
    [NSException raise:@"异常信息" format:@"子类需要自己实现此方法"];
    return nil;
}
- (NSString *)updateStatement
{
    [self prepareStatement];
    return nil;
}

-(NSString *)sql
{
    if (!_sql) {
        _sql = [self updateStatement];
    }
    return _sql;
}
-(void)setInsertWithDb:(FMDatabase *)db
{
    if (![db executeUpdate:self.sql]) {
        DLog(@"DB Error: %@",self.sql);
    }
}

// 更新数据
- (BOOL)executeUpdate:(NSString*)sql, ...
{
    return [[HMDatabaseManager shareDatabase] executeUpdate:sql];
}
// 更新数据(可用?占位符)
- (BOOL)executeUpdateWithPlaceHolder:(NSString *)sql, ... {
    va_list args;
    va_start(args, sql);
    BOOL result = [[HMDatabaseManager shareDatabase] executeUpdate:sql withVAList:args];
    va_end(args);
    return result;
}

+ (BOOL)executeUpdate:(NSString*)sql, ...
{
    return [[HMDatabaseManager shareDatabase] executeUpdate:sql];
}

// 查询数据
- (FMResultSet *)executeQuery:(NSString*)sql, ...
{
    return [[HMDatabaseManager shareDatabase] executeQuery:sql];
}
+ (FMResultSet *)executeQuery:(NSString*)sql, ...
{
    return [[HMDatabaseManager shareDatabase] executeQuery:sql];
}

// 某个column是否存在
+ (BOOL)columnExists:(NSString*)columnName
{
    return [[HMDatabaseManager shareDatabase] columnExists:columnName inTableWithName:[self tableName]];
}

@end
