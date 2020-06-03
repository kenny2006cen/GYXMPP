//
//  HMThemeModel.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2018/6/7.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMThemeModel.h"
#import "HMBaseModel+Extension.h"
#import "HMDatabaseManager.h"


@implementation HMThemeModel

+ (NSString *)tableName {
    
    return @"theme";
}

+ (NSArray*)columns
{
    return @[
             column("themeId","text"),
             column("deviceId","text"),
             column("themeType","integer"),
             column("nameType","integer"),
             column("speed","FLOAT"),
             column("angle","integer"),
             column("variation","integer"),
             column("color","text"),
             column("sequence","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

+ (NSString*)constrains
{
    return @"UNIQUE (themeId) ON CONFLICT REPLACE";
}

- (BOOL)deleteObject {
    
    NSString * sql = [NSString stringWithFormat:@"delete from familyInvite where themeId = '%@' ",self.themeId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

+ (HMThemeModel *)themeOfDeviceId:(NSString *)deviceId themeType:(int)themeType {
    NSString *sql = [NSString stringWithFormat:@"select * from theme where deviceId = '%@' and delFlag = 0 and themeType = %d",deviceId,themeType];
    __block HMThemeModel *theme = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        theme = [HMThemeModel object:rs];
    });
    return theme;
}

+ (NSMutableArray *)themesOfDeviceId:(NSString *)deviceId {
    NSMutableArray *themesArr = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from theme where deviceId = '%@' and delFlag = 0 order by nameType",deviceId];
    NSMutableArray *dynamicThemeArr = [NSMutableArray array]; // 动态主题
    NSMutableArray *staticThemeArr = [NSMutableArray array]; // 静态主题
    queryDatabase(sql, ^(FMResultSet *rs) {
        HMThemeModel *theme = [HMThemeModel object:rs];
        if (theme.nameType <= 6) {
            [dynamicThemeArr addObject:theme];
        }else {
            [staticThemeArr addObject:theme];
        }
    });
    if (dynamicThemeArr.count) {
        [themesArr addObject:dynamicThemeArr];
    }
    if (staticThemeArr.count) {
        [themesArr addObject:staticThemeArr];
    }
    return themesArr;
}

+ (HMThemeModel *)themeOfThemeId:(NSString *)themeId {
    NSString *sql = [NSString stringWithFormat:@"select * from theme where themeId = '%@' and delFlag = 0",themeId];
    __block HMThemeModel *theme = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        theme = [HMThemeModel object:rs];
    });
    return theme;
    
}

+ (HMThemeModel *)themeOfDeviceId:(NSString *)deviceId nameType:(int)nameType {
    NSString *sql = [NSString stringWithFormat:@"select * from theme where deviceId = '%@' and nameType = %d and delFlag = 0",deviceId,nameType];
    __block HMThemeModel *theme = nil;
    queryDatabase(sql, ^(FMResultSet *rs) {
        theme = [HMThemeModel object:rs];
    });
    return theme;
    
}



@end
