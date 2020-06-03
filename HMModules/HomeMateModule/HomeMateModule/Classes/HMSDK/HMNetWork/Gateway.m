//
//  Gateway.m
//
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "Gateway+Send.h"
#import "Gateway+Foreground.h"
#import "Gateway+HeartBeat.h"
#import "HMConstant.h"
#import "HMStorage.h"

@interface GatewayModel : SingletonClass

// 数据发送的任务队列
@property (nonatomic, strong) NSMutableDictionary *taskQueue;

// 不同主机当前状态（是否正在同步数据）
@property (nonatomic, strong) NSMutableDictionary *hubStatusInfo;

@end

@implementation GatewayModel

+ (id)shareInstance{
    Singleton();
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.taskQueue = [NSMutableDictionary dictionary];
        self.hubStatusInfo = [NSMutableDictionary dictionary];
    }
    return self;
}
@end


@interface Gateway ()

@property (nonatomic, strong, readonly) GlobalSocket *localSocket;

@end



@implementation Gateway
@synthesize uid;
@synthesize host;
@synthesize port;
@synthesize loginType;
@synthesize tableQueue;
@synthesize taskQueue;
@synthesize statusInfo;
@synthesize receivedData;
@synthesize delegate = theDelegate;

@synthesize lastUpdateTime = _lastUpdateTime;
@synthesize specificTableUpdateTime = _specificTableUpdateTime;

-(id <HMBusinessProtocol>)delegate
{
    if (theDelegate) {
        return theDelegate;
    }
    return [HMStorage shareInstance].delegate;
}

-(NSString *)lastUpdateTimeKey
{
    NSString *keyOfLastUpdateTime = lastUpdateTimeKey(self.uid);
    DLog(@"uid:%@ lastUpdateTimeKey:%@",self.uid,keyOfLastUpdateTime);
    
    return keyOfLastUpdateTime;
}

-(void)setLastUpdateTime:(NSString *)lastUpdateTime
{
    DLog(@"uid:%@ 旧lastUpdateTime：%@ 新lastUpdateTime：%@",self.uid,_lastUpdateTime,lastUpdateTime);
    
    if (lastUpdateTime != _lastUpdateTime) {
        
        _lastUpdateTime = lastUpdateTime;
    }
    
    NSString *keyOfLastUpdateTime = [self lastUpdateTimeKey];
    
    if (_lastUpdateTime) {
        DLog(@"uid:%@ 保存lastUpdateTime ：%@",self.uid,_lastUpdateTime);
        [self saveObject:_lastUpdateTime withKey:keyOfLastUpdateTime];
    }else{
        DLog(@"uid:%@ 移除lastUpdateTime",self.uid);
        [self removeObjectWithKey:keyOfLastUpdateTime];
    }
}


-(NSString *)lastUpdateTime
{
    if (!_lastUpdateTime) {

        
        NSString *lastTimeSecKey = lastUpdateTimeSecKey(self.uid);
        NSString *lastTimeSec = [self objectWithKey:lastTimeSecKey]; // 实际上如果存在应该是nsnumber类型
        
        if (lastTimeSec) {
            _lastUpdateTime = lastTimeSec;
        }else{
            _lastUpdateTime = [self objectWithKey:[self lastUpdateTimeKey]];
        }
        
        DLog(@"uid:%@ 获取lastUpdateTime ：%@",self.uid,_lastUpdateTime);
    }
    return _lastUpdateTime;
}

-(void)saveLastUpdateTime
{
    if (self.updateTime) {
        
        DLog(@"uid:%@ 保存lastUpdateTime, 旧lastUpdateTime：%@ 新lastUpdateTime：%@",self.uid,self.lastUpdateTime,self.updateTime);
        self.lastUpdateTime = self.updateTime;
    }
    
    if (self.updateTimeSec) {
        
        DLog(@"uid:%@ 保存updateTimeSec ：%@",self.uid,self.updateTimeSec);
        
        NSString *lastTimeSecKey = lastUpdateTimeSecKey(self.uid);
        [self saveObject:self.updateTimeSec withKey:lastTimeSecKey];
        _lastUpdateTime = (NSString *)self.updateTimeSec;
    }
}
-(NSString *)tableUpdateTime:(NSString *)tableName
{
    NSString *updatetime = self.specificTableUpdateTime[tableName];
    if (!updatetime) {
        //DLog(@"tableUpdateTime = %@",self.lastUpdateTime);
        return self.lastUpdateTime;
    }
    //DLog(@"tableUpdateTime = %@",updatetime);
    return updatetime;
}

