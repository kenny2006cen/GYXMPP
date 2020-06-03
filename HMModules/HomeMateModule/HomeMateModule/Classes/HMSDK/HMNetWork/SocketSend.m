 //
//  SocketSend.m
//  ABB
//
//  Created by orvibo on 14-5-22.
//  Copyright (c) 2014年 orvibo. All rights reserved.
//

#import "SocketSend.h"
#import "Gateway+Send.h"
@interface SocketSend ()

@end

@implementation SocketSend
@synthesize delegate = theDelegate;

-(id <SocketSendBusinessProtocol>)delegate
{
    if (theDelegate) {
        return theDelegate;
    }
    return [HMStorage shareInstance].delegate;
}

-(id)init
{
    self = [super init];
    if (self) {
        
        //[self uploadExceptionInfo]; // 发送异常信息
        //[self uploadBackupInfo];// 发送备份信息
    }
    return self;
}

+ (SocketSend *)shareInstance
{
    static SocketSend *__singletion;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __singletion = [[self alloc] init];
        [__singletion hm_addNotification:kNOTIFICATION_AUTO_DISAPPEAR_LOADING selector:@selector(cancelLoading) object:nil];
        
    });
    
    return __singletion;
}

-(void)popAlert:(NSString *)alert
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate popAlert:alert];
    }
}
-(void)displayLoading
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate displayLoading];
    }

}

-(void)stopLoading
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate stopLoading];
    }
}

-(void)cancelLoading
{
    [SocketSend cancelLoading];
}
+(void)cancelLoading
{
    SocketSend *weakSelf = [SocketSend shareInstance];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf];
    [weakSelf stopLoading];
}
-(void)onlySendData:(BaseCmd *)cmd
{
    Gateway *gateway = [self gatewayWithCmd:cmd];
    [gateway onlySendData:cmd];
}

#pragma mark -
#pragma mark - 下面的接口发送失败后直接返回结果，不自动重发
- (void)onlySendCmd:(BaseCmd *)cmd completion:(SocketCompletionBlock)completion
{
    Gateway *gateway = [self gatewayWithCmd:cmd];
    cmd.resendTimes = kMaxTryTimes;
    [gateway sendCmd:cmd completion:completion];
}
#pragma mark -
#pragma mark - 下面的接口发送失败后会自动重新登录gateway（本地和远程都会尝试）
- (void)sendCmd:(BaseCmd *)cmd delegate:(id)deletage completion:(SocketCompletionBlock)completion
{
    [self sendCmd:cmd delegate:deletage loading:NO alertTimeout:NO completion:completion];
}

- (void)sendCmd:(BaseCmd *)cmd delegate:(id)deletage loading:(BOOL)loading alertTimeout:(BOOL)alert  completion:(SocketCompletionBlock)completion
{
    [self gatewayWithCmd:cmd].delegate = deletage;
    [self sendCmd:cmd loading:loading alertTimeout:alert completion:completion];
}

- (void)sendCmd:(BaseCmd *)cmd loading:(BOOL)loading alertTimeout:(BOOL)alert  completion:(SocketCompletionBlock)completion
{
    [self sendCmd:cmd loading:loading alertTimeout:alert delay:0.5 completion:completion];
}

- (void)sendCmd:(BaseCmd *)cmd loading:(BOOL)loading alertTimeout:(BOOL)alert delay:(NSTimeInterval)delay  completion:(SocketCompletionBlock)completion
{
    __block SocketSend *weakSelf = self;
    
    if ((!isNetworkAvailable()) && (!isEnableWIFI())) {
        DLog(@"----------------------------直没网络");
        completion(KReturnValueNetWorkProblem,nil);
        return;
    }
    if (loading) {
        // 如果 1秒能给出响应，就不出现loading页面
        [self performSelector:@selector(displayLoading) withObject:nil afterDelay:delay];
    }
    
    [self sendCmd:cmd completion:^(KReturnValue returnValue, NSDictionary *dic) {
        
        if (loading) {
            
            DLog(@"停止loading");
            //返回结果 则停止loading
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(displayLoading) object:nil];
            [weakSelf stopLoading];
        }

        completion(returnValue,dic);
        
    }];
}
-(Gateway *)gatewayWithCmd:(BaseCmd *)cmd
{
    // 如果uid为空，说明命令是直接发到服务器的
    if (cmd.sendToServer || (cmd.uid == nil)) {
        
        return getGateway(nil); // 获取 server
        
    }else if (cmd.sendToGateway && cmd.uid){

        Gateway *gateway = getGateway(cmd.uid);
        return gateway; // 仅限本地发送的指令
        
    }else if ([[RemoteGateway shareInstance]isSocketConnected]){
        // 远程socket链接正常，则优先发送指令到远程
        return getGateway(nil); // 获取 server
    }
    else{

        Gateway *gateway = getGateway(cmd.uid);
        if (gateway.isLocalNetwork) {
            return gateway;
        }
    }
    
    return getGateway(nil);
}


#pragma mark - 发送数据到主机 - 一次超时之后，下次重新登陆
- (void)sendCmd:(BaseCmd *)cmd completion:(SocketCompletionBlock)completion
{
    Gateway *gateway = [self gatewayWithCmd:cmd];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [gateway sendCmd:cmd completion:completion];
        
    });
}

@end
