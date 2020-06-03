//
//  Gateway+HeartBeat.m
//  Vihome
//
//  Created by Air on 15-3-16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "Gateway+HeartBeat.h"
#import "HMConstant.h"

@implementation Gateway (HeartBeat)

#pragma mark - 心跳包相关 ---
#if 1
-(void)beginSendHeartbeat
{
    //[self sendHeartbeat];
    
    DLog(@"每三分钟发送一个心跳包");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self stopHeartbeat];// 先停止旧的心跳包发送
        self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:kHeartBeatTime target:self
                                                             selector:@selector(sendHeartbeat)
                                                             userInfo:nil repeats:YES];
    });
}
// 发送心跳包
-(void)sendHeartbeat
{
    // 未登录情况下不再发送心跳包
    if (!userAccout().isLogin) {
        return;
    }
    if (isEnableWIFI() && ([self.localSsid isEqualToString:[HMNetworkMonitor getSSID]])) {
        
        // 本地心跳包
        HeartbeatCmd * hbReq = [HeartbeatCmd object];
        hbReq.userName = userAccout().userName;
        hbReq.uid = self.uid;
        
        sendCmd(hbReq, ^(KReturnValue returnValue, NSDictionary *returnDic) {
            
            BOOL success = (returnValue == KReturnValueSuccess);
            DLog(@"发送到gateway: %@ 心跳包%@ 状态码: %d",self.uid,success ? @"成功" : @"失败",returnValue);
        });
        
    }else {
        
        DLog(@"无网络，不发送心跳包");
    }
}

-(void)stopHeartbeat
{
    [self.heartBeatTimer invalidate];
    self.heartBeatTimer = nil;
}

#endif
#pragma mark - 心跳包相关 ---

@end
