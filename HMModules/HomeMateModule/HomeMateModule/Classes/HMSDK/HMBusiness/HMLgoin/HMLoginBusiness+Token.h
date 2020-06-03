//
//  HMLoginBusiness+Token.h
//  HomeMateSDK
//
//  Created by Alic on 2020/4/26.
//  Copyright © 2020 orvibo. All rights reserved.
//

#import "HMLoginBusiness.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMLoginBusiness (Token)

/**
*  查询自动登录的Token信息
*
*  @param dict  登录接口返回的dict数据，包括（cmd=2，cmd=331，cmd=332，cmd=335）
*  @param completion 回调结果
*/
+(void)queryTokenWithLoginInfo:(NSDictionary *)dict completion:(SocketCompletionBlock)completion;

/**
*  使用Token自动登录，并同步数据
*
*  @param completion 回调结果
*/
+(void)tokenAutonLoginWithCompletion:(SocketCompletionBlock)completion;

/**
*  只进行Token登录，不同步数据，适用一键登录/验证码登录用户调用，使用SDK自动保存的Token登录
*
*  @param completion 回调结果
*/
+(void)tokenLoginWithCompletion:(SocketCompletionBlock)completion;

/**
*  只进行Token登录，查询家庭信息，不同步数据，适用一键登录/验证码登录用户调用，使用外部传入的Token登录
*
*  @param completion 回调结果
*/
+(void)loginWithToken:(NSString *)token completion:(SocketCompletionBlock)completion;

/**
*  是否可以使用Token自动登录
*/
+(BOOL)canUseTokenLogin;

@end

NS_ASSUME_NONNULL_END
