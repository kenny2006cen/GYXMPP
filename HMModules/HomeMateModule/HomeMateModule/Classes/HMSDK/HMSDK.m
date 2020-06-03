//
//  HMSDK.m
//  HomeMateSDK
//
//  Created by Air on 16/3/7.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMSDK.h"
#import "HMDescConfig.h"
#import "HMAppFactoryConfig.h"
#import "HMTaskManager.h"
#import "HMConstant.h"
#import "HMStorage.h"

@implementation HMSDK

+ (instancetype)initWithAppName:(NSString *)appName
{
    return [self initWithAppName:appName idc:nil];
}
/**
 *  widget初始化SDK
 *
 *  @param appName 第三方应用的唯一英文名称标识
 */
+ (instancetype)widgetInitWithAppName:(NSString *)appName type:(HMWidgetType)widgetType
{
    NSString *widgetName = @"异常情况";
    if (widgetType == HMWidgetDevice) {
        widgetName = @"设备widget初始化";
    }else if (widgetType == HMWidgetScene) {
        widgetName = @"情景widget初始化";
    }else if (widgetType == HMWidgetSecurity) {
        widgetName = @"安防widget初始化";
    }else if (widgetType == HMSiriIntent) {
        widgetName = @"SiriIntent初始化";
    }
    DLog(widgetName);
    userAccout().isWidget = YES;
    userAccout().widgetType = widgetType;
    return [self initWithAppName:appName idc:nil];
}

+ (instancetype)initWithAppName:(NSString *)appName idc:(NSNumber *)idc
{
    static id __singletion__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [HMStorage shareInstance].appName = appName;
        [HMStorage shareInstance].lastFamilyCount = 0; // 默认为0
        // 默认值 HomeMate，外部可以修改
        [HMStorage shareInstance].descSource = @"HomeMate";
        [HMStorage shareInstance].specifiedIdc = idc;
        
        __singletion__ =[[self alloc] init];
    });
    return __singletion__;
}
- (instancetype)init {
    if (self = [super init]) {
        
        // 开启网络监测
        [[HMNetworkMonitor shareInstance] startNetworkNotifier];
        
        // 初始化数据库
        [[HMDatabaseManager shareDatabase]initDatabase];

    }
    return self;
}

+ (void)setDeviceToken:(NSString *)deviceToken
{
    [HMStorage shareInstance].deviceToken = deviceToken;
}

+ (void)setDebugEnable:(BOOL)enable
{
    [HMStorage shareInstance].enableLog = enable;
}


+(void)setBusinessDelegate:(id <HMBusinessProtocol>)delegate
{
    [HMStorage shareInstance].delegate = delegate;
}

+ (void)setDescSource:(NSString *)descSource
{
    [HMStorage shareInstance].descSource = descSource;
}

+(void)loginWithUserName:(NSString *)userName password:(NSString *)password completion:(commonBlock)completion
{
    [[AccountSingleton shareInstance] loginToReadDataWithUserName:userName password:md5WithStr(password) completion:completion];
}

+(void)loginWithUserName:(NSString *)userName md5pwd:(NSString *)md5pwd completion:(commonBlock)completion
{
    [[AccountSingleton shareInstance] loginToReadDataWithUserName:userName password:md5pwd completion:completion];
}
// 删除一个指定帐号的所有数据，如果出现数据无法同步的情况，可以执行一次此操作，然后重新登录
+(void)deleteAllDataWithUserId:(NSString *)userId
{
    [userAccout() deleteAccountWithUserId:userId];
}
/**
 *  当前连接的是否是测试服务器
 */
+(BOOL)isSetConnectTestServer{
    return [[HMSDK memoryDict][@"isConnectTestServer"] boolValue];
}
/**
 *  设置SDK层连接测试服务器
 */
+(void)setConnectTestServer:(BOOL)connected{
    [HMSDK memoryDict][@"isConnectTestServer"] = @(connected);
}

/**
 *  当前测试服务器IP，如果用户没有手动设置，则返回默认的测试服务器IP
 */
+(NSString *)testServerIP{
    NSString *userSettedIP = [HMSDK memoryDict][@"testServerIP"];
    if (userSettedIP) {
        return userSettedIP;
    }
    HMEnvironmentOptions env = [HMSDK SDKEnvironment];
    if (env == HMEnvironmentDebug) {
        return @"106.53.16.50"; //测试环境
    }
    if (env == HMEnvironmentDebug2) {
        return HM_DOMAIN_NAME; // 线上环境
    }
    if (env == HMEnvironmentDebug3) {
        return @"192.168.2.241"; // 开发环境
    }
    return @"106.53.16.50"; //默认测试环境
}

/**
 *  设置SDK层连接的测试服务器域名/或者IP
 *  如果setConnectTestServer设置为YES ：
 *  没有设置setTestServerIP的情况下，使用默认的测试服务器IP
 *  设置了setTestServerIP，则使用用户设置的IP
 */
+(void)setTestServerIP:(NSString *)ip{
    [HMSDK memoryDict][@"testServerIP"] = ip;
}

/**
 *  设置SDK使用环境，默认Debug状态，注意：设置结果只在内存中保存
 */
+(void)setSDKEnvironment:(HMEnvironmentOptions)environmentOptions{
    [HMSDK memoryDict][@"SDKEnvironment"] = @(environmentOptions);
}

/**
 *  设置 widget UserDefault SuiteName
 */
+(void)setWidgetSuiteName:(NSString *)widgetSuiteName{
    [HMSDK memoryDict][@"widgetSuiteName"] = widgetSuiteName;
}

/**
 *  返回当前的SDK环境
 */
+(HMEnvironmentOptions)SDKEnvironment{
    NSNumber *env = [HMSDK memoryDict][@"SDKEnvironment"];
    return env?[env unsignedLongValue]:HMEnvironmentDefault;
}
+(NSMutableDictionary *)memoryDict{
    return [HMStorage shareInstance].hmCacheDic;
}


+(HMUserLoginType)userLoginType{
    return [RemoteGateway userLoginType];
}
@end
