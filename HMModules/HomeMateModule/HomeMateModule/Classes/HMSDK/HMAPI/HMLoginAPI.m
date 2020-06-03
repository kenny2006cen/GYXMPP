//
//  HMLoginAPI.m
//  HomeMateSDK
//
//  Created by Air on 2017/6/16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMLoginAPI.h"

#import "HMLoginBusiness+Local.h"
#import "HMLoginBusiness+Token.h"

@implementation HMLoginAPI
+(LoginCmd *)cmdWithUserName:(NSString *)userName password:(NSString *)password
{
    // 默认都用 type = 4 这种类型登录
    return [HMLoginBusiness cmdWithUserName:userName password:password uid:nil type:4];
}
+(LoginCmd *)cmdWithUserName:(NSString *)userName password:(NSString *)password uid:(NSString *)uid
{
    NSInteger type = uid ? 3 : 4; //uid有值时发给主机，值为3，uid无值时发给服务器，值为4
    return [HMLoginBusiness cmdWithUserName:userName password:password uid:uid type:type];
}

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
           completion:(SocketCompletionBlock)completion {
    [HMLoginBusiness loginWithPhone:phone areaCode:areaCode code:code completion:completion];
}

+(void)loginWithUserName:(NSString *)userName password:(NSString *)password completion:(SocketCompletionBlock)completion
{
    [HMLoginBusiness loginWithUserName:userName password:password completion:completion];
}

+(void)loginWithUserName:(NSString *)userName password:(NSString *)password uid:(NSString *)uid completion:(SocketCompletionBlock)completion{
    [HMLoginBusiness loginWithUserName:userName password:password uid:uid completion:completion];
}

+(void)readDataInFamily:(NSString *)familyId completion:(commonBlockWithObject)completion
{
    [HMLoginBusiness readDataInFamily:familyId completion:completion];
}

+(void)localLoginWithUserName:(NSString *)userName password:(NSString *)password completion:(SocketCompletionBlock)completion
{
    [HMLoginBusiness localLoginWithUserName:userName password:password completion:completion];
}

+(void)autoLoginAndUpdateDataWithCompletion:(commonBlockWithObject)completion
{
    [HMLoginBusiness autoLoginAndUpdateDataWithCompletion:completion];
}

/**
 *  登录接口，只发送登录指令到服务器做登录校验
 *
 *  @param oneKeyToken   一键登录Token
 *  @param completion     回调结果
 */
+(void)loginWithOneKeyToken:(NSString *)oneKeyToken completion:(SocketCompletionBlock)completion
{
    [HMLoginBusiness loginWithOneKeyToken:oneKeyToken completion:completion];
}

+ (void)loginWithPhone:(NSString *)phone oneKeyToken:(NSString *)oneKeyToken completion:(SocketCompletionBlock)completion
{
    [HMLoginBusiness loginWithPhone:phone oneKeyToken:oneKeyToken completion:completion];
}

+(void)loginWithOneKeyToken:(NSString *)oneKeyToken version:(NSString *)version completion:(SocketCompletionBlock)completion
{
    [HMLoginBusiness loginWithOneKeyToken:oneKeyToken completion:completion];
}

/**
*  只进行Token登录，不同步数据，适用一键登录/验证码登录用户调用，使用外部传入的Token登录
*
*  @param completion 回调结果
*/
+(void)loginWithToken:(NSString *)token completion:(SocketCompletionBlock)completion{
    [HMLoginBusiness loginWithToken:token completion:completion];
}

@end
