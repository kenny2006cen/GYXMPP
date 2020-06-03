//
//  HMLoginBusiness.m
//  HomeMateSDK
//
//  Created by Air on 2017/6/19.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMLoginBusiness.h"
#import "RemoteGateway+WiFi.h"
#import "HMFamilyBusiness.h"
#import "SearchMdns.h"
#import "HMLoginBusiness+Token.h"

@implementation HMLoginBusiness

+(LoginCmd *)cmdWithUserName:(NSString *)userName password:(NSString *)password uid:(NSString *)uid type:(NSInteger)type
{
    NSParameterAssert(userName);
    NSParameterAssert(password);
    
    LoginCmd *lgCmd = [LoginCmd object];
    lgCmd.uid = uid;
    lgCmd.userName = userName;
    lgCmd.password = password;
    lgCmd.type = type;
    lgCmd.sendToServer = (!uid) ? YES : NO ;
    
    return lgCmd;
}


+(void)loginWithUserName:(NSString *)userName password:(NSString *)password completion:(SocketCompletionBlock)completion
{
    // type = 4; 2.5版本新登录方式，登录接口只验证用户名和密码正确性
    LoginCmd *lgCmd = [HMLoginBusiness cmdWithUserName:userName password:password uid:nil type:4];
    
    sendCmd(lgCmd, ^(KReturnValue loginReturnValue, NSDictionary *loginReturnDic) {
        
        // 登录完成，如果登录成功，则立即查询family信息
        if (loginReturnValue == KReturnValueSuccess) {
            
            DLog(@"登录成功");
            
            NSString *userId = loginReturnDic[@"userId"];
            NSParameterAssert(userId);
                    
            // 当前登录的账号，密码信息保存下来
            [userAccout() addLocalAccountWithUserName:userName password:password userId:userId];
            
            DLog(@"远程登录成功之后上报token");
            postToken();
            
            // 登录接口完成之后，立即请求家庭信息
            [HMFamilyBusiness requestFamilyWithUserId:userId completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
                
                // 家庭信息变化后再更新一次widget所需要的信息
                [userAccout() widgetSaveUserInfo];
                
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
    });
}

//如果是具有不同权限的 userId 登录到同一个 familyId 下面，如果他们具有的权限不同，那么数据也应该是不同的
+(void)checkNeedCleanOldDataWithUserId:(NSString *)userId familyId:(NSString *)familyId completion:(commonBlockWithObject)completion
{
    if (userAccout().isWidget) {
        DLog(@"widget登录，不读表");
        return;
    }
    NSParameterAssert(userId);
    NSParameterAssert(familyId);
    
    // 场景：家庭1 里面A是超级管理员，B是普通成员。安卓登录A，iOS登录B，A设置B不可见灯4。然后iOS登录A，但是默认家庭为家庭2，然后切换到家庭1，此时也是自动登录状态，没有校验：不同权限的用户登录同一个家庭，从而导致A看不到灯4
    
    // 如果当前familyId的数据是当前userId读下来的，则不做任何处理
    // 如果当前familyId的数据还不属于任何userId,则也不做处理
    // 如果当前familyId的数据不属于当前userId，而是另一个userId的数据（因权限不同，可能数据有差异），则应先清除当前家庭的所有数据再重新读取所有数据
    
    NSString *currentUserIdInFmlyKey =  [NSString stringWithFormat:@"CurrentUserIdInFamilyKey_%@",familyId];
    NSString *userIdInFamily = [HMUserDefaults objectForKey:currentUserIdInFmlyKey];
    
    if (!userIdInFamily) {
        DLog(@"当前familyId：%@ userId：%@ 未找到其他的userId登录到同一个familyId，不清除当前家庭的数据,直接保存即可",familyId,userId);
    }else if ([userIdInFamily isEqualToString:userId]){
        DLog(@"当前familyId：%@ userId：%@ 此familyId的数据是上一次同一个userId：%@ 读下来的,直接保存即可",familyId,userId,userIdInFamily);
    }else{ // (userIdInFamily && ![userIdInFamily isEqualToString:userId])
        DLog(@"当前familyId：%@ userId：%@ 此familyId的数据是上一次另一个userId：%@ 读下来的，因他们的权限可能不同，所以需要先清除当前家庭的所有数据再重新读取所有数据",familyId,userId,userIdInFamily);
        
        [[HMDatabaseManager shareDatabase]deleteAllWithFamilyId:familyId];
    }
    
    [[RemoteGateway shareInstance] readAllDataWithFamilyId:familyId completion:^(KReturnValue value,id object) {
        
        DLog(@"读取家庭familyId：%@ 所有数据返回状态：%d",familyId,value);
        if (value == KReturnValueSuccess) {
            
            if (![userIdInFamily isEqualToString:userId]){
                
                DLog(@"保存当前家庭familyId：%@ 的数据是属于最新的userId：%@",familyId,userId);
                
                [HMUserDefaults saveObject:userId withKey:currentUserIdInFmlyKey];
                
            }else{
                DLog(@"上次和本次是同一个用户进入到当前家庭familyId：%@ userId：%@",familyId,userId);
            }
        }
        
        if (completion) {
            completion(value,object);
        }
    }];
}

+(void)readDataInFamily:(NSString *)familyId completion:(commonBlockWithObject)completion
{
    [self checkNeedCleanOldDataWithUserId:userAccout().userId familyId:familyId completion:completion];
}

+(void)autoLoginAndUpdateDataWithCompletion:(commonBlockWithObject)completion
{
    if ([RemoteGateway shareInstance].isSocketConnected) {
        DLog(@"当前登录状态未失效，则直接同步家庭下面的数据即可");
        [HMLoginBusiness readDataInFamily:userAccout().familyId completion:completion];
        return;
    }
    
    DLog(@"登录状态失效的情况下，重新进行登录再同步数据");
    NSString *password = userAccout().currentPassword;
    NSString *userName = userAccout().currentUserName;
    if (isBlankString(userName) || isBlankString(password)) {
        if ([self canUseTokenLogin]) {
            DLog(@"使用Token登录");
            [self tokenAutonLoginWithCompletion:completion];
            return;
        }
    }
    
    DLog(@"使用账号密码登录");
    [self loginWithUserName:userName password:password completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            //读取当前家庭下面的数据
            [HMLoginBusiness readDataInFamily:userAccout().familyId completion:completion];
            
        }else{
            
            if (completion) {
                completion(returnValue,nil);
            }
        }
        
    }];
}

