//
//  HMBaseModel+Extension.m
//  HomeMateSDK
//
//  Created by Air on 2017/6/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"
#import "HMTypes.h"
#import "HMConstant.h"

static BOOL hm_executeUpdate(FMDatabase *db,NSString *sql,NSUInteger columnsCount,id (^v)(NSUInteger i));
static NSString *hm_placeholderWithColumnsCount(NSUInteger columnsCount);
static NSString *hm_columnsString(NSArray *columns);

@implementation HMBaseModel (Extension)

+ (NSArray<NSDictionary *>*)columns
{
    [NSException raise:@"异常信息" format:@"子类必须自己实现此方法"];
    return nil;;
}

+ (NSString*)constrains
{
    return nil;
}


+ (NSString*)createTableString
{
    if ([self constrains]) {
        return [NSString stringWithFormat:@"CREATE TABLE if not exists %@ (%@,%@)"
                ,[self tableName],hm_columnsString([self columns]),[self constrains]];
    }
    return [NSString stringWithFormat:@"CREATE TABLE if not exists %@ (%@)",[self tableName],hm_columnsString([self columns])];
}


+ (NSArray<NSString *>*)columnNames
{
    return [[self columns]valueForKey:@"name"];
}

+ (NSArray<NSDictionary *>*)newColumns
{
    return nil;
}

- (void)prepareStatement
{
    //DLog(@"prepareStatement");
}

-(BOOL)insertModel:(FMDatabase *)db
{
    NSArray *columnNames = [[self class]columnNames]; // 字段名数组
    
    NSUInteger columnsCount = columnNames.count;
    if (columnsCount > 0) {
        
        [self prepareStatement];
        
        NSString *tableName = [[self class] tableName];// 表名
        
        NSString *columns = [columnNames componentsJoinedByString:@","]; // 字段名
        
        NSString *placeholders = hm_placeholderWithColumnsCount(columnsCount); // 占位符
        
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)",tableName,columns,placeholders]; // 带占位符的sql语句
        
        return hm_executeUpdate(db, sql, columnsCount, ^id(NSUInteger i) {
            
            return [self valueForKey:columnNames[i]]?:@"";
            
        });
    }
    
    DLog(@"表字段数量为 0");
    return NO;
}


@end


NSDictionary * column(char *name,char *type)
{
    if (name && type) {
        return @{@"name":[NSString stringWithUTF8String:name]
                 ,@"type":[NSString stringWithUTF8String:type]};
    }
    return @{};
}

NSDictionary * column_constrains(char *name,char *type,char*constrains)
{
    if (name && type && constrains) {
        return @{@"name":[NSString stringWithUTF8String:name]
                 ,@"type":[NSString stringWithUTF8String:type]
                 ,@"constrains":[NSString stringWithUTF8String:constrains]};
    }
    
    if (!constrains) {
        return column(name, type);
    }
    return @{};
}

static NSString *hm_columnsString(NSArray *columns)
{
    NSMutableString *columnString = [NSMutableString string];
    
    for (NSDictionary* dic in columns) {
        
        NSString *name = dic[@"name"];
        NSString *type = dic[@"type"];
        NSString *constrains = dic[@"constrains"];
        if (constrains) {
            [columnString appendFormat:@"%@ %@ %@,",name,type,constrains];
        }else{
            [columnString appendFormat:@"%@ %@,",name,type];
        }
    }
    
    if ([columnString hasSuffix:@","]) {
        return [columnString substringToIndex:columnString.length - 1];
    }
    return columnString;
}

static NSString *hm_placeholderWithColumnsCount(NSUInteger columnsCount)
{
    NSMutableString *placeholder = [NSMutableString string];
    
    for (int i = 0; i < columnsCount; i ++) {
        
        [placeholder appendString:@"?,"];
    }
    if ([placeholder hasSuffix:@","]) {
        [placeholder setString:[placeholder substringToIndex:placeholder.length - 1]];
    }
    return placeholder;
}

static BOOL hm_executeUpdate(FMDatabase *db,NSString *sql,NSUInteger columnsCount,id (^v)(NSUInteger i))
{
    if (1 == columnsCount) {
        return [db executeUpdate:sql,v(0)];
    }else if (2 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1)];
    }else if (3 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2)];
    }else if (4 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3)];
    }else if (5 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4)];
    }else if (6 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5)];
    }else if (7 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6)];
    }else if (8 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7)];
    }else if (9 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8)];
    }else if (10 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9)];
    }else if (11 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10)];
    }else if (12 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11)];
    }else if (13 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12)];
    }else if (14 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13)];
    }else if (15 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14)];
    }else if (16 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15)];
    }else if (17 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16)];
    }else if (18 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17)];
    }else if (19 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18)];
    }else if (20 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19)];
    }else if (21 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20)];
    }else if (22 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21)];
    }else if (23 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22)];
    }else if (24 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23)];
    }else if (25 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23),v(24)];
    }else if (26 == columnsCount){
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23),v(24),v(25)];
    }else if (27 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23),v(24),v(25),v(26)];
    }else if (28 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23),v(24),v(25),v(26),v(27)];
    }else if (29 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23),v(24),v(25),v(26),v(27),v(28)];
    }else if (30 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23),v(24),v(25),v(26),v(27),v(28),v(29)];
    }else if (31 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23),v(24),v(25),v(26),v(27),v(28),v(29),v(30)];
    }else if (32 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23),v(24),v(25),v(26),v(27),v(28),v(29),v(30),v(31)];
    }else if (33 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23),v(24),v(25),v(26),v(27),v(28),v(29),v(30),v(31),v(32)];
    }else if (34 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23),v(24),v(25),v(26),v(27),v(28),v(29),v(30),v(31),v(32),v(33)];
    }else if (35 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23),v(24),v(25),v(26),v(27),v(28),v(29),v(30),v(31),v(32),v(33),v(34)];
    }else if (36 == columnsCount) {
        return [db executeUpdate:sql,v(0),v(1),v(2),v(3),v(4),v(5),v(6),v(7),v(8),v(9),v(10),v(11),v(12),v(13),v(14),v(15),v(16),v(17),v(18),v(19),v(20),v(21),v(22),v(23),v(24),v(25),v(26),v(27),v(28),v(29),v(30),v(31),v(32),v(33),v(34),v(35)];
    }else{
        DLog(@"字段过多，尚未定义");
    }
    return NO;
}
