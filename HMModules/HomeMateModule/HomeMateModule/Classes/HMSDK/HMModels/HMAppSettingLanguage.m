//
//  HMAppSettingLanguage.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/4/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppSettingLanguage.h"
#import "HMBaseModel+Extension.h"


@implementation HMAppSettingLanguage

+ (NSString *)tableName {
    return @"appSettingLanguage";
}

+ (NSArray*)columns
{
    return @[
             column_constrains("id","text","UNIQUE ON CONFLICT REPLACE"),
             column("factoryId","text"),
             column("language","text"),
             column("companyName","text"),
             column("companyContact","text"),
             column("companyTel","text"),
             column("companyMail","text"),
             column("emailCtx","text"),
             column("smsCtx","text"),
             column("appName","text"),
             column("shopName","text"),
             column("startTxt","text"),
             column("agreementUrl","text"),
             column("privacyUrl","text"),
             column("shopUrl","text"),
             column("adviceUrl","text"),
             column("sourceUrl","text"),
             column("updateHistoryUrl","text"),
             column("updateTime","text"),
             column("createTime","text"),
             column("delFlag","integer")
             ];
}
+ (NSArray<NSDictionary *>*)newColumns {
    return @[column("privacyUrl","text")];
}
-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

@end