/**
 *  登录接口，只发送登录指令到服务器做登录校验
 *
 *  @param phone   手机号
 *  @param areaCode   国家区号
 *  @param code   验证码
 *  @param completion 回调结果
 */
+(void)loginWithPhone:(NSString *)phone areaCode:(NSString *)areaCode code:(NSString *)code completion:(SocketCompletionBlock)completion{
    
    SMSCodeLoginCmd * cmd = [SMSCodeLoginCmd object];
    cmd.phone = phone;
    cmd.areaCode = areaCode;
    cmd.code = code;
    cmd.sendToServer = YES;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            DLog(@"短信登录成功");
            [self queryTokenWithLoginInfo:returnDic completion:completion];
        }else{
            // 登录失败，直接把失败结果返回
            if (completion) {
                completion(returnValue,returnDic);
            }
        }
    });
}

/**
 *  登录接口，只发送登录指令到服务器做登录校验
 *
 *  @param oneKeyToken   一键登录Token
 *  @param completion     回调结果
 */
+(void)loginWithOneKeyToken:(NSString *)oneKeyToken completion:(SocketCompletionBlock)completion{
    HMOneKeyLoginCmd * cmd = [HMOneKeyLoginCmd object];
    cmd.oneKeyToken = oneKeyToken;
    cmd.sysVersion = @"iOS";
    cmd.sendToServer = YES;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            [self queryTokenWithLoginInfo:returnDic completion:completion];
        }else{
            // 一键登录失败，直接把结果返回
            if (completion) {
                completion(returnValue,returnDic);
            }
        }
    });
}

/**
 *  登录接口，idc变化时，第二次验证需要使用此接口
 *
 *  @param oneKeyToken   一键登录Token
 *  @param phone   手机号码
 *  @param completion     回调结果
 */
+(void)loginWithPhone:(NSString *)phone oneKeyToken:(NSString *)oneKeyToken completion:(SocketCompletionBlock)completion{
    
    HMOneKeyLoginPhoneCmd * cmd = [HMOneKeyLoginPhoneCmd object];
    cmd.oneKeyToken = oneKeyToken;
    cmd.sysVersion = @"iOS";
    cmd.phone = phone;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            [self queryTokenWithLoginInfo:returnDic completion:completion];
        }else{
            if (completion) {
                completion(returnValue,returnDic);
            }
        }
    });
}

@end
