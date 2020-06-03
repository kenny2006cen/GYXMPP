//
//  RunTimeLanguage.h
//  Vihome
//
//  Created by orvibo on 15-1-15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "SingletonClass.h"

@interface RunTimeLanguage : SingletonClass

//如果当前语言环境为简体中文则返回yes，否则返回no
+(BOOL)isZh_Hans;

//如果当前语言环境为繁体中文则返回yes，否则返回no
+(BOOL)isZh_Hant;

//如果当前语言环境为韩文则返回yes，否则返回no
+(BOOL)isLan_Ko;

//如果当前语言环境为德语则返回yes，否则返回no
+(BOOL)isLan_De;

//如果当前语言环境为日语则返回yes，否则返回no
+(BOOL)isLan_Ja;

//如果当前语言环境为葡萄牙语则返回yes，否则返回no
+(BOOL)isLan_Pt;

//如果当前语言环境为法语则返回yes，否则返回no
+(BOOL)isLan_Fr;

//如果当前语言环境为西班牙则返回yes，否则返回no
+(BOOL)isLan_Es;

//如果当前语言环境为英语则返回yes，否则返回no
+(BOOL)isLan_En;

/**
 *  返回系统语言简称
 *
 *  @return zh：简体中文 en：英文
 */
+(NSString *)languageCode;

/**
 *  返回设备信息对应的code
 *
 *  @return zh：简体中文 zh_TW：繁体中文 en：英文
 */
+(NSString *)deviceLanguage;

/**
 *  获取系统语言
 *
 *  @return 系统语言编码
 */
+ (NSString *)getCurrentLanguage;

/**
 *  获取用户选择的语言，如果用户未做选择，则以系统语言为准
 *
 *  @return 系统语言编码
 */
+ (NSString *)userSelectedLanguage;

/**
 *  保存用户选择的语言，启动以用户选择的语言为准
 */
+ (void)saveUserLanguage:(NSString *)language;

- (NSString *)runTimeLocalizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;

@end