-(NSMutableDictionary *)taskQueue
{
    if (!taskQueue) {
        taskQueue = [GatewayModel shareInstance].taskQueue;
    }
    return taskQueue;
}

-(NSMutableDictionary *)statusInfo
{
    if (statusInfo) {
        statusInfo = [GatewayModel shareInstance].hubStatusInfo;
    }
    return statusInfo;
}
-(void)dealloc
{
    //dispatch_release(networkSemaphore);
    
    DLog(@"dealloc gateway uid = %@ host = %@",self.uid,self.host);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [_heartBeatTimer invalidate];_heartBeatTimer = nil;
}

-(NSString *)description
{
    if (uid) {
        return [NSString stringWithFormat:@"%@--%@",uid,host];
    }
    return [NSString stringWithFormat:@"%@--%@",@"服务器",host];
}
+(Gateway *)newGateway
{
    Gateway * gateway = [[Gateway alloc]init];
    [gateway addMdnsObserver];
    return gateway;
}

-(id)init{
    self = [super init];
    if (self) {
        
        self.tableQueue = [NSMutableArray array];
        self.specificTableUpdateTime = [NSMutableDictionary dictionary];
        
        [self addObserver];
    }
    return self;
}



-(void)addMdnsObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNOTIFICATION_SEARCH_MDNS_RESULT object:nil];
    // mdns
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(searchMdnsResult:)
                                                name:kNOTIFICATION_SEARCH_MDNS_RESULT
                                              object:nil];
}

-(void)addObserver
{
    [self addCancelTaskObserver];
    
    // 退出登录
    [self addLogOffObserver];
    
    // 登录失败
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(cancelTask)
                                                name:kNOTIFICATION_LOGIN_FAILED
                                              object:nil];
    
}

-(void)addLogOffObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNOTIFICATION_LOG_OFF object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(logOff)
                                                name:kNOTIFICATION_LOG_OFF
                                              object:nil];
}
-(void)addCancelTaskObserver
{
    [self removeCancelTaskObserver];
    // 取消剩余任务的执行，将要进入后台的时候执行
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(cancelTask)
                                                name:kNOTIFICATION_CANCEL_SOCKET_TASK
                                              object:nil];
}

-(void)removeCancelTaskObserver
{
    // 取消剩余任务的执行，将要进入后台的时候执行
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNOTIFICATION_CANCEL_SOCKET_TASK object:nil];
}


#pragma mark - 退出登录

-(void)logOff
{
    DLog(@"uid:%@ 退出登录",self.uid);
    self.isLoginSuccessful = NO;
    [self hm_removeAllObserver];
    [self cancelTask];
    
    // 退出登陆后，移除上一次登录时生成的gateway对象，下次登录时重新生成相应的对象
    // 避免先登录主账号，再登录子账号时，会返回主账号的lastupdateTime，导致子账号读取不到数据
    if (self.uid) {
        NSMutableDictionary *dic = userAccout().gatewayDicList;
        [dic removeObjectForKey:self.uid];
    }
}


#pragma mark - 取消剩余任务的执行
- (void)cancelTask
{
    LogFuncName();
    [self disconnect];
    
    // 取消超时任务
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // 重置任务队列
    DLog(@"uid:%@ 重置任务队列，移除所有任务",self.uid);
    [self.taskQueue removeAllObjects];
    [self.tableQueue removeAllObjects];
    [self.statusInfo removeAllObjects];
}

- (void)disconnect
{
    LogFuncName();
    [self stopHeartbeat]; // 停止心跳包发送
    self.delegate = nil;
    self.receivedData = nil;
    self.groupData = nil;
    self.isGrouping = NO;
    _lastUpdateTime = nil;
    
    if (_localSocket) {
        
        DLog(@"uid:%@ 关闭localSocket链接",self.uid);
        _localSocket.encryptionKey = nil;
        if ([_localSocket isConnected]) {
            
            [_localSocket disconnect];
        }
    }
}


- (void)sendCmd:(BaseCmd *)cmd completion:(SocketCompletionBlock)completion
{
    [self didSendCmd:cmd completion:completion];
}

