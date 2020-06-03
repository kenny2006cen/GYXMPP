//
//  RemoteGateway.m
//  Vihome
//
//  Created by Air on 15-3-14.
//  Copyright © 2017年 orvibo. All rights reserved.
//


#import "RemoteGateway.h"
#import "Gateway+Tcp.h"
#import "HMTaskManager.h"
#import "HMConstant.h"
#import "HMThirdAccountId.h"
#import "HMStorage.h"

static NSString *specifiedIdcURL = @"https://lgs.orvibo.com/getHost?source=%@&idc=%d&sysVersion=iOS";

@interface RemoteGateway ()<StateMachineProtocol,GCDAsyncSocketDelegate>

@property (nonatomic, strong, readonly) GlobalSocket *remoteSocket;
@property (nonatomic, strong) NSString *remoteHost;
@property (nonatomic, strong) NSString *serverIP;
@property (nonatomic, strong) HMTaskManager *manager;

@end

@implementation RemoteGateway

+ (instancetype)shareInstance
{
    Singleton();
}
+(HMUserLoginType)userLoginType{
    return [[RemoteGateway shareInstance].manager userLoginType];
}
+(void)asyncRefreshServerIpWithCompletion:(VoidBlock)completion{
    dispatch_queue_t queue = dispatch_queue_create("com.orvibo.requestIP", NULL);
    dispatch_async(queue, completion);
}

+(VoidBlock)finishOnMainThread:(VoidBlock)completion{
    return ^{dispatch_async(dispatch_get_main_queue(),completion);};
}

+(void)refreshServerIpWithThirdId:(NSString *)thirdId completion:(VoidBlock)completion{
    
    [self asyncRefreshServerIpWithCompletion:^{
        [[RemoteGateway shareInstance]refreshServerIpWithThirdId:thirdId completion:[self finishOnMainThread:completion]];
    }];
}

+(void)refreshServerIpWithUserName:(NSString *)userName completion:(VoidBlock)completion{
    
    [self asyncRefreshServerIpWithCompletion:^{
        [[RemoteGateway shareInstance]refreshServerIpWithUserName:userName completion:[self finishOnMainThread:completion]];
    }];
}

+(void)refreshServerIpWithPhoneNumber:(NSString *)phoneNumber areaCode:(NSString *)areaCode completion:(VoidBlock)completion{
    
    [self asyncRefreshServerIpWithCompletion:^{
        [[RemoteGateway shareInstance] refreshServerIpWithPhoneNumber:phoneNumber areaCode:areaCode completion:[self finishOnMainThread:completion]];
    }];
}

+(void)updateServerIP:(NSString *)newServerIP{
    [[RemoteGateway shareInstance]updateServerIP:newServerIP];
}

#pragma mark ---------------------------------------------------------------------------------------

-(NSString *)lastServerIPKey:(NSString *)userName
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",@"LastServerIPKey",userName?:@""];
    DLog(@"%@",key);
    return key;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.sensorTableQueue = [NSMutableArray array];
        self.wifiTableQueue = [NSMutableArray array];
        self.manager = [HMTaskManager stateWithDelegate:self];
        // 默认情况下，根据上一次的用户信息获取IP
        // 如果用户手动登录，会再刷新一次IP
        [self refreshServerIP:^{
            [self.manager prepare];
        }];
    }
    return self;
}

-(void)refreshServerIpWithPhoneNumber:(NSString *)phoneNumber areaCode:(NSString *)areaCode completion:(VoidBlock)completion
{
    HMAccount *account = [HMAccount accountWithPhoneNumber:phoneNumber areaCode:areaCode];
    if (account) {
        [self getServerIpWithUserName:account.userId completion:completion];
    }else{
        // 如果没有，则根据phoneNumber && areaCode去查询IP信息
        NSString *source = [HMStorage shareInstance].appName ?: @"HomeMate";
        NSMutableString *urlString = [NSMutableString stringWithFormat:kGet_ServerIP_URL,source,0,@"",@"",@"",phoneNumber];
        [urlString appendFormat:@"&areaCode=%@",areaCode];
        
        NSString *key = [NSString stringWithFormat:@"%@_%@",phoneNumber,areaCode];
        [self getIpWithURL:urlString localKey:key completion:completion];
    }
}

