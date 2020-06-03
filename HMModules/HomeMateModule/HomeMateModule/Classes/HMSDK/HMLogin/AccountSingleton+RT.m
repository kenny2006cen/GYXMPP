//
//  AccountSingleton+RT.m
//  HomeMate
//
//  Created by Air on 15/8/12.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "AccountSingleton+RT.h"
#import "Gateway+RT.h"
#import "TokenReportCmd.h"
#import "HMLoginBusiness+Token.h"
#import "HMFamilyBusiness.h"

static NSTimeInterval beginTimeStamp = 0;

@implementation AccountSingleton (RT)

#pragma mark - 读取当前账号信息和账号下所有设备的数据

-(void)readAllData:(commonBlockWithObject)completion
{
    LogFuncName();
    [HMLoginAPI readDataInFamily:self.familyId completion:completion];
}

-(void)loginAccount:(NSString *)userName password:(NSString *)password completion:(SocketCompletionBlock)completion
{
    LogFuncName();
    
    DLog(@"当前登录账号：%@ 密码：%@",userName,password);
    
    self.currentPassword = password;
    self.currentUserName = userName;
    
    [HMLoginAPI loginWithUserName:userName password:password completion:completion];
}

-(void)loginWithUserName:(NSString *)userName password:(NSString *)password completion:(SocketCompletionBlock)completion
{
    LogFuncName();
    
    [self loginAccount:userName password:password completion:completion];
}

-(SocketCompletionBlock)loginBlock:(commonBlock)completion{
    __weak typeof(self)weakSelf = self;
    SocketCompletionBlock block = ^(KReturnValue returnValue, NSDictionary *resultDic) {
    
    weakSelf.serverLoginValue = returnValue;
    weakSelf.localLoginValue = KReturnValueFail; // 本地默认登录失败，只有自动登录的情况下，而且远程登录失败才尝试本地登录
                     
    if (returnValue == KReturnValueSuccess) { // 远程登录成功
        
            DLog(@"开始读账号信息和所有wifi数据");
            [weakSelf readAllData:^(KReturnValue value,id object) {
                
                DLog(@"账号信息和所有wifi数据读取%@",(value == KReturnValueSuccess) ? @"成功" : @"失败");
                
                [weakSelf postResultWithCompletion:completion];
            }];

        }else{
            
            DLog(@"远程登录失败，错误码：%d",returnValue);
            
            // 自动登录状态
            if (self.isAutoLogin) {

                [HMLoginAPI localLoginWithUserName:weakSelf.userName password:weakSelf.password completion:^(KReturnValue value, NSDictionary *returnDic) {
                    
                    weakSelf.localLoginValue = value;
                    [weakSelf postResultWithCompletion:completion];
                }];
                
            }else{
                
                // 非自动登录状态，直接返回远程登录结果
                [weakSelf postResultWithCompletion:completion];
            }
        }
    };
    return block;
}

-(void)loginToReadDataWithToken:(commonBlock)completion{
    
    LogFuncName();
    
    beginTimeStamp = CACurrentMediaTime();
    
    DLog(@"============开始登录");
    
    self.isReading = YES;
    self.isManualLogout = NO;
    
    [HMFamilyBusiness requestFamilyWithUserId:self.userId completion:[self loginBlock:completion]];
}

-(void)loginToReadDataWithUserName:(NSString *)userName password:(NSString *)password completion:(commonBlock)completion
{
    LogFuncName();
    
    beginTimeStamp = CACurrentMediaTime();
    
    DLog(@"============开始登录");
    
    SocketCompletionBlock block = [self loginBlock:completion];
    
    __weak typeof(self)weakSelf = self;
    weakSelf.isReading = YES;
    weakSelf.isManualLogout = NO;
    
    if (!isBlankString(userName) && !isBlankString(password)) {
        [weakSelf loginAccount:userName password:password completion:block];
    }else if ([HMLoginBusiness canUseTokenLogin]){
        [HMFamilyBusiness requestFamilyWithUserId:weakSelf.userId completion:block];
    }else{
        block(KReturnValueFail,nil);
    };
    
}

#pragma mark - 发出登录完成的通知
-(void)postResultWithCompletion:(commonBlock)completion
{
    LogFuncName();
    
    self.isReading = NO;
    // 清除掉delFlag = 1 的数据  （HMMessageCommon表不能清，有个最大序号是以delFlag=1标记的）
    cleanDeviceData(nil);
    
    if (self.isManualLogout) {
        
        DLog(@"用户手动退出登录");
        return;
    }
    
    if (self.isEnterBackground) {
        
        DLog(@"App已进入后台");
        return;
    }
    
    // 本地再搜一次主机
    searchGatewaysWtihCompletion(^(BOOL success, NSArray *gateways) {
        //DLog(@"success == %d",success);
    });
    
    
    KReturnValue value = self.serverLoginValue;
    // 只要远程或本地有一处登录成功，就认为登录成功
    if ((self.serverLoginValue == KReturnValueSuccess)
        || (self.localLoginValue == KReturnValueSuccess)) {
        
        value = KReturnValueSuccess; // 认为登录成功
        
        self.isLogin = YES;
        [HMBaseAPI postNotification:kNOTIFICATION_LOGIN_SUCCESS object:nil];
        
        [HMBaseAPI postNotification:KNOTIFICATION_ACCOUNT_SWITCH object:nil];
        
        // 保存widget登录信息
        [self widgetSaveUserInfo];
        
    }else if (value == KReturnValueFamilyEmpty){
        
        self.isLogin = YES;
        // 保存widget登录信息
        [self widgetSaveUserInfo];
    }
    
    
    if (completion) {
        completion(value);
    }
    
    [self loginFinish:value];
    
    [HMBaseAPI postNotification:kNOTIFICATION_LOGIN_FINISH object:@(value)];
    
}



-(void)loginFinish:(KReturnValue)value
{
    [self performOutsideTasks];
    DLog(@"============登录完成，总共耗时：%fs",CACurrentMediaTime() - beginTimeStamp);
    
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate loginFinish:value];
    }
}
@end
