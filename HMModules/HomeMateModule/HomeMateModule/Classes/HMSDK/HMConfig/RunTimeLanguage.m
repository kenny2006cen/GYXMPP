//
//  RunTimeLanguage.m
//  Vihome
//
//  Created by orvibo on 15-1-15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "RunTimeLanguage.h"
#import "HMUtil.h"
#import "NSObject+Save.h"
#import "HMTypes.h"
#import "HMConstant.h"


static NSString *kUserSelectedLanguageKey = @"HMUserSelectedLanguageKey";
@interface RunTimeLanguage()

@property (nonatomic, assign) BOOL stingFileExist;
@property (nonatomic, strong) NSString *lprojName;
@property (nonatomic, strong) NSArray *customLocalizedStringKeys;

+ (BOOL)onlyChinese;
+(BOOL)isTraditionalChinese:(NSString *)language;
+(BOOL)isLanguage:(NSString*) lan;

@end



@interface HMRunTimeLanguage : SingletonClass
@property (nonatomic, strong) NSNumber *zh_Hans;
@property (nonatomic, strong) NSNumber *zh_Hant;
@end

@implementation HMRunTimeLanguage

+ (id)shareInstance
{
    Singleton();
}

-(BOOL)inner_isZh_Hans{
    if ([RunTimeLanguage onlyChinese]) {
        return YES;
    }
    
    NSString *currentLanguage = [RunTimeLanguage getCurrentLanguage];
    // 先判断是否是繁体中文
    if ([RunTimeLanguage isTraditionalChinese:currentLanguage]) {
        return NO;
    }
    
    return [RunTimeLanguage isLanguage:@"zh"];
}

-(NSNumber *)zh_Hans{
    if (!_zh_Hans) {
        _zh_Hans = @([self inner_isZh_Hans]);
    }
    return _zh_Hans;
}

-(BOOL)inner_isZh_Hant{
    NSString *currentLanguage = [RunTimeLanguage getCurrentLanguage];
    if ([RunTimeLanguage isTraditionalChinese:currentLanguage]) {    // 繁体中文
        return YES;
    }
    return NO;
}

-(NSNumber *)zh_Hant{
    if (!_zh_Hant) {
        _zh_Hant = @([self inner_isZh_Hant]);
    }
    return _zh_Hant;
}

-(void)resetCachedLanguage{
    _zh_Hans = nil;
    _zh_Hant = nil;
}

@end



@implementation RunTimeLanguage
@synthesize stingFileExist;
@synthesize customLocalizedStringKeys;

+(NSArray *)customLocalizedStringKeys{
    
    NSArray *array = nil;
#if defined(__Opple__)
    
    array = @[@"UserNamePlaceholder",
              @"PleaseEnterYourAccount",
              @"Localizable_EnterFamilyPhoneNumberOrEmailAddress",
              @"Localizable_bindFirst",
              @"Localizable_needPhoneOrEmail",
              @"Localizable_EnterYourPhoneOrEmail"];
    
#else
    
    
#endif
    
    return array;
}

- (NSString *)runTimeLocalizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
    NSString *table = [NSString stringWithFormat:@"Custom-%@",self.lprojName];
    
    if (stingFileExist && [customLocalizedStringKeys containsObject:key]) {
        
        NSString *localizedString=[[NSBundle mainBundle] localizedStringForKey:key value:value table:table];
        if (localizedString) {
            return localizedString;
        }
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.lprojName ofType:@"lproj"];
    NSBundle *languageBundle = [NSBundle bundleWithPath:path];
    
    if (languageBundle) {
        
        NSString *localizedString=[languageBundle localizedStringForKey:key value:value table:nil];
        
        if (localizedString) {
            
            return localizedString;
        }
    }
    
    // 默认都返回英文
    NSString *defaultPath = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
    NSBundle *defaultBundle = [NSBundle bundleWithPath:defaultPath];
    NSString *defaultString=[defaultBundle localizedStringForKey:key value:value table:nil];
    return defaultString;
}
-(NSString *)lprojName
{
    if (!_lprojName) {
        _lprojName = [[self class]userSelectedLanguage];
    }
    return _lprojName;
}
+ (id)shareInstance
{
    Singleton();
}
-(id)init
{
    self = [super init];
    if (self) {
        
        self.stingFileExist = [[self class]stingFileExist];
        self.customLocalizedStringKeys = [[self class]customLocalizedStringKeys];
    }
    return self;
}

