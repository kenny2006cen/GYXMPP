//
//  HMTaskManager.m
//  HomeMateSDK
//
//  Created by 管理员 on 2017/4/16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMTaskManager.h"
#import "RequestKeyCmd.h"
#import "HMLoginBusiness+Token.h"
#import "AccountSingleton+Widget.h"
#import "BaseCmd.h"
#import "GlobalSocket.h"
#import "HMStorage.h"

typedef enum : NSUInteger{
    
    HMDefault,
    
    HMDisconnected,
    HMConnecting,
    HMConnectFailed,
    HMConnectSuccess,
    
    HMRequestingKey,
    HMRequestKeyFailed,
    HMRequestKeySuccess,
    
    HMLogining,
    HMLoginFailed,
    HMLoginSuccess
    
}HMPrepareState;


@interface HMRequestQueue:NSObject

+(instancetype)queue;
-(void)push:(id)object;
-(id)pop;
-(NSUInteger)count;

@end


@interface HMRequestQueue()

@property(nonatomic,strong)NSLock *lock;
@property(nonatomic,strong)NSMutableArray *queue;

- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (void)removeAllObjects;

@end
@implementation HMRequestQueue

+(instancetype)queue
{
    HMRequestQueue *queue = [[HMRequestQueue alloc]init];
    if (queue) {
        queue.lock = [[NSLock alloc]init];
        queue.queue = [NSMutableArray array];
    }
    return queue;
}

-(void)push:(id)object
{
    //LogFuncName();
    if (![self.queue containsObject:object]) {
        
        [self addObject:object];
        
    }else{
        DLog(@"已经添加了此对象：%@",object);
    }
    
}

-(id)pop
{
    //LogFuncName();
    id object = [self firstObject];
    if (object) {
        
        [self removeObject:object];
        
        return object;
    }
    return nil;
}

- (id)firstObject{
    return self.queue.firstObject;
}

- (void)addObject:(id)object
{
    if (object) {
        
        [_lock lock];
        [self.queue addObject:object];
        [_lock unlock];
    }
}
- (void)removeObject:(id)object
{
    [_lock lock];
    [self.queue removeObject:object];
    [_lock unlock];
}
- (void)removeAllObjects
{
    [_lock lock];
    [self.queue removeAllObjects];
    [_lock unlock];
}
-(NSUInteger)count
{
    return self.queue.count;
}
-(NSString *)description{
    return self.queue.description;
}
@end


@interface HMTaskManager()

@property (nonatomic,assign)HMPrepareState state;

@property (nonatomic,strong) HMRequestQueue *requestQueue;

@property (nonatomic,weak) id <StateMachineProtocol> gateway;

@property (nonatomic,weak) id <HMBusinessProtocol> delegate;

@property (nonatomic,assign) BOOL isPwdLogined;

/// 登录类型
@property (nonatomic,assign) HMUserLoginType loginType;

-(void)addTask:(BaseCmd *)cmd;

@end

@implementation HMTaskManager
@synthesize delegate = theDelegate;

+(instancetype)stateWithDelegate:(id<StateMachineProtocol>)gateway
{
    HMTaskManager *state = [[HMTaskManager alloc]init];
    state.gateway = gateway;
    state.requestQueue = [HMRequestQueue queue];
    return state;
}

-(id <HMBusinessProtocol>)delegate
{
    if (theDelegate) {
        return theDelegate;
    }
    return [HMStorage shareInstance].delegate;
}

-(void)addTask:(BaseCmd *)cmd
{
    DLog(@"cacheCmd: %@",cmd);
    [self.requestQueue push:cmd];
}
-(void)removeAllTasks
{
    DLog(@"removeAllTasks: %@",self.requestQueue);
    [self.requestQueue removeAllObjects];
}
+(BOOL)isNeedLogin:(BaseCmd *)cmd
{
    if(cmd.cmd == VIHOME_CMD_RK   // 获取通信密钥
    
       //31，49，50，51，68，69，74
     || cmd.cmd == VIHOME_CMD_GSC    // 获取验证码命令不需要登录
     || cmd.cmd == VIHOME_CMD_CSC    // 校验验证码命令不需要登录
     || cmd.cmd == VIHOME_CMD_RST    // 注册命令不需要登录
     
     || cmd.cmd == VIHOME_CMD_RS             //reset 31
     || cmd.cmd == VIHOME_CMD_GETEMAILCODE   //获取邮箱验证码接口 get email code
     || cmd.cmd == VIHOME_CMD_CHECKEMAILCODE //校验邮箱验证码接口 check email code
     || cmd.cmd == VIHOME_CMD_RESETPASSWORD  //重置用户密码接口  reset password
     || cmd.cmd == VIHOME_CMD_GB             // 主机绑定命令，不需要登录
     || cmd.cmd == VIHOME_CMD_UBD            // 查询局域网内未绑定的设备列表，不需要登录
     || cmd.cmd == VIHOME_CMD_THIRD_REG      // 第三方登陆的注册命令
     || cmd.cmd == VIHOME_CMD_THIRD_VERIFY   //第三方登陆验证是否已经注册命令
       ){
        
        //DLog(@"cmd = %@ 不需要登录",NSStringFromClass([cmd class]));
        return NO;
    }
    
    //DLog(@"cmd = %@ 需要登录",NSStringFromClass([cmd class]));
    return YES;
}

