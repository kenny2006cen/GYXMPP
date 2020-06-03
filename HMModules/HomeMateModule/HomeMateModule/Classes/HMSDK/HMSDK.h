//
//  HMSDK.h
//
//  v3.6.0  2018/11/16
//  Copyright © 2018年 ORVIBO. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "HMTypes.h"
#import "HMProtocol.h"

@interface HMSDK : NSObject

/**
 *  服务端推送时会根据appName选择对应的推送证书和密钥向APNS发送推送信息
 *  所以第三方接入时如果需要推送服务，需要提供应用的唯一英文名称和APP发布时使用的推送证书及密钥
 *
 *  @param appName 第三方应用的唯一英文名称标识
 *
 */
+ (instancetype)initWithAppName:(NSString *)appName;

/**
 *  在方法initWithAppName:基础上新增idc参数，指定idc情况下，在请求IP时直接使用指定的idc
 */
+ (instancetype)initWithAppName:(NSString *)appName idc:(NSNumber *)idc;

/**
 *  widget初始化SDK
 *
 *  @param appName 第三方应用的唯一英文名称标识
 */
+ (instancetype)widgetInitWithAppName:(NSString *)appName type:(HMWidgetType)widgetType;

/**
 *  设置推送的deviceToken，没有此token，server无法准确推送设备执行消息，只支持TCP推送
 */
+ (void)setDeviceToken:(NSString *)deviceToken;

/**
 *  设置是否开启debug模式
 *
 *  @param enable YES 允许  NO 不允许
 */
+ (void)setDebugEnable:(BOOL)enable;

/**
 *  设置设备描述表的source
 */
+ (void)setDescSource:(NSString *)descSource;

/**
 *  根据用户名，明文密码进行登录，并通过block返回登录结果
 *
 *  @param userName   用户名
 *  @param password   明文密码
 *  @param completion 返回值
 */

+(void)loginWithUserName:(NSString *)userName password:(NSString *)password completion:(commonBlock)completion;

/**
 *  根据用户名，MD5密码进行登录，并通过block返回登录结果
 *
 *  @param userName   用户名
 *  @param md5pwd   明文密码的MD5值 [传入参数为: md5WithStr(明文密码)]
 *  @param completion 返回值
 */

+(void)loginWithUserName:(NSString *)userName md5pwd:(NSString *)md5pwd completion:(commonBlock)completion;

/**
 *  删除一个指定帐号的所有数据，如果出现数据无法同步的情况，可以执行一次此操作，然后重新登录
 */
+(void)deleteAllDataWithUserId:(NSString *)userId;

/**
 *  设置业务层的委托
 */
+(void)setBusinessDelegate:(id <HMBusinessProtocol>)delegate;

/**
 *  用户是否设置了使用测试服务器
 */
+(BOOL)isSetConnectTestServer;

/**
 *  设置SDK层连接测试服务器
 */
+(void)setConnectTestServer:(BOOL)connected;

/**
 *  如果用户没有手动设置测试服务器IP，则返回默认的测试服务器IP
 */
+(NSString *)testServerIP;

/**
 *  设置SDK层连接的测试服务器域名/或者IP
 *  如果setConnectTestServer设置为YES ：
 *  没有设置setTestServerIP的情况下，使用默认的测试服务器IP
 *  设置了setTestServerIP，则使用用户设置的IP
 */
+(void)setTestServerIP:(NSString *)ip;

/**
 *  设置SDK使用环境，默认Debug状态，注意：设置结果只在内存中保存
 */
+(void)setSDKEnvironment:(HMEnvironmentOptions)environmentOptions;

/**
 *  设置 widget UserDefault SuiteName
 */
+(void)setWidgetSuiteName:(NSString *)widgetSuiteName;

/**
 *  返回当前的SDK环境
 */
+(HMEnvironmentOptions)SDKEnvironment;

/**
 *  全局的内存cache字典
 */
+(NSMutableDictionary *)memoryDict;


/**
 *   返回当前登录类型
*/
+(HMUserLoginType)userLoginType;

@end
