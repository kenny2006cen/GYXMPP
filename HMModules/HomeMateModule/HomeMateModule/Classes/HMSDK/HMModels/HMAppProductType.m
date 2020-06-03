//
//  HMAppProductType.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/4/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppProductType.h"
#import "HMConstant.h"

@implementation HMAppProductType

+ (NSString *)tableName {
    return @"appProductType";
}

+ (NSArray*)columns
{
    return @[
             column("productTypeId","text"),
             column("preProductTypeId","text"),
             column("verCode","integer"),
             column("language","text"),
             column("customName","text"),
             column("factoryId","text"),
             column("sequence","integer"),
             column("level","integer"),
             column("productNameId","text"),
             column("smallIconUrl","text"),
             column("detailIconUrl","text"),
             column("viewUrl","text"),
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

+ (NSString*)constrains
{
    return @"UNIQUE (productTypeId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject {

    NSString * sql = [NSString stringWithFormat:@"delete from appProductType where productTypeId = '%@' ",self.productTypeId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (NSString *)smallIconActrueUrl {
    if (!_smallIconActrueUrl.length) {
        NSString *sourceUrl = [HMAppFactoryAPI sourceUrl];
        NSString *appName = [HMStorage shareInstance].appName;
        NSString * tempSmallIconActrueUrl = [NSString stringWithFormat:@"%@%@/list/%d/%@",sourceUrl,appName,self.level,self.smallIconUrl];
        _smallIconActrueUrl = [tempSmallIconActrueUrl lowercaseString];
    }
   
    return _smallIconActrueUrl;

}

@end