#pragma mark - 本地链接
-(GlobalSocket *)socket
{
    if (host == nil) {
        GlobalSocket *socket = [RemoteGateway shareInstance].socket;
        socket.delegate = (id)self;
        return socket;
    }else{
        
    }
    
    if (!_localSocket) {
        
        //dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_queue_t queue = dispatch_queue_create("com.orvibo.localSocket", NULL);
        _localSocket = [[GlobalSocket alloc] initWithDelegate:(id)self delegateQueue:queue];
    }
    
    _localSocket.delegate = (id)self;
    _localSocket.uid = self.uid;
    
    DLog(@"本地通信密钥：%@",_localSocket.encryptionKey ?:@"无通信密钥");
    
    if ([_localSocket isDisconnected]) {
        
        NSError *err = nil;
        DLog(@"====== 创建local tcp链接 %@:%d ======", host, port);
        if (![_localSocket connectToHost:host onPort:port error:&err]) { // 创建tcp链接，失败后重试3次
            
            DLog(@"创建tcp链接失败，失败码：%d %@", [err code], [err localizedDescription]);
        }
    }
    return _localSocket;
}
-(BOOL)isSocketConnected
{
    _isSocketConnected = [_localSocket isConnected];
    return _isSocketConnected;
}

-(NSString *)host{
    if (host == nil) {
        DLog(@"host 未被赋值");
        
        return [RemoteGateway shareInstance].host;
        
    }
    return host;
}

-(void)setHost:(NSString *)theHost
{
    host = theHost;
}
-(UInt16)port
{
    if (host == nil) {
        return [RemoteGateway shareInstance].port;
    }
    return port;
}
-(CGFloat)cmdTimeout
{
    if (self.deviceType == kDeviceTypeViHCenter300) {
        return 3.0; // 本地超时时间是2.0s
    }
    return 5.0; // 小主机超时时间设置为5s
}

-(BOOL)isHostNotNil
{
    return (host != nil);
}
-(BOOL)isLocalNetwork{
    
    if (isEnableWIFI()) {
        if (self.isHostNotNil
            && (self.isSocketConnected
                || self.loginType == LOCAL_LOGIN
                || [self.localSsid isEqualToString:[HMNetworkMonitor getSSID]])) {
            
            DLog(@"网关处于局域网状态，uid = %@ host = %@",self.uid,self.host);
            return YES;
                
        }else{
            
            DLog(@"WiFi状态下，主机不在局域网");
            //[[SearchMdns shareInstance]searchGatewaysAndPostResult];
        }
    }
    return NO;
}
-(BOOL)isMiniHub
{
    BOOL miniHub = (self.deviceType == kDeviceTypeMiniHub);
    
    DLog(@"uid = %@ model = %@ %@",self.uid,self.model,miniHub?@"是小主机":@"是大主机");
    
    return miniHub;
}
-(KDeviceType)deviceType
{
    DLog(@"gateway 的 uid:%@  model: %@  deviceType:%d",self.uid,self.model,_deviceType);
    if (!_deviceType) {
        _deviceType = HostType(self.model);
    }
    DLog(@"===== gateway 的 uid:%@  model: %@  deviceType:%d",self.uid,self.model,_deviceType);
    return _deviceType;
}

-(NSString *)model
{
    if (!isValidUID(self.uid)) {
        return _model;
    }
    if (!_model) {
        _model = [HMGateway objectWithUid:self.uid].model;
    }
    return _model;
}



#pragma mark - delegate method

-(void)popAlert:(NSString *)alert
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate popAlert:alert];
    }
}

/**
 *  错误码26对应接口 网关上的数据已不存在
 */
-(void)handleDataNotExist:(NSDictionary *)device
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate handleDataNotExist:device];
    }
}


/**
 *  接收到任意数据时给委托对象的回调
 */
-(void)receiveDataCallback:(NSDictionary *)payloadDic
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate receiveDataCallback:payloadDic];
    }
}


/**
 *  删除wifi设备/主机上报接口
 */
-(void)handleDevcieDeletedReport:(NSDictionary *)payloadDic
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate handleDevcieDeletedReport:payloadDic];
    }
}

/**
 *  接收到推送信息
 */
- (void)handlePushInfo:(NSDictionary *)payloadDic
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate handlePushInfo:payloadDic];
    }
}


/**
 *  向服务器查询传感器设备的最新状态（记录）
 */

-(void)queryLastestMsg
{
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate queryLastestMsg];
    }
}

/**
 *  查询主机升级状态
 */
- (void)checkHostUpgradeStatus {
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate checkHostUpgradeStatus];
    }
}


/**
 *  处理配电箱属性报告
 */
- (void)handleDistBoxStatusReportWithDic:(NSDictionary *)dic {
    if (self.delegate && [self.delegate respondsToSelector:_cmd]) {
        [self.delegate handleDistBoxStatusReportWithDic:dic];
    }
}

@end
