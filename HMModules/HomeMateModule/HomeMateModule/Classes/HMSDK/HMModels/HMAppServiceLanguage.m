//
//  HMAppServiceLanguage.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/12/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppServiceLanguage.h"
#import "HMBaseModel+Extension.h"

@implementation HMAppServiceLanguage

+ (NSString *)tableName {
    return @"appServiceLanguage";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("id","text","UNIQUE ON CONFLICT REPLACE"),
             column("serviceId","text"),  // appService表主键
             column("language","text"), // 多国语言选项
             column("name","text"), // 列表项名称
             column("delFlag","integer"),
             column("updateTime","text"),
             column("createTime","text")
             
             ];
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

@end