// 繁体中文
+(BOOL)isTraditionalChinese:(NSString *)language
{
    /*
     iOS 10
     
     zh-Hans,
     zh-Hans-CN,简体
     
     zh-Hant-CN,繁体
     zh-Hant-HK,
     zh-Hant-TW,
     zh-Hant-MO,
     zh-Hant,
     */
    
    
    /*
     iOS 9
     zh-Hans-CN,简体
     
     zh-Hant-CN,繁体
     zh-HK,
     zh-TW,
     
     */
    
    // 必须以zh开头
    if (![language.lowercaseString hasPrefix:@"zh".lowercaseString]) {
        
        DLog(@"isTraditionalChinese:%@ NO",language);
        return NO;
    }
    
    if (stringContainString(language.lowercaseString, @"HK".lowercaseString)) {
        
        DLog(@"isTraditionalChinese:%@ YES",language);
        return YES;
    }
    
    if (stringContainString(language.lowercaseString, @"TW".lowercaseString)) {
        
        DLog(@"isTraditionalChinese:%@ YES",language);
        return YES;
    }
    
    if (stringContainString(language.lowercaseString, @"MO".lowercaseString)) {
        
        DLog(@"isTraditionalChinese:%@ YES",language);
        return YES;
    }
    
    if (stringContainString(language.lowercaseString, @"Hant".lowercaseString)) {
        
        DLog(@"isTraditionalChinese:%@ YES",language);
        return YES;
    }
    
    DLog(@"isTraditionalChinese:%@ NO",language);
    return NO;
}

// 设备描述表使用的语言标志
+(NSString *)deviceLanguage
{
    RunTimeLanguage* wself = [RunTimeLanguage shareInstance];
    
    // 简体中文
    if ([wself.lprojName isEqualToString:@"zh-Hans"]) {
        return @"zh";
    }
    
    // 繁体中文
    if ([wself.lprojName isEqualToString:@"zh-Hant-TW"]) {
        return @"zh_TW";
    }
    
    //德语
    if([wself.lprojName isEqualToString:@"de"]){
        return @"de";
    }
    
    //日语
    if([wself.lprojName isEqualToString:@"ja"]){
        return @"ja";
    }
    //葡萄牙
    if([wself.lprojName isEqualToString:@"pt-PT"]){
        return @"pt";
    }
    
    //葡萄牙-巴西
    if([wself.lprojName isEqualToString:@"pt-BR"]){
        return @"pt_BR";
    }
    
    //法语
    if([wself.lprojName isEqualToString:@"fr"]){
        return @"fr";
    }
    
    //西班牙
    if([wself.lprojName isEqualToString:@"es"]){
        return @"es";
    }
    
    if ([wself.lprojName isEqualToString:@"ko"]) { // 韩语
        return @"ko";
    }
    
    if ([wself.lprojName isEqualToString:@"vi-VN"]) { // 越南
        return @"vi_VN";
    }
    
    if ([wself.lprojName isEqualToString:@"cs-CZ"]) { // 捷克语
        return @"cs_CZ";
    }
    // 默认英文
    return @"en";
}

