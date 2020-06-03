//
//  HMAppMyCenter.m
//  HomeMateSDK
//
//  Created by liqiang on 17/5/10.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppMyCenter.h"
#import "HMBaseModel+Extension.h"
#import "HMAppFactoryAPI.h"
#import "HMStorage.h"

@implementation HMAppMyCenter
+ (NSString *)tableName {
    return @"appMyCenter";
}

+ (NSArray*)columns
{
    return @[
             column("myCenterId","text"),
             column("factoryId","text"),
             column("groupIndex","integer"),
             column("sequence","integer"),
             column("verCode","integer"),
             column("iconUrl","text"),
             column("viewId","text"),
             column("updateTime","text"),
             column("createTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (myCenterId) ON CONFLICT REPLACE";
}


-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject {
    
    NSString * sql = [NSString stringWithFormat:@"delete from appMyCenter where myCenterId = '%@' ",self.myCenterId];
    BOOL result = [self executeUpdate:sql];
    return result;
}


- (NSString *)iconRealUrl {
    if(_iconRealUrl == nil) {
        NSString *sourceUrl = [HMAppFactoryAPI sourceUrl];
        NSString *appName = [HMStorage shareInstance].appName;
        _iconRealUrl = [[NSString stringWithFormat:@"%@%@/my/%@",sourceUrl,appName,self.iconUrl] lowercaseString];
    }
    return _iconRealUrl;
}
@end
