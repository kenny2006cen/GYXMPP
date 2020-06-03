//
//  HMAppNaviTabLanguage.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/4/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppNaviTabLanguage.h"

@implementation HMAppNaviTabLanguage


+ (NSString *)tableName {
    return @"appNaviTabLanguage";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("id","text","UNIQUE ON CONFLICT REPLACE"),
             column("naviTabId","text"),
             column("language","text"),
             column("naviName","text"),
             column("updateTime","text"),
             column("createTime","text"),
             column("delFlag","integer")
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

@end
