//
//  HMBaseModel+Extension.h
//  HomeMateSDK
//
//  Created by Air on 2017/6/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"
#import "FMDatabase.h"

NSDictionary * column(char *name,char *type);
NSDictionary * column_constrains(char *name,char *type,char*constrains);

@interface HMBaseModel (Extension)

+ (NSString*)createTableString;

/** 插入数据库前调用，在此方法中应将值异常的字段重新赋值 */
- (void)prepareStatement;

-(BOOL)insertModel:(FMDatabase *)db;

/**返回当前表的所有字段*/
+ (NSArray<NSDictionary *>*)columns;
+ (NSArray<NSString *>*)columnNames;
/**返回当前表的约束信息*/
+ (NSString*)constrains;

/**不改版本号的情况下，新增的一个column*/
+ (NSArray<NSDictionary *>*)newColumns;

@end
