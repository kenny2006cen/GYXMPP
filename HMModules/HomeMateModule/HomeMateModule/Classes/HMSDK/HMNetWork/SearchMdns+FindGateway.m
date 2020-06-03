//
//  SearchMdns+FindGateway.m
//  HomeMate
//
//  Created by Air on 16/6/30.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "SearchMdns+FindGateway.h"
#import "HMConstant.h"


@implementation SearchMdns (FindGateway)

-(void)autoFindGateway:(commonBlockWithObject)completion
{
    LogFuncName();
    
    if (completion) {
        
        __weak typeof(self) weakSelf = self;
        
        // 当前账号没有绑定zigbee主机的情况下才搜索未绑定的主机
        if (userAccout().isLogin && (!userAccout().hasZigbeeHost)) {
            
            DLog(@"开始搜索zigbee主机");
            [weakSelf searchGatewaysWtihCompletion:^(BOOL success, NSArray *gateways) {
                
                // 查找到主机，大小主机一起
                if (success) {
                    
                    DLog(@"搜索zigbee主机完毕，共搜索到%d台主机",(int)(gateways.count));
                    
                    [weakSelf queryGateways:gateways completion:completion];
                }else{
                    
                    DLog(@"未搜索到Zigbee主机");
                    completion(KReturnValueFail,nil);
                }
                
            }];
        }else{
            
            DLog(@"未登录或者已经有了Zigbee主机");
            completion(KReturnValueFail,nil);
        }
    }
}

-(void)queryGateways:(NSArray *)gateways completion:(commonBlockWithObject)completion
{
    __weak typeof(self) weakSelf = self;
    
    // 本地搜索到的主机
    NSArray *searchedUidArray = [gateways valueForKey:@"uid"];
    [HMHubAPI queryBindStatusWithUidList:searchedUidArray completion:^(KReturnValue value, NSDictionary *dic) {
        
        DLog(@"queryBindStatusWithUidList : 返回状态码：%d",value);
        if (value == KReturnValueSuccess) {
            
            NSArray *bindListArray = [dic objectForKey:@"bindList"];
            
            // 服务器返回已被绑定的主机
            NSArray *bindedUidArray = [bindListArray valueForKey:@"uid"];
            
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT self.uid in (%@)",bindedUidArray];
            NSArray *notBindedArray = [gateways filteredArrayUsingPredicate:pred];
            
            if (notBindedArray.count == 0) {
                DLog(@"本地搜索到的主机都被绑定");
                completion(KReturnValueFail,nil);
            }else{
                [weakSelf preBindGateway:notBindedArray completion:completion];
            }
            
            
        }else {
            [weakSelf preBindGateway:gateways completion:completion];
        }
    }];
}

-(void)preBindGateway:(NSArray *)searchedGateways completion:(commonBlockWithObject)completion
{
    LogFuncName();
    
    NSArray *array = searchedGateways;
    NSUInteger total = array.count;
    
    NSMutableArray *unbindArray = [NSMutableArray array];
    NSMutableArray *loginSuceessArray = [NSMutableArray array];
    
    __block NSUInteger notBindCount = 0;
    __block NSUInteger loginSuccessCount = 0;
    __block NSUInteger loginFailedCount = 0;
    
     __block BOOL returnAlready = NO;
    
    for (Gateway *gateway in array) {
        
        LoginCmd *lgCmd = [HMLoginAPI cmdWithUserName:userAccout().userName password:userAccout().password uid:gateway.uid];
        
        [gateway sendCmd:lgCmd completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
            
            if (returnAlready){
                DLog(@"已查找到主机直接返回");
                return;
            }
            
            // 直接登录成功
            if (returnValue == KReturnValueSuccess){
                
                DLog(@"gateway uid == %@,IP == %@ 登录成功，主机里面的绑定信息未失效，此时应直接把绑定关系添加回来",gateway.uid,gateway.host);
                // 登录成功，意味着主机里面的绑定信息未失效，此时应直接把绑定关系添加回来，并读取表数据，然后开组网进入设备搜索流程
                
                [loginSuceessArray addObject:gateway];
                loginSuccessCount ++;
                
                if (!returnAlready) {
                    
                    DLog(@"没有绑定关系但是登录成功一台主机，立即返回");
                    returnAlready = YES;
                    completion(KReturnValueSuccess,gateway);
                }
                
            }
            // 主机未绑定用户信息或者绑定信息已经被重置
            else if (returnValue == KReturnValueMainframeRest) {
                
                DLog(@"\n\n gateway uid == %@,IP == %@ 该主机未被绑定\n\n",gateway.uid,gateway.host);
                
                [unbindArray addObject:gateway];
                
                notBindCount ++;
                
                if (!returnAlready && gateway.deviceType == KDeviceTypeAlarmHub) {
                    
                    DLog(@"找到一台未被绑定的报警主机，立即返回");
                    returnAlready = YES;
                    completion(KReturnValueSuccess,gateway);
                }
                
                if (!returnAlready && gateway.isMiniHub) {
                    
                    DLog(@"找到一台未被绑定的小主机，立即返回");
                    returnAlready = YES;
                    completion(KReturnValueSuccess,gateway);
                }
            }
            else {
                
                loginFailedCount ++;
                
                if (returnValue == KReturnValueNotBindMainframe) {
                    DLog(@"gateway uid == %@,IP == %@ 该用户名未绑定到本主机",gateway.uid,gateway.host);
                }else{
                    DLog(@"gateway uid == %@,IP == %@ 登录命令失败，错误码：%d",gateway.uid,gateway.host,returnValue);
                }
            }
            
            BOOL finish = (loginSuccessCount + notBindCount + loginFailedCount == total);
            
            if (finish) {
                
                DLog(@"所有主机尝试登录完毕");
                
                if (!returnAlready) {
                    returnAlready = YES;
                    
                    if (unbindArray.count) {
                        NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.isMiniHub = %d",YES];
                        NSArray *miniHubs = [unbindArray filteredArrayUsingPredicate:pred];
                        
                        // 发现小主机，则优先返回小主机
                        if (miniHubs.count) {
                            completion(KReturnValueSuccess,miniHubs.firstObject);
                        }else{
                            completion(KReturnValueSuccess,unbindArray.firstObject);
                        }
                    }else{
                        completion(KReturnValueFail,nil);
                    }
                }
                
                
            }else{
                DLog(@"未全部尝试登录完毕");
            }
        }];
        
    }
}

@end
