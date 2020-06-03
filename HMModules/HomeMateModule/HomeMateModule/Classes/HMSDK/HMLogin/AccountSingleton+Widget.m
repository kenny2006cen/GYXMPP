//
//  AccountSingleton+Widget.m
//  HomeMate
//
//  Created by Air on 17/2/24.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "AccountSingleton+Widget.h"
#import "HMConstant.h"
#import <objc/runtime.h>

static NSString *const kWidgetCurrentUserInfoKey = @"widgetCurrentUserInfo";

@implementation AccountSingleton (Widget)

- (HMWidgetType)widgetType{
    return [objc_getAssociatedObject(self, @"widgetType") intValue];
}

-(void)setWidgetType:(HMWidgetType)widgetType{
    objc_setAssociatedObject(self, @"widgetType", @(widgetType), OBJC_ASSOCIATION_ASSIGN);
}

-(NSDictionary *)widgetUserInfo{
    NSDictionary *userInfoDic = [self.widgetUserDefault dictionaryForKey:kWidgetCurrentUserInfoKey];
    return userInfoDic;
}

-(void)widgetSaveUserInfo
{
    LogFuncName();
    
    // widget登录情况下，不需要修改widgetUserDefault中的数据
    if (self.isWidget) return;
        
    HMLocalAccount *account = self.currentLocalAccount;
    
    NSString *userName = self.userName?:@"";
    NSString *password = self.password?:@"";
    NSString *userId   = self.userId?:@"";
    NSString *token = account.token?:@"";
    
    NSNumber *isConnectTestServer = @([HMSDK isSetConnectTestServer]);
    NSNumber *environment = @([HMSDK SDKEnvironment]);
    // 保存当前用户信息到公用的 widget
    NSMutableDictionary *userInfo = [@{@"token":token,@"userName":userName, @"password":password, @"userId":userId,@"isConnectTestServer":isConnectTestServer,@"SDKEnvironment":environment} mutableCopy];
    
    NSString *familyId = self.familyId;
    if (familyId) {
        [userInfo setObject:familyId forKey:@"familyId"];
    }
    
    NSString *identifier = phoneIdentifier();
    if (identifier){
        [userInfo setObject:identifier forKey:@"appSetupId"];
    }
    
    NSString *ip = [HMSDK memoryDict][@"ip"];
    if (ip) {
        [userInfo setObject:ip forKey:@"ip"];
    }
    [self.widgetUserDefault setObject:userInfo forKey:kWidgetCurrentUserInfoKey];
    [self.widgetUserDefault synchronize];
    
    DLog(@"保存到widgetUserDefault数据：%@",userInfo);
}

-(void)widgetRemoveUserInfo{
    [self.widgetUserDefault removeObjectForKey:kWidgetCurrentUserInfoKey];
    [self.widgetUserDefault synchronize];
}


/**
 *  登录接口，根据widget保存的数据登录，优先token登录，token登录失败则尝试账号密码登录
 *
 *  @param token   登录token
 *  @param completion 回调结果
 */
-(void)widgetLoginWithDict:(NSDictionary *)info completion:(commonBlock)completion{
    
    NSDictionary *userInfo = info?:[self widgetUserInfo];
    
    DLog(@"widgetUserDefault保存的数据：%@",userInfo);

    NSString *userName = userInfo[@"userId"];
    NSString *password = userInfo[@"password"];
    NSString *token = userInfo[@"token"];
    NSNumber *isConnectTestServer = userInfo[@"isConnectTestServer"];
    NSNumber *environment = userInfo[@"SDKEnvironment"];
    
    [HMSDK setConnectTestServer:[isConnectTestServer boolValue]];
    [HMSDK setSDKEnvironment:[environment unsignedIntValue]];
    
    self.currentPassword = password;
    self.currentUserName = userName;
    
    // 有token时，优先使用token登录
    if (!isBlankString(token)) {
        __weak typeof(self)weakSelf = self;
        [HMLoginAPI loginWithToken:token completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
            
            if (returnValue == KReturnValueSuccess) {
                if (completion) {
                    completion([weakSelf widgetLoginSuccess:returnDic]);
                }
            }else{
                // token登录失败，则尝试账号密码登录
                if (!isBlankString(userName) && !isBlankString(password)) {
                    [self widgetLoginWithUserName:userName password:password completion:completion];
                }else{
                    if (completion) {
                        completion(returnValue);
                    }
                }
            }
        }];
        
    }else {
        DLog(@"widget登录，Token为空");
        [self widgetLoginWithUserName:userName password:password completion:completion];
    }
    
    
    
    // 设备和情景控制时才需要局域网登录，安防和siri控制不需要
    if (self.widgetType == HMWidgetDevice || self.widgetType == HMWidgetScene) {
        
        DLog(@"开始局域网登录主机");
        [HMLoginAPI localLoginWithUserName:userName password:password completion:^(KReturnValue value, NSDictionary *returnDic) {
            DLog(@"本地登录主机完成：KReturnValue=%d",value);
        }];
    }
}

-(void)widgetLoginWithUserName:(NSString *)userName password:(NSString *)password completion:(commonBlock)completion
{
    DLog(@"当前登录账号：%@ 密码：%@",userName,password);
    
    __weak typeof(self)weakSelf = self;
    
    [HMLoginAPI loginWithUserName:userName password:password completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            returnValue = [weakSelf widgetLoginSuccess:returnDic];
        }
        
        if (completion) {
            completion(returnValue);
        }
    }];
}

-(KReturnValue)widgetLoginSuccess:(NSDictionary *)returnDic{
    
    // 主 App 登录的用户的信息
    NSDictionary *userInfoDic = [self widgetUserInfo];
    NSString *lastFamilyId = userInfoDic[@"familyId"];
    
    __weak typeof(self)weakSelf = self;
    DLog(@"登录成功");
    NSString * validFamilyId = nil;
    NSString *userId = returnDic[@"userId"];
    weakSelf.userId = userId;
    
    KReturnValue returnValue = KReturnValueSuccess;
    
    NSArray *familyList = returnDic[@"familyList"];
    
    if (familyList && [familyList isKindOfClass:[NSArray class]] && [familyList count]) {
        
        // 家庭未失效，仍然可以查到当前家庭
        
        NSArray *familyIds = [familyList valueForKey:@"familyId"];
        if ([familyIds containsObject:lastFamilyId]) {
            
            DLog(@"上次选择的家庭有效，则读取当前家庭下面的所有设备数据信息");
            validFamilyId = lastFamilyId;
            
        }else{
            DLog(@"上次选择的家庭已失效，自动切换到默认家庭");
            
            validFamilyId = familyIds.firstObject;
            
            // 返回家庭失效的错误码，widget本地没有缓存新家庭的数据，应显示空页面
            returnValue = KReturnValueFamilyInvalid;
        }
        
        weakSelf.userId = userId;
        weakSelf.familyId = validFamilyId;
        
    }else{
        // 返回家庭失效的错误码，widget本地没有缓存新家庭的数据，应显示空页面
        returnValue = KReturnValueFamilyInvalid;
    }
    return returnValue;
}
@end
