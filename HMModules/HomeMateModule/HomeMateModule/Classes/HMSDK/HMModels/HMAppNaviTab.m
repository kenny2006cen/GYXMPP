//
//  HMAppNaviTab.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/4/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppNaviTab.h"
#import "HMConstant.h"
#import "HMStorage.h"

@implementation HMAppNaviTab

+ (NSString *)tableName {
    return @"appNaviTab";
}

+ (NSArray*)columns
{
    return @[
             column("naviTabId","text"),
             column("factoryId","text"),
             column("sequence","integer"),
             column("verCode","integer"),
             column("defaultIconUrl","text"),
             column("selectedIconUrl","text"),
             column("defaultFontColor","text"),
             column("selectedFontColor","text"),
             column("viewId","text"),
             column("updateTime","text"),
             column("createTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (naviTabId) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject {

    NSString * sql = [NSString stringWithFormat:@"delete from appNaviTab where naviTabId = '%@' ",self.naviTabId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (void)setDefaultFontColor:(NSString*)defaultFontColor {
    _defaultFontColor = defaultFontColor;
    self.defaultColor = [BLUtility colorWithHexString:defaultFontColor alpha:1];
}

- (void)setSelectedFontColor:(NSString*)selectedFontColor {
    _selectedFontColor = selectedFontColor;
    self.selectedColor = [BLUtility colorWithHexString:selectedFontColor alpha:1];
}


- (NSString *)defaultRealIconUrl {
    if (_defaultRealIconUrl == nil) {
        NSString *sourceUrl = [HMAppFactoryAPI sourceUrl];
        NSString *appName = [HMStorage shareInstance].appName;
        _defaultRealIconUrl = [[NSString stringWithFormat:@"%@%@/tab/%@",sourceUrl,appName,self.defaultIconUrl] lowercaseString];
    }
    
    return _defaultRealIconUrl;
}

- (NSString *)selectedRealIconUrl {
    if (_selectedRealIconUrl == nil) {
        NSString *sourceUrl = [HMAppFactoryAPI sourceUrl];
        NSString *appName = [HMStorage shareInstance].appName;
        _selectedRealIconUrl = [[NSString stringWithFormat:@"%@%@/tab/%@",sourceUrl,appName,self.selectedIconUrl] lowercaseString];
    }
    
    return _selectedRealIconUrl;
}
@end