-(void)refreshServerIpWithThirdId:(NSString *)thirdId completion:(VoidBlock)completion
{
    // 根据thirdId查询本地数据库是否有当前授权的账号信息，如果有，则使用已经存在的账号信息数据 idc userId thirdId
    NSString *userId = [HMThirdAccountId selectUserIdByThirdId:thirdId];
    if (userId) {
        [self getServerIpWithUserName:userId completion:completion];
    }else{
        // 如果没有，则根据thirdId去查询IP信息
        NSString *source = [HMStorage shareInstance].appName ?: @"HomeMate";
        NSMutableString *urlString = [NSMutableString stringWithFormat:kGet_ServerIP_URL,source,0,@"",@"",@"",@""];
        [urlString appendFormat:@"&thirdId=%@",thirdId];
        
        [self getIpWithURL:urlString localKey:thirdId completion:completion];
    }
    
}

-(void)refreshServerIpWithUserName:(NSString *)userName completion:(VoidBlock)completion
{
    [self getServerIpWithUserName:userName completion:completion];
}
// 根据上一次登录的用户名来查询的IP
-(void)refreshServerIP:(VoidBlock)completion
{
    if (userAccout().isWidget) {
        NSString *ip = userAccout().widgetUserInfo[@"ip"];
        if ([HMSDK isSetConnectTestServer]) {
            ip = [HMSDK testServerIP];
        }
        if (ip){
            DLog(@"widget直接使用主App保存的IP登录：%@",ip);
            [self updateServerIP:ip];
            return;
        }
    }
    
    if(userAccout().isLogin){
        DLog(@"已登录状态，根据上一次的用户信息获取IP");
        [self getServerIpWithUserName:userAccout().userId completion:completion];
    }else{
        DLog(@"非自动登录状态，需要用户手动刷新IP");
    }
}

-(void)getServerIpWithUserName:(NSString *)name completion:(VoidBlock)completion
{
    LogFuncName();
    
    // 默认值
    NSNumber *idc = @(0);
    NSMutableString *country = [NSMutableString stringWithString:@""];
    NSMutableString *state = [NSMutableString stringWithString:@""];
    NSMutableString *city = [NSMutableString stringWithString:@""];
    NSMutableString *urlString = [NSMutableString string];
    NSString *source = [HMStorage shareInstance].appName ?: @"HomeMate";
    // 指定了idc
    if ([HMStorage shareInstance].specifiedIdc) {
        
        idc = [HMStorage shareInstance].specifiedIdc;
        [urlString appendFormat:specifiedIdcURL,source,[idc intValue]];
        
    }else{ // 未指定idc的情况
                
        NSDictionary *dic = [HMUserDefaults objectForKey:kLocationDictionaryKey];
        if (dic) {
            [country setString:dic[@"country"]];
            [state setString:dic[@"state"]];
            [city setString:dic[@"city"]];
        }
        
        if (!isBlankString(name)) {
            HMAccount *account = [HMAccount accountWithName:name];
            if (account) {
                idc = @(account.idc);
                if (![account.country isEqualToString:@""]) {
                    [country setString:account.country];
                    [state setString:account.state];
                    [city setString:account.city];
                }
            }
        }
        
        NSString *userName = name?name.lowercaseString:@"";
        [urlString appendFormat:kGet_ServerIP_URL,source,[idc intValue],country,state,city,userName];
    }
    
    [self getIpWithURL:urlString localKey:name completion:completion];
}

