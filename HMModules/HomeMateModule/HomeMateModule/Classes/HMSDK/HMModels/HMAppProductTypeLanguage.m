//
//  HMAppProductTypeLanguage.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/4/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppProductTypeLanguage.h"
#import "HMBaseModel+Extension.h"

@implementation HMAppProductTypeLanguage

+ (NSString *)tableName {
    return @"appProductTypeLanguage";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("id","text","UNIQUE ON CONFLICT REPLACE"),
             column("productNameId","text"),
             column("language","text"),
             column("productName","text"),
             column("productType","text"),
             column("preProductType","text"),
             column("level","integer"),
             column("deviceType","text"),
             column("manualUrl","text"),
             column("updateTime","text"),
             column("createTime","text"),
             column("delFlag","integer")
             ];
}
/**不改版本号的情况下，新增的一个column*/
+ (NSArray<NSDictionary *>*)newColumns {
    return @[column("manualUrl","text")];
}
-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

@end
