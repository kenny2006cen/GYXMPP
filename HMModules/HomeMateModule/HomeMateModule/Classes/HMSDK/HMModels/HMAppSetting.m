//
//  HMAppSetting.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/4/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppSetting.h"
#import "HMConstant.h"


@implementation HMAppSetting

+ (NSString *)tableName {
    return @"appSetting";
}

+ (NSArray*)columns
{
    return @[
             column("id","text"),
             column("factoryId","text"),
             column("platform","text"),
             column("bgColor","text"),
             column("fontColor","text"),
             column("topicColor","text"),
             column("securityBgColor","text"),
             column("startSec","integer"),
             column("qqAuth","text"),
             column("wechatAuth","text"),
             column("weiboAuth","text"),
             column("xiaoFAuthority","text"),
             column("daLaCoreCode","text"),
             column("aMapKey","text"),
             column("updateTime","text"),
             column("scanBarEnable","text"),
             column("smsRegisterEnable","integer"),
             column("emailRegisterEnable","integer"),
             column("keyParam","text default ''"),
             column("createTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSArray<NSDictionary *>*)newColumns {
    return  @[column("keyParam","text default ''")];
}



+ (NSString*)constrains
{
    return @"UNIQUE (id,factoryId,platform) ON CONFLICT REPLACE";
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject {

    NSString * sql = [NSString stringWithFormat:@"delete from appSetting where factoryId = '%@' ",self.factoryId];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (void)setBgColor:(NSString *)bgColor {
    _bgColor = bgColor;
    self.controllerBgColor = [BLUtility colorWithHexString:bgColor alpha:1];
}
- (void)setFontColor:(NSString *)fontColor {
    _fontColor = fontColor;
    self.lableFontColor = [BLUtility colorWithHexString:fontColor alpha:1];
}
- (void)setTopicColor:(NSString *)topicColor {
    _topicColor = topicColor;
    self.appTopicColor = [BLUtility colorWithHexString:topicColor alpha:1];
}
- (void)setSecurityBgColor:(NSString *)securityBgColor {
    _securityBgColor = securityBgColor;
    self.securityColor = [BLUtility colorWithHexString:securityBgColor alpha:1];
}

@end
