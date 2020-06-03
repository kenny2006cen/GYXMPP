//
//  HMAppMyCenterLanguage.m
//  HomeMateSDK
//
//  Created by liqiang on 17/5/10.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppMyCenterLanguage.h"
#import "HMBaseModel+Extension.h"

@implementation HMAppMyCenterLanguage
+ (NSString *)tableName {
    return @"appMyCenterLanguage";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("id","text","UNIQUE ON CONFLICT REPLACE"),
             column("myCenterId","text"),
             column("language","text"),
             column("name","text"),
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