-(HMUserLoginType)userLoginType{
    return self.loginType;
}

-(BOOL)isConnected
{
    return (self.state == HMLoginSuccess);
}
-(BOOL)isReady:(BaseCmd *)cmd {
    
    if (HMConnecting == self.state) {
        DLog(@"isReady - Connecting");
        
        [self addTask:cmd];
        return NO;
    }
    
    if (HMRequestingKey == self.state) {
        DLog(@"isReady - RequestingKey");
        
        [self addTask:cmd];
        return NO;
    }
    
    // 如果当前指令不需要登录，那么只判断 [socket isConnected] 和 socket.encryptionKey 即可
    BOOL stateOK = (self.state >= HMRequestKeySuccess);
    
    if (stateOK && [[self class] isNeedLogin:cmd]) {
        
        stateOK = (self.state == HMLoginSuccess);
    }
    
    // 如果状态有问题，则缓存指令，尝试修正状态
    if (!stateOK) {
        
        [self addTask:cmd];
        [self prepare];
    }
    return stateOK;
}


-(void)prepareLogin:(SocketCompletionBlock)completion{
    
    LogFuncName();
    
    GlobalSocket *socket =  [self.gateway socket];
    BOOL stateOK = ([socket isConnected] && socket.encryptionKey && (self.state == HMLoginSuccess));

    if (stateOK && completion) {
        
        completion(KReturnValueSuccess,nil);
        return;
    }
    
    self.state = HMLogining;
    
    BaseCmd *cmd = [self.requestQueue firstObject];
    if (cmd) {
        
        // 登录命令
        if (cmd.cmd == VIHOME_CMD_CL                // 账号密码登录
            || cmd.cmd == VIHOME_CMD_ONEKEY_LOGIN   // 一键登录
            || cmd.cmd == VIHOME_CMD_TOKEN_LOGIN    // token登录
            || cmd.cmd == VIHOME_CMD_SMS_CODE_LOGIN // 验证码登录
            || cmd.cmd == VIHOME_CMD_ONE_KEY_LOGIN_BY_VERIFY) { // 手机号验证登录
            
            // 如果当前发送的指令就是登录指令，则把当前指令弹出队列
            // 避免登录成功之后执行缓存的命令时再执行一遍
            [self.requestQueue pop];
            DLog(@"当前需要发送的指令就是登录命令:%@",cmd);
            
            SocketCompletionBlock finishBlock = cmd.finishBlock;
            
            SocketCompletionBlock block = ^(KReturnValue returnValue , NSDictionary *returnDic){
                if (completion) {
                    completion(returnValue,returnDic);
                }
                
                if (finishBlock) {
                    finishBlock(returnValue,returnDic);
                }
            };
            
            cmd.finishBlock = block;
            
            [self.gateway didSendCmd:cmd completion:block];
            return;
            
        }else if (![[self class] isNeedLogin:cmd]){
            // 此命令不需要登录，则修改状态，然后直接发送此命令即可

            [self.requestQueue pop];
            [self.gateway didSendCmd:cmd completion:cmd.finishBlock];
            
            return;
        }
    }else{
        DLog(@"prepareLogin --- 没有等待发送的指令");
    }
    
    // 非自动登录状态，则返回命令处理失败
    if (!userAccout().isLogin) {
        
        DLog(@"非自动登录状态，则返回命令处理失败：cmd：%@",cmd);
        if (completion) {
            completion(KReturnValueFail,nil);
        }
        return;
    }
    // 自动登录
    __weak typeof(self) weakSelf = self;
    if (userAccout().isWidget) {
        DLog(@"widget自动登录");
        [userAccout() widgetLoginWithDict:nil completion:^(KReturnValue value) {
            if (completion) {
                completion(value,nil);
            }
        }];
        return;
    }
    
    if ([HMLoginBusiness canUseTokenLogin]) {
        DLog(@"token自动登录");
        HMLocalAccount *accout = [HMLocalAccount objectWithUserId:userAccout().userId];
        HMTokenLoginCmd *lgCmd = [HMTokenLoginCmd object];
        lgCmd.accessToken = accout.token;
        lgCmd.sendToServer = YES;
        [self.gateway didSendCmd:lgCmd completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
            
            if (completion) {
                completion(returnValue,returnDic);
            }
            
            if(returnValue == KReturnValueLoginTokenExpired){ // Token失效
                DLog(@"Token失效时弹框提示");
                [weakSelf logoutForTokenExpired];
            }
        }];
        return;
    }
    
    DLog(@"用户名密码自动登录");
    LoginCmd *lgCmd = [HMLoginAPI cmdWithUserName:userAccout().userName password:userAccout().password];
    
    [self.gateway didSendCmd:lgCmd completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (completion) {
            completion(returnValue,returnDic);
        }
        
        if(returnValue == KReturnValueAccountOrPWDERR){
            
            DLog(@"用户名密码错误时弹框提示");
            [weakSelf logoutForPwdError];
        }
    }];
}

