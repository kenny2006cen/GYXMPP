//
//  HMDatabaseManager+Changed.m
//  HomeMateSDK
//
//  Created by 管理员 on 2017/6/25.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMDatabaseManager+Changed.h"
#import "HMConstant.h"

@implementation HMDatabaseManager (Changed)

+(BOOL)isTableColumnChaned
{
    NSMutableArray *tables = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select tbl_name from sqlite_master where [type] = 'table'"];
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        NSString *tableName = [rs stringForColumn:@"tbl_name"];
        
        if (tableName) {
            NSDictionary *dic = @{tableName : [self columnsWithTable:tableName]};
            if (dic) {
                [tables addObject:dic];
            }
        }
    });
    
    DLog(@"%@",tables);
    
    return YES;
}

+(NSArray *)columnsWithTable:(NSString *)tableName
{
    NSMutableArray *columns = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info('%@')",tableName];
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        NSString *column = [rs stringForColumn:@"name"];
        
        if (column) {
            [columns addObject:column];
        }
    });
    
    return columns;
}
@end
