//
//  HMLoginAPI.h
//  HomeMateSDK
//
//  Created by Air on 2017/6/16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseAPI.h"
#import "HMConstant.h"


@interface HMLoginAPI : HMBaseAPI

/**
 *  获取登录指令
 *
 *  @param userName   用户名
 *  @param password   明文密码的MD5值 [传入参数为: md5WithStr(明文密码)]
 *
 */

+(LoginCmd *)cmdWithUserName:(NSString *)userName password:(NSString *)password;
+(LoginCmd *)cmdWithUserName:(NSString *)userName password:(NSString *)password uid:(NSString *)uid;

/**
 *  登录接口，只发送登录指令到服务器做登录校验
 *
 *  @param userName   用户名
 *  @param password   明文密码的MD5值 [传入参数为: md5WithStr(明文密码)]
 *  @param completion 回调结果
 */
+(void)loginWithUserName:(NSString *)userName
                password:(NSString *)password
              completion:(SocketCompletionBlock)completion;

/**
 *  登录接口，只发送登录指令到主机做登录校验，限制使用场景为局域网登录主机
 *
 *  @param userName   用户名
 *  @param password   明文密码的MD5值 [传入参数为: md5WithStr(明文密码)]
 *  @param uid        主机的uid信息
 *  @param completion 回调结果
 */
+(void)loginWithUserName:(NSString *)userName
                password:(NSString *)password
                     uid:(NSString *)uid
              completion:(SocketCompletionBlock)completion;



/**
 *  读取指定家庭的所有数据
 *
 *  @param familyId   指定家庭的id
 *  @param completion 回调结果
 */
+(void)readDataInFamily:(NSString *)familyId completion:(commonBlockWithObject)completion;



/**
 *  局域网登录主机，有任意一台主机登录成功则立即返回
 *
 *  @param userName   用户名
 *  @param password   明文密码的MD5值 [传入参数为: md5WithStr(明文密码)]
 *  @param completion 回调结果
 *
 */
+(void)localLoginWithUserName:(NSString *)userName password:(NSString *)password completion:(SocketCompletionBlock)completion;


/**
 *  适用已成功登录后，需要更新数据时调用，方法内会自动登录，并更新家庭信息，以及所有的设备等信息
 *
 *  @param completion 回调结果
 */

+(void)autoLoginAndUpdateDataWithCompletion:(commonBlockWithObject)completion;

/**
 *  登录接口，只发送登录指令到服务器做登录校验
 *
 *  @param phone   手机号
 *  @param areaCode   国家区号
 *  @param code   验证码
 *  @param completion 回调结果
 */
+(void)loginWithPhone:(NSString *)phone
             areaCode:(NSString *)areaCode
                 code:(NSString *)code
           completion:(SocketCompletionBlock)completion;

/// 一键登录
/// @param oneKeyToken sdk token
/// @param completion 结果回调
+(void)loginWithOneKeyToken:(NSString *)oneKeyToken
                 completion:(SocketCompletionBlock)completion;


/// 手机号码一键登录
/// @param phone 手机号码
/// @param oneKeyToken token
/// @param completion 结果回调
+(void)loginWithPhone:(NSString *)phone
          oneKeyToken:(NSString *)oneKeyToken
           completion:(SocketCompletionBlock)completion;

/**
*  只进行Token登录，不同步数据，适用一键登录/验证码登录用户调用，使用外部传入的Token登录
*
*  @param completion 回调结果
*/
+(void)loginWithToken:(NSString *)token completion:(SocketCompletionBlock)completion;

@end
