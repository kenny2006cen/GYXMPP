//
//  HMLoginBusiness+Token.m
//  HomeMateSDK
//
//  Created by Alic on 2020/4/26.
//  Copyright © 2020 orvibo. All rights reserved.
//

#import "HMLoginBusiness+Token.h"
#import "HMFamilyBusiness.h"

@implementation HMLoginBusiness (Token)
/**
 *  查询token，用于token登录
 */
+(void)queryTokenWithLoginInfo:(NSDictionary *)dict completion:(SocketCompletionBlock)completion{
    
    NSString *userId = dict[@"userId"];
    NSParameterAssert(userId);
    
    HMQueryLoginTokenCmd *cmd = [HMQueryLoginTokenCmd object];
    cmd.sendToServer = YES;
    sendCmd(cmd, ^(KReturnValue _value, NSDictionary *returnDic) {
        
        // 查询到自动登录Token，保存在本地
        if (_value == KReturnValueSuccess) {
            
            DLog(@"查询登录Token成功");
            // 当前登录的账号，Token信息保存下来
            [userAccout() addLocalAccountWithUserId:userId token:returnDic[@"accessToken"]];
            [userAccout() loginToReadDataWithToken:^(KReturnValue value) {
                if (value == KReturnValueSuccess) {
                    
                    // 家庭信息变化后再更新一次widget所需要的信息
                    [userAccout() widgetSaveUserInfo];
                    
                    if (completion) {
                        completion(value,returnDic);
                    }
                }else{
                    DLog(@"同步数据是不失败");
                    if (completion) {
                        completion(value,returnDic);
                    }
                }
            }];
        }else{
            
            DLog(@"查询登录Token失败");
            if (completion) {
                completion(_value,returnDic);
            }
        }
    });
}


+(BOOL)canUseTokenLogin{
    if (userAccout().isAutoLogin) {
        HMLocalAccount *accout = [HMLocalAccount objectWithUserId:userAccout().userId];
        if (accout && (!isBlankString(accout.token))) {
            return YES;
        }
    }
    return NO;
}

/**
 *  登录接口，使用Token自动登录，同步数据
 */
+(void)tokenAutonLoginWithCompletion:(SocketCompletionBlock)completion{
    
    [self tokenLoginWithCompletion:^(KReturnValue returnValue, NSDictionary *returnDic) {

        // 登录完成，如果登录成功，则立即查询family信息
        if (returnValue == KReturnValueSuccess) {

            DLog(@"使用Token登录成功");
            {
                NSString *userId = returnDic[@"userId"];
                NSParameterAssert(userId);
                
                DLog(@"上报 APNS Token");
                postToken();
                
                // 登录接口完成之后，立即请求家庭信息
                [HMFamilyBusiness requestFamilyWithUserId:userId completion:^(KReturnValue returnValue, NSDictionary *returnDic) {

                    if (returnValue == KReturnValueSuccess) {
                        // 家庭信息变化后再更新一次widget所需要的信息
                        [userAccout() widgetSaveUserInfo];
                        //读取当前家庭下面的数据
                        [HMLoginBusiness readDataInFamily:userAccout().familyId completion:completion];
                        
                    }else{
                        
                        if (completion) {
                            completion(returnValue,nil);
                        }
                    }
                }];
            }

        }else{
            DLog(@"使用Token登录失败");
            // 登录失败，直接把失败结果返回
            if (completion) {
                completion(returnValue,returnDic);
            }
        }
    }];
}
/**
*  只进行Token登录，不同步数据
*
*  @param completion 回调结果
*/
+(void)tokenLoginWithCompletion:(SocketCompletionBlock)completion{

    // 统一使用Token登录，同步数据
    HMLocalAccount *accout = [HMLocalAccount objectWithUserId:userAccout().userId];
    [self onlyLoginWithToken:accout.token completion:completion];
}

/**
*  只进行Token登录，不同步数据
*
*  @param completion 回调结果
*/
+(void)onlyLoginWithToken:(NSString *)token completion:(SocketCompletionBlock)completion{
    
    if (token && (!isBlankString(token))) {
        HMTokenLoginCmd *lgCmd = [HMTokenLoginCmd object];
        lgCmd.accessToken = token;
        lgCmd.sendToServer = YES;
        sendCmd(lgCmd, completion);
    }else{
        DLog(@"登录Token异常");
        if (completion) {
            completion(KReturnValueFail,nil);
        }
    }
}

/**
*  只进行Token登录，查询家庭信息，不同步数据，适用一键登录/验证码登录用户调用，使用外部传入的Token登录
*
*  @param completion 回调结果
*/
+(void)loginWithToken:(NSString *)token completion:(SocketCompletionBlock)completion{
    [self onlyLoginWithToken:token completion:^(KReturnValue loginReturnValue, NSDictionary *loginReturnDic) {
        // 登录完成，如果登录成功，则立即查询family信息
        if (loginReturnValue == KReturnValueSuccess) {
            DLog(@"登录成功");
            NSString *userId = loginReturnDic[@"userId"];
            NSParameterAssert(userId);
            // 登录接口完成之后，立即请求家庭信息
            [HMFamilyBusiness requestFamilyWithUserId:userId completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
                if (completion) {
                    completion(returnValue,returnDic);
                }
            }];
        }else{
            // 登录失败，直接把失败结果返回
            if (completion) {
                completion(loginReturnValue,loginReturnDic);
            }
        }
    }];
}

@end
