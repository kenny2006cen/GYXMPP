//
//  HMLoginBusiness+Local.m
//  HomeMateSDK
//
//  Created by Air on 2017/6/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMLoginBusiness+Local.h"

@implementation HMLoginBusiness (Local)

+(void)loginWithUserName:(NSString *)userName password:(NSString *)password uid:(NSString *)uid completion:(SocketCompletionBlock)completion{
    
    if (!uid) {
        
        DLog(@"参数错误，uid为空");
        if (completion) {
            completion(KReturnValueFail,nil);
        }
        
        return;
    }
    
    // 3: 按家庭登录
    LoginCmd *lgCmd = [HMLoginBusiness cmdWithUserName:userName password:password uid:uid type:3];
    sendCmd(lgCmd, completion);
}

+(void)localLoginWithUserName:(NSString *)userName password:(NSString *)password completion:(SocketCompletionBlock)completion
{
    LogFuncName();
    
    __weak typeof(self) weakSelf = self;
    
    // WiFi 情况下本地搜索主机并登录
    if (isEnableWIFI()) {
        
        DLog(@"开始搜索zigbee主机");
        [[SearchMdns shareInstance] searchGatewaysWtihCompletion:^(BOOL success, NSArray *gateways) {
            
            // 查找到主机，大小主机一起
            if (success) {
                
                DLog(@"搜索zigbee主机完毕，共搜索到%d台主机",(int)(gateways.count));
                [weakSelf preLoginGateway:gateways userName:userName password:password completion:completion];
                
            }else{
                
                DLog(@"未搜索到Zigbee主机");
                if (completion) {
                    completion(KReturnValueFail,nil);
                }
            }
            
        }];
    }else{
        
        DLog(@"非WiFi状态，不再局域网搜索主机");
        if (completion) {
            completion(KReturnValueFail,nil);
        }
    }
}

+(void)preLoginGateway:(NSArray *)searchedGateways userName:(NSString *)userName
              password:(NSString *)password completion:(SocketCompletionBlock)completion
{
    LogFuncName();
    
    NSArray *array = searchedGateways;
    NSUInteger total = array.count;
    
    __block NSUInteger loginSuccessCount = 0;
    __block NSUInteger loginFailedCount = 0;
    
    for (Gateway *gateway in array) {
        
        LoginCmd *lgCmd = [HMLoginAPI cmdWithUserName:userName password:password uid:gateway.uid];
        
        [gateway sendCmd:lgCmd completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
            
            if (returnValue == KReturnValueSuccess){
                
                loginSuccessCount ++;
                DLog(@"第%d台主机登录成功，gateway uid == %@,IP == %@",loginSuccessCount,gateway.uid,gateway.host);
                
                // 第一台登录成功后处理拿到的数据
                if (1 == loginSuccessCount) {
                    
                    [self localLoginSuccess:userName password:password returnDic:returnDic];
                }
                
            }else {
                
                loginFailedCount ++;
                
                // 主机未绑定用户信息或者绑定信息已经被重置
                if (returnValue == KReturnValueMainframeRest) {
                    
                    DLog(@"\n\n gateway uid == %@,IP == %@ 该主机未被绑定\n\n",gateway.uid,gateway.host);
                }
                else if (returnValue == KReturnValueNotBindMainframe) {
                    DLog(@"gateway uid == %@,IP == %@ 该用户名未绑定到本主机",gateway.uid,gateway.host);
                }else{
                    DLog(@"gateway uid == %@,IP == %@ 登录命令失败，错误码：%d",gateway.uid,gateway.host,returnValue);
                }
            }
            
            BOOL finish = (loginSuccessCount + loginFailedCount == total);
            
            if (finish && completion) {
                
                DLog(@"%d台主机登录成功，%d台主机登录失败",loginSuccessCount,loginFailedCount);
                
                if (loginSuccessCount > 0) {
                    // 至少成功一台就认为成功
                    completion(KReturnValueSuccess,nil);
                }else{
                    // 全部失败则认为失败
                    completion(KReturnValueFail,nil);
                }

            }else{
                DLog(@"未全部尝试登录完毕");
            }
        }];
    }
}

+(void)localLoginSuccess:(NSString *)userName password:(NSString *)password returnDic:(NSDictionary *)returnDic
{
    
    NSString *userId = returnDic[@"userId"];
    
    DLog(@"userAccout().userId:%@ userId:%@",userAccout().userId,userId);
    
    if (userId && (![userId isEqualToString:userAccout().userId])) {
        
        DLog(@"本地登录返回了当前用户名密码对应的userId，和当前获取到的userId不一致，更新userId");
        
        [userAccout() addLocalAccountWithUserName:userName password:password userId:userId];
    }
    
    NSArray *familyArray = returnDic[@"familyList"];
    
    if (familyArray && [familyArray isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary *familyDic in familyArray) {
            
            HMFamily *hostFamily = [HMFamily objectFromDictionary:familyDic];
            HMFamily *dbFamily = [HMFamily familyWithFamilyId:hostFamily.familyId userId:userId];
            // 本地没有这个家庭的信息，则插入
            if (!dbFamily) {
                DLog(@"本地没有此家庭：%@ id:%@",hostFamily.familyName,hostFamily.familyId);
                hostFamily.userId = userId;
                [hostFamily insertObject];
            }
            
            if (!userAccout().familyId) {
                DLog(@"远程登录失败，未成功获取家庭信息，则使用本地主机返回的家庭信息");
                userAccout().familyId = hostFamily.familyId;
            }
        }
    }
}

@end