-(void)getIpWithURL:(NSString *)urlString localKey:(NSString *)userName completion:(VoidBlock)completion{
        
    // 如果有网络就到服务器上查ip，没有网络就使用上次的ip
    if (isNetworkAvailable()) {
        
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        DLog(@"获取通信IP URL:%@",url);
        
        [self requestIP:url completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data) {
                
                NSDictionary *getHostDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                if (!error && getHostDic) {
                    
                    DLog(@"获取通信IP %@",getHostDic);
                    
                    NSNumber *errorCode = getHostDic[@"errorCode"];
                    if (errorCode.intValue == KReturnValueSuccess) {
                        
                        // 保存请求到的ip到本地
                        NSString *ip = getHostDic[@"ip"];
                        
                        // 消息记录页URL
                        [HMSDK memoryDict][@"recordUrl"] = getHostDic[@"recordUrl"];
                        [HMSDK memoryDict][@"ip"] = ip;
                        
                        if (ip) {
                            
                            [self didUpdateServerIP:ip];
                            
                            NSString *key = [self lastServerIPKey:userName];
                            [self saveObject:ip withKey:key];
                            
                            DLog(@"从服务器请求到通信ip:%@ 保存到本地key：%@",ip,key);
                            
                            if (completion) {
                                completion();
                            }
                        }else{
                            DLog(@"返回数据异常，没有ip字段，使用上次保存的ip");
                            [self getLocalSavedIpWithKey:userName completion:completion];
                        }
                    }else{
                        DLog(@"errorCode:%@ errorMessage:%@",errorCode,getHostDic[@"errorMessage"]);
                        DLog(@"使用上次保存的ip");
                        [self getLocalSavedIpWithKey:userName completion:completion];
                    }
                }else{
                    DLog(@"error:%@",error);
                    DLog(@"使用上次保存的ip");
                    [self getLocalSavedIpWithKey:userName completion:completion];
                }
            }else{
                DLog(@"获取通信ip，返回数据为空，使用上次保存的ip");
                [self getLocalSavedIpWithKey:userName completion:completion];
            }
        }];
    }else{
        DLog(@"没有网络，使用上次保存的ip");
        [self getLocalSavedIpWithKey:userName completion:completion];
    }
}

-(void)requestIP:(NSURL *)URL completion:(HMRequestBlock)completion{
//    dispatch_queue_t queue = dispatch_queue_create("com.orvibo.requestIP", NULL);
//    dispatch_async(queue, ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:3.0f];
        [request setHTTPMethod:@"GET"];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//        dispatch_async(dispatch_get_main_queue(),^{
            if (completion) {
                completion(data,nil,nil);
            }
//        });
//    });
}

-(void)getLocalSavedIpWithKey:(NSString *)userName completion:(VoidBlock)completion
{
    if (isBlankString(userName)) {
        if (completion) {
            completion();
        }
        return;
    }
    
    NSString *ip = [HMUserDefaults objectForKey:userName];
    if (ip) {
        
        DLog(@"上次从服务器请求到的通信ip:%@",ip);
        [self didUpdateServerIP:ip];
        
    }else{
        DLog(@"本地没有保存的ip地址信息");
    }
    if (completion) {
        completion();
    }
}
-(NSString *)serverIP
{
    if ([HMSDK isSetConnectTestServer]) {
        return [HMSDK testServerIP];
    }
    
    if (_serverIP) {
        return _serverIP;
    }
    return HM_DOMAIN_NAME;
}
-(void)didUpdateServerIP:(NSString *)newServerIP{
    DLog(@"断开旧的链接，重新建立新的链接 新IP:%@ 旧IP:%@",newServerIP,_serverIP);
    [self cancelTask];
    self.serverIP = newServerIP;
}

-(void)updateServerIP:(NSString *)newServerIP
{
    if ([HMSDK isSetConnectTestServer]){
        [HMSDK setTestServerIP:newServerIP];
    }
    [self didUpdateServerIP:newServerIP];
}

-(NSString *)session
{
    return _remoteSocket.session;
}

-(NSString *)uid
{
    return @"";
}

-(NSString *)remoteHost
{
    _remoteHost = [_remoteSocket connectedHost];
    return _remoteHost;
}
-(NSString *)host{
    
    if (self.remoteHost) {
        return _remoteHost;
    }
    return self.serverIP;
}
-(UInt16)port
{
    return 10002; // 增加SSL加密功能后，需要修改端口号
    //return HM_SERVER_PORT;
}

-(CGFloat)cmdTimeout
{
    return 5.0; // 远程超时时间设置为5.0s
}

-(BOOL)isSocketConnected
{
    return [self.manager isConnected];
}