-(void)prepareEncryptionKey:(SocketCompletionBlock)completion{
    
    LogFuncName();
    
    __weak GlobalSocket *socket =  [self.gateway socket];
    if ([socket isConnected] && socket.encryptionKey) {
        
        DLog(@"已有通信密钥：%@",socket.encryptionKey);
        
        if (completion) {
            completion(KReturnValueSuccess,nil);
        }
        
        return;
    }
    
    self.state = HMRequestingKey;
    socket.encryptionKey = nil;
    
    RequestKeyCmd *reqCmd = [RequestKeyCmd object];
    [self.gateway didSendCmd:reqCmd completion:completion];
}

-(void)didSocetConnected:(BOOL)connected completion:(SuccessBlock)completion
{
    // 建立链接是在子线程进行的，回调block中有可能有UI操作，所以回调block应该在主线程中调用
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (completion) {
            completion(connected);
        }
    });
}
-(void)prepareConnection:(SuccessBlock)completion{
    
    LogFuncName();
    
    __weak typeof(self) weakSelf = self;
    
    __weak GlobalSocket *socket =  [self.gateway socket];
    
    if ([socket isConnected]) {
        
        DLog(@"[socket isConnected] = YES");
        [weakSelf didSocetConnected:YES completion:completion];
        return;
    }
    
    self.state = HMConnecting;
    socket.encryptionKey = nil;
    // 异步等待
    __block NSInteger tryTimes = 0;
    NSInteger maxTryTimes = 8;
    NSTimeInterval interval = 1.0; // 间隔1.0s执行一次
    gcdRepeatTimer(interval, ^BOOL{
        
        tryTimes++;
        /*if (userAccout().isEnterBackground){
            
            DLog(@"进入后台，立即结束任务");
            [weakSelf didSocetConnected:NO completion:completion];
            
        }else 后台需要继续处理socket任务，继续尝试建立socket连接*/
        if ([socket isConnected]){
            
            DLog(@"[socket isConnected] = YES ，已等待 %d 秒",tryTimes);
            [weakSelf didSocetConnected:YES completion:completion];
            
        }
        /*else if ([socket isDisconnected]){
         
         DLog(@"[socket isDisconnected] = YES ，已等待 %d 秒",tryTimes);
         [weakSelf didSocetConnected:NO completion:completion];
         
         }*/
        else if(tryTimes >= maxTryTimes) {
            
            DLog(@"socket 尝试连接 %d次，仍然失败",tryTimes);
            socket.connectFailed = YES;
            [weakSelf didSocetConnected:NO completion:completion];
            
        }else{
            
            if ([socket isDisconnected]){
                DLog(@"[socket isDisconnected] = YES ，已等待 %d 秒",tryTimes);
                socket.connectFailed = YES;
            }
            
            NSString *theHost = self.gateway.host;
            uint16_t thePort = self.gateway.port;
            
            DLog(@"尝试重新连接 %d次 Host:%@ Port:%d",tryTimes,theHost,thePort);
            
            NSError *err = nil;
            if (![socket connectToHost:theHost onPort:thePort error:&err]) {
                DLog(@"tcp 仍然未连接成功");
                
                // 4s还未连接成功，则断开重连
                if (tryTimes % 4 == 0) {
                    [socket disconnect];
                }
            }
            
            return NO; // 继续循环尝试连接 server
        }
        return YES; // 执行到此处就停止timer
    }, nil);
}


