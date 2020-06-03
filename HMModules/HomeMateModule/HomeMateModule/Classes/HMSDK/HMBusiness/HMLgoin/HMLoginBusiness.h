//
//  HMLoginBusiness.h
//  HomeMateSDK
//
//  Created by Air on 2017/6/19.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseBusiness.h"

@interface HMLoginBusiness : HMBaseBusiness
/**
 *  获取登录指令
 *
 *  @param userName   用户名
 *  @param password   明文密码的MD5值 [传入参数为: md5WithStr(明文密码)]
 *  @param uid        如果命令发到主机，则填上主机的uid信息，否则不填
 *  @param type       登录类型 0:登录界面登录 1:管理员登录 2:普通用户登录 3:按照家庭登录 4:2.5版本新登录方式，登录接口只验证用户名和密码正确性
 *
 */

+(LoginCmd *)cmdWithUserName:(NSString *)userName password:(NSString *)password uid:(NSString *)uid type:(NSInteger)type;

/**
 *  登录接口，只发送登录指令到服务器做登录校验
 *
 *  @param userName   用户名
 *  @param password   明文密码的MD5值 [传入参数为: md5WithStr(明文密码)]
 *  @param completion 回调结果
 */
+(void)loginWithUserName:(NSString *)userName password:(NSString *)password completion:(SocketCompletionBlock)completion;


/**
 *  登录接口，只发送登录指令到服务器做登录校验
 *
 *  @param phone   手机号
 *  @param areaCode   国家区号
 *  @param code   验证码
 *  @param completion 回调结果
 */
+(void)loginWithPhone:(NSString *)phone areaCode:(NSString *)areaCode code:(NSString *)code completion:(SocketCompletionBlock)completion;

/**
 *  登录接口，手机号码一键登录
 *
 *  @param oneKeyToken   阿里sdk获取的一键登录Token
 *  @param completion     回调结果
 */
+(void)loginWithOneKeyToken:(NSString *)oneKeyToken completion:(SocketCompletionBlock)completion;

/**
 *  读取指定家庭的所有数据
 *
 *  @param familyId   指定家庭的id
 *  @param completion 回调结果
 */
+(void)readDataInFamily:(NSString *)familyId completion:(commonBlockWithObject)completion;

/**
 *  适用已成功登录后，需要更新数据时调用，方法内会自动登录，并更新家庭信息，以及所有的设备等信息
 *
 *  @param completion 回调结果
 */

+(void)autoLoginAndUpdateDataWithCompletion:(commonBlockWithObject)completion;


/// 手机号码一键登录
/// @param phone 手机号码
/// @param oneKeyToken token
/// @param version 版本号
/// @param completion 结果回调
+(void)loginWithPhone:(NSString *)phone oneKeyToken:(NSString *)oneKeyToken completion:(SocketCompletionBlock)completion;


@end