-(BOOL)isLocalNetwork
{
    return NO;
}
#pragma mark - 远程链接
-(GlobalSocket *)socket
{
    if (!_remoteSocket) {
        //dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_queue_t queue = dispatch_queue_create("com.orvibo.remoteSocket", NULL);
        _remoteSocket = [[HMServerSocket alloc] initWithDelegate:self delegateQueue:queue];
        _remoteSocket.isConnectToServer = YES;
    }
    
    _remoteSocket.delegate = self;
    //DLog(@"远程通信密钥：%@",_remoteSocket.encryptionKey ?:@"无通信密钥");
    
    if ([_remoteSocket isDisconnected])
    {
        NSError *err = nil;
        DLog(@"====== 创建remote tcp链接 %@:%d ======", self.host, self.port);
        if (![_remoteSocket connectToHost:self.host onPort:self.port error:&err]) { // 创建tcp链接，失败
            DLog(@"创建tcp链接失败");
        }
    }
    
    
    return _remoteSocket;
}

-(LOGIN_TYPE)loginType
{
    return REMOTE_LOGIN;
}

-(void)sendHeartbeat
{
    if (isNetworkAvailable()) {
        // 远程心跳包
        HeartbeatCmd * hbReq = [HeartbeatCmd object];
        hbReq.sendToServer = YES;
        sendCmd(hbReq, ^(KReturnValue returnValue, NSDictionary *returnDic) {
            
            BOOL success = (returnValue == KReturnValueSuccess);
            DLog(@"发送到server 心跳包%@ 状态码: %d",success ? @"成功" : @"失败",returnValue);
        });
        
        [self checkHubOnlineStatus];
        
    }else {
        
        DLog(@"无网络，不发送心跳包");
    }
}

- (void)checkHubOnlineStatus {
    checkHubOnlineStatus();
}

- (void)disconnect
{
    LogFuncName();
    
    [super disconnect];
    
    if (userAccout().persistSocketFlag) {
        return;
    }

    [self didDisconnect];
}

- (void)didDisconnect
{
    LogFuncName();
    
    if (_remoteSocket) {
        
        DLog(@"关闭remoteSocket链接");
        _remoteSocket.encryptionKey = nil;
        if ([_remoteSocket isConnected]) {
            [_remoteSocket disconnect];
        }
    }
}
- (void)cancelTask
{
    LogFuncName();
    
    [super cancelTask];
    
    // 重置任务队列
    [self.sensorTableQueue removeAllObjects];
    [self.wifiTableQueue removeAllObjects];
    
    [self.manager removeAllTasks];
    [self.manager reset]; // 重置状态
}
#pragma mark - 退出登录

-(void)logOff
{
    DLog(@"退出登录 -- 远程");
    
    [self cancelTask];
    [self didDisconnect];
}

#pragma mark -  已经是发向服务器的指令，不再转发，直接返回失败
-(BOOL)repeaterTransmit:(BaseCmd *)cmd completion:(SocketCompletionBlock)completion
{
    DLog(@"已经是发向服务器的指令，不再转发，直接返回失败");
    
    if (completion) {
        completion(KReturnValueConnectError,nil);
    }
    return NO;    
}


- (void)socketDidDisconnect:(GlobalSocket *)sock withError:(NSError *)err
{
    [super socketDidDisconnect:sock withError:err];
    
    // 重置状态
    [self.manager reset];
    
    if (userAccout().isManualLogout) {
        DLog(@"已手动退出登录");
        return;
    }
    // 已进入后台
    if (userAccout().isEnterBackground) {
        DLog(@"当前处于后台状态");
        return;
    }
    // 当前无网络
    if (!isNetworkAvailable()) {
        DLog(@"当前处于无网络状态");
        return;
    }
    
    // 当前未登录
    if (!userAccout().isLogin) {
        DLog(@"当前处于未登录状态");
        return;
    }
    
    // 当前未登录
    if (userAccout().isInAPConfiguring) {
        DLog(@"重新尝试建立链接,当前处于AP配置中");
        return;
    }
    
    DLog(@"重新尝试建立链接");
    [self.manager prepare];
}


- (void)sendCmd:(BaseCmd *)cmd completion:(SocketCompletionBlock)completion
{
    // 如果状态正常则直接发送指令
    // 如果状态异常则自动缓存指令
    if ([self.manager isReady:[cmd taskWithCompletion:completion]]) {
        [self didSendCmd:cmd completion:completion];
    }
}
@end