-(void)reset
{
    // 当前正在尝试建立连接，则继续尝试
    if (HMConnecting == self.state) {
        DLog(@"reset - Connecting");
        return;
    }
    
    // 否则重置状态
    self.state = HMDisconnected;
    DLog(@"reset - Disconnected");
}

-(void)prepare{
    
    //LogFuncName();
    
    if (HMConnecting == self.state) {
        DLog(@"prepare - Connecting");
        return;
    }
    
    if (HMRequestingKey == self.state) {
        DLog(@"prepare - RequestingKey");
        return;
    }
    
    [self didPrepare];
}

-(void)didPrepare
{
    //LogFuncName();
    
    __weak typeof(self) weakSelf = self;
    
    // 尝试建立 socket 链接
    [self prepareConnection:^(BOOL connected) {
        
        if (connected) {
            
            weakSelf.state = HMConnectSuccess;
            // 尝试申请通信密钥
            [self prepareEncryptionKey:^(KReturnValue value , NSDictionary *returnDic) {
                
                if (value == KReturnValueSuccess) {
                    
                    weakSelf.state = HMRequestKeySuccess;
                    
                    [self prepareLogin:^(KReturnValue returnValue , NSDictionary *returnDic) {
                        
                        if (returnValue == KReturnValueSuccess) {
                            int cmd = [returnDic[@"cmd"]intValue];
                            switch (cmd) {
                                case VIHOME_CMD_CL://账号密码
                                    weakSelf.loginType = HMUserLoginType_Account;
                                    break;
                                case VIHOME_CMD_TOKEN_LOGIN://token登录
                                    weakSelf.loginType = HMUserLoginType_Token;
                                    break;
                                case VIHOME_CMD_ONEKEY_LOGIN://一键登录
                                case VIHOME_CMD_ONE_KEY_LOGIN_BY_VERIFY://一键登录
                                    weakSelf.loginType = HMUserLoginType_PhoneOneKey;
                                    break;
                                case VIHOME_CMD_SMS_CODE_LOGIN://验证码登录
                                    weakSelf.loginType = HMUserLoginType_PhoneSmsCode;
                                    break;
                            }
                            weakSelf.state = HMLoginSuccess;
                            // 通知RemoteGateway 发送所有缓存的指令
                            [weakSelf sendAllCachedCmds];
                            
                        }else{
                            // 登录失败
                            weakSelf.state = HMLoginFailed;
                            
                            /** 用户名或者密码错误 */
                            if (returnValue == KReturnValueAccountOrPWDERR) {
                                
                                DLog(@"用户名或者密码错误");
                                [weakSelf removeAllTasks];
                                
                            }else{
                                
                                //给缓存的那些指令返回结果
                                [weakSelf returnCmdFailed:returnValue];
                            }
                        }
                    }];
                    
                }else{
                    // 再次尝试 申请通信密钥
                    weakSelf.state = HMRequestKeyFailed;
                    [weakSelf returnCmdFailed:value];
                }
            }];
            
        }else{
            
            // 建立 socket 链接失败
            weakSelf.state = HMConnectFailed;
            [weakSelf returnCmdFailed:KReturnValueConnectError];
        }
    }];

}

-(void)returnCmdFailed:(KReturnValue)error
{
    LogFuncName();
    while ([self.requestQueue count]) {
        
        BaseCmd *cmd = [self.requestQueue pop];
        if (cmd.finishBlock) {
            cmd.finishBlock(error, cmd.payload);
        }
    }
}

-(void)sendAllCachedCmds{
    
    LogFuncName();
    while ([self.requestQueue count]) {
        
        BaseCmd *cmd = [self.requestQueue pop];
        [self.gateway didSendCmd:cmd completion:cmd.finishBlock];
    }
}

/**
 *  后台自动登录时，服务器返回用户名密码错误
 */
-(void)logoutForPwdError
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate logoutForPwdError];
    }
}

/**
 *  后台自动登录时，服务器返回登录token过期
*/
-(void)logoutForTokenExpired
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate logoutForTokenExpired];
    }
}
@end
