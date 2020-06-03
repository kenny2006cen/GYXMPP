//
//  HMAppService.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/12/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppService.h"
#import "HMBaseModel+Extension.h"

@implementation HMAppService

+ (NSString *)tableName {
    return @"appService";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("id","text","UNIQUE ON CONFLICT REPLACE"),
             column("factoryId","text"),  // 厂家ID
             column("name","text"), // 展示的列表名称
             column("groupId","text"), // 列表项分组ID
             column("groupIndex","integer"), // 列表项分组序号
             column("sequence","integer"), // 列表项组内排序序号
             column("verCode","integer"), // 创建列表项时版本号
             column("iconUrl","text"), // 列表项小图标链接地址:资源路径为IP+"/"+factoryId+"/"+"my"'
             column("viewId","text"), // 列表项跳转地址
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