//string文件的文件名
+(NSString *)languageCode
{
    
    if ([self onlyChinese]) { // 只支持中文的版本
        return @"zh-Hans";
    }
    
    if ([self isZh_Hant]) {
        return @"zh-Hant-TW";// 繁体中文
    }
    
    if([self isZh_Hans]){ //简体中文
        return @"zh-Hans";
    }
    
    if([self isLan_De]){ //德语
        return @"de";
    }
    
    if ([self isLan_Ja]) { // 日语
        return @"ja";
    }
    
    if ([self isLan_PtBR]) { // 葡萄牙语 -- 巴西
        return @"pt-BR";
    }
    
    if ([self isLan_Pt]) { // 葡萄牙语
        return @"pt-PT";
    }
 
    if ([self isLan_Fr]) { // 法语
        return @"fr";
    }
    
    if ([self isLan_Es]) { // 西班牙
        return @"es";
    }
    
    if ([self isLan_Ko]) { // 韩语
        return @"ko";
    }
    
    if ([self isLan_Ko]) { // 韩语
        return @"ko";
    }
    
    if ([self isLan_VN]) { // 越南语
        return @"vi-VN";
    }
    if ([self isLan_CZ]) { // 捷克语
        return @"cs-CZ";
    }
    
    NSString *currentLanguage = [RunTimeLanguage getCurrentLanguage];
    NSArray *localizations = [[NSBundle mainBundle]localizations];
    if ([localizations containsObject:currentLanguage]) { // 已本地化当前语言
        return currentLanguage;
    }
    
    // 默认英语
    return @"en";
}
+(BOOL)stingFileExist
{
    NSString *table = [NSString stringWithFormat:@"Custom-%@",[[self class] languageCode]];
    NSString *tableFile = [table stringByAppendingString:@".strings"];
    NSString *tablePath =[[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:tableFile];
    return [[NSFileManager defaultManager]fileExistsAtPath:tablePath];
}

+(BOOL)isLanguage:(NSString*) lan
{
    NSString *currentLanguage = [RunTimeLanguage getCurrentLanguage];
    return stringContainString(currentLanguage, lan);
}

+(BOOL)isZh_Hans
{
    return [[HMRunTimeLanguage shareInstance].zh_Hans boolValue];
}
//如果当前语言环境为繁体中文则返回yes，否则返回no
+(BOOL)isZh_Hant
{
    return [[HMRunTimeLanguage shareInstance].zh_Hant boolValue];
}

//如果当前语言环境为韩文则返回yes，否则返回no
+(BOOL)isLan_Ko
{
    return [self isLanguage:@"ko"];// 韩语
}

//如果当前语言环境为德语则返回yes，否则返回no
+(BOOL)isLan_De
{
    return [self isLanguage:@"de"];// 德语
}

//如果当前语言环境为日语则返回yes，否则返回no
+(BOOL)isLan_Ja
{
    return [self isLanguage:@"ja"];// 日语
}

//如果当前语言环境为葡萄牙语则返回yes，否则返回no
+(BOOL)isLan_Pt
{
     return [self isLanguage:@"pt"];// 葡萄牙欧洲语
}

//如果当前语言环境为葡萄牙-巴西则返回yes，否则返回no
+(BOOL)isLan_PtBR
{
    return [self isLanguage:@"pt-BR"];// 葡萄牙-巴西语
}

//如果当前语言环境为法语则返回yes，否则返回no
+(BOOL)isLan_Fr
{
    return [self isLanguage:@"fr"];// 法语
}

//如果当前语言环境为西班牙语则返回yes，否则返回no
+(BOOL)isLan_Es
{
    return [self isLanguage:@"es"];// 西班牙语
}

//如果当前语言环境为英语则返回yes，否则返回no
+(BOOL)isLan_En
{
    return [self isLanguage:@"en"];// 英语
}

//如果当前语言环境为越南语则返回yes，否则返回no
+(BOOL)isLan_VN
{
    return [self isLanguage:@"vi-VN"];// 越南
}

//如果当前语言环境为捷克语则返回yes，否则返回no
+(BOOL)isLan_CZ
{
    return [self isLanguage:@"cs-CZ"];// 捷克
}
+ (NSString *)getCurrentLanguage
{
    if ([self userLanguage]) {
        return [self userSelectedLanguage];
    }
    
    //    HMUserDefaults *defaults = [HMUserDefaults standardUserDefaults];
    //    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    //    NSString *currentLanguage = [languages firstObject];
    
    static NSString *currentLanguage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSArray *languages = [NSLocale preferredLanguages];
        currentLanguage = [languages firstObject];
        DLog(@"currentLanguage:%@" , currentLanguage);
        
    });
    
    return currentLanguage;
}

/**
 *  是不是只有中文
 *
 *  @return YES 是  NO 不是
 */
+ (BOOL)onlyChinese {
#if defined(__Hope__) \
|| defined(__Wts__) \
|| defined(__Welbell__) \
|| defined(__NVCLighting__) \
|| defined(__Opple__)\
|| defined(__BaLing__)// 向往、望天树、华百安 只有汉语
    
    return YES;
    
#else
    return NO;
    
#endif
}

+ (NSString *)userLanguage
{
    return [HMUserDefaults objectForKey:kUserSelectedLanguageKey];
}
/**
 *  获取用户选择的语言，如果用户未做选择，则以系统语言为准
 *
 *  @return 系统语言编码
 */
+ (NSString *)userSelectedLanguage
{
    NSString *lan = [self userLanguage];
    
    if (lan) {
        
        NSArray *localizations = [[NSBundle mainBundle]localizations];
        if ([localizations containsObject:lan]) { // 已本地化用户选择的语言，则直接返回，否则返回当前系统的语言
            return lan;
        }else{
            // 未本地化用户选择的语言，则应该移除UserDefaults中的数据
            [HMUserDefaults removeObjectForKey:kUserSelectedLanguageKey];
        }
    }
    return [self languageCode];
}

/**
 *  保存用户选择的语言，启动以用户选择的语言为准
 */
+ (void)saveUserLanguage:(NSString *)language
{
    NSArray *localizations = [[NSBundle mainBundle]localizations];
    if ([localizations containsObject:language]) { // 已本地化用户选择的语言，则保存
        [HMUserDefaults saveObject:language withKey:kUserSelectedLanguageKey];
        // 保存后更新languageCode
        [RunTimeLanguage shareInstance].lprojName = language;
        [[HMRunTimeLanguage shareInstance] resetCachedLanguage]; // 重置缓存的语言信息
    }
}
@end

