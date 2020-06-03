//
//  SearchMdns.m
//  Vihome
//
//  Created by Air on 15-1-27.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "SearchMdns+UdpSearch.h"
#import "HMNetworkMonitor.h"
#import "HMConstant.h"

#define testSearchTime 5

#define kSearchColorLightMdnsTime                     2.1        // 查找灯带mdns服务的时间

@interface SearchMdns ()

@property (nonatomic , strong) NSString *ssid;

@property (nonatomic , strong) NSMutableArray *blocksArray;
@property (nonatomic , strong) NSMutableArray *netServiceArray;//已发布服务的实例
@property (nonatomic , strong) NSMutableDictionary *searchGateways;

@property (nonatomic , strong) NSNetServiceBrowser *browser; // 服务发现实例
@property (nonatomic , strong) GCDAsyncUdpSocket *udpSocket; // upd 发广播查找主机

//@property (nonatomic , strong) ABB_AsyncUdpSocket *udpSocket; // upd 发广播查找主机

/**
 *  时间戳，把上次搜索的结果缓存5s，如果在同一个网络钟是5s内
 */
@property(nonatomic,assign) NSTimeInterval timeStamp;

/**
 *  上一次搜索到的网关缓存的有效时间，默认5s
 */
@property(nonatomic,assign) NSTimeInterval cacheTime;

@property(nonatomic,assign) BOOL updateTimeStamp;

@property(nonatomic,assign,readonly) BOOL timeStampExpired;

@property(nonatomic,assign) BOOL isSearchHost;
@property(nonatomic,assign) BOOL isSearching;


// 搜索主机以外的设备用到
@property(nonatomic,assign) KDeviceType mdnsDeviceType;
@property (nonatomic ,strong) NSTimer *mdnsTimer;


@end

@implementation SearchMdns


+ (id)shareInstance
{
    Singleton();
}
-(id)init
{
    self = [super init];
    if (self) {
        
        if (!_searchGateways) {
            self.searchGateways = [NSMutableDictionary dictionary];
            self.netServiceArray = [NSMutableArray array];
            self.blocksArray = [NSMutableArray array];
            
            // 初始化
            self.timeStamp = 0;
            self.cacheTime = kSearchMdnsTime;
            self.updateTimeStamp = NO;
            
            _isSearchHost = YES; // 默认是搜索主机
            
        }
    }
    return self;
}

//- (void)startMdnsTimer {
//    if (!_mdnsTimer) {
//        _mdnsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(start) userInfo:nil repeats:YES];
//    }
//}

//- (void)stopMdnsTimer {
//    if (_mdnsTimer) {
//        [_mdnsTimer invalidate];
//        _mdnsTimer = nil;
//    }
//}

-(NSNetServiceBrowser *)browser
{
    if (!_browser) {
        _browser = [[NSNetServiceBrowser alloc] init];
        _browser.delegate = self;
        _browser.includesPeerToPeer = YES;
    }
    return _browser;
}

#pragma mark - 更新时间戳
-(void)setUpdateTimeStamp:(BOOL)updateTimeStamp
{
    if (updateTimeStamp) {
        self.timeStamp = CACurrentMediaTime();
    }else{
        self.timeStamp = 0;
    }
}

#pragma mark - 判定时间戳是否过期
-(BOOL)timeStampExpired
{
    NSTimeInterval now = CACurrentMediaTime();
    NSTimeInterval last = self.timeStamp;
    NSTimeInterval interval = now - last;
    
    BOOL isExpired = (interval > self.cacheTime);
    
    DLog(@"mdns日志 ---两次搜索时间间隔为%0.0fs,%@",interval,isExpired ? @"缓存已经过期":@"缓存尚未过期");
    
    return isExpired;
}



-(void)searchGatewaysAndPostResult
{
    if (!_isSearching) {
        
        DLog(@"searchGatewaysAndPostResult");
        
        [self searchGatewaysWtihCompletion:^(BOOL success, NSArray *gateways) {
            
            if (isEnableWIFI()) {
                [HMBaseAPI postNotification:kNOTIFICATION_SEARCH_MDNS_RESULT object:gateways];
            }else {
                [HMBaseAPI postNotification:kNOTIFICATION_SEARCH_MDNS_RESULT object:nil];
            }
        }];
    }
    
}

-(void)mdnsSearchDevicesWithDeviceType:(KDeviceType)deviceType completion:(SearhMdnsBlock)completion {
    NSAssert((deviceType != kDeviceTypeViHCenter300)
             && (deviceType != KDeviceTypeMixPad)
             && (deviceType != kDeviceTypeMiniHub)
             && (deviceType != KDeviceTypeAlarmHub), @"搜索主机不要调用此方法");
    
    _mdnsDeviceType = deviceType;
    [self searchGatewaysWtihCompletion:completion isSearchHost:NO];
}

// 搜索到的网关
- (NSMutableDictionary *)searchAimGatewayDic {
    NSMutableDictionary *tmpSearchAimGatewayDic = [NSMutableDictionary dictionaryWithDictionary:_searchGateways];
    NSArray *searchGatewayObjs = [NSArray arrayWithArray:_searchGateways.allValues];
    
    if (_isSearchHost) {
        [searchGatewayObjs enumerateObjectsUsingBlock:^(Gateway * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!isHostModel(obj.model)) {
                [tmpSearchAimGatewayDic removeObjectForKey:obj.uid];
            }
        }];
        DLog(@"mdns日志 ---mdns完后应该回调 ----- 搜索的主机为： %@",tmpSearchAimGatewayDic);
    }else {
        
        __weak typeof(self) weakSelf = self;
        [searchGatewayObjs enumerateObjectsUsingBlock:^(Gateway * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            KDeviceType deviceType = [HMDeviceDesc descTableDeviceTypeWithModel:obj.model];
            if (deviceType != weakSelf.mdnsDeviceType) {
                [tmpSearchAimGatewayDic removeObjectForKey:obj.uid];
            }
        }];
        DLog(@"mdns日志 ---mdns完后应该回调 ----- 搜索的设备（除主机）为： %@",tmpSearchAimGatewayDic);
    }
    return tmpSearchAimGatewayDic;
}

-(void)searchGatewaysWtihCompletion:(SearhMdnsBlock)completion isSearchHost:(BOOL)isSearchHost {
    _isSearchHost = isSearchHost;
    self.cacheTime = kSearchColorLightMdnsTime;
    
    BOOL isWifiStatus = isEnableWIFI();
    NSString *curSSid = [HMNetworkMonitor getSSID];
    
    // WiFi 状态下，上次的搜索结果还在有效期内
    if (isWifiStatus && !self.timeStampExpired) {
        // 已保存过一次ssid 而且ssid 未发生变化
        if (self.ssid && [self.ssid isEqualToString:curSSid]) {
            
            if (completion) {
                
                DLog(@"mdns日志 ---时间较短且wifi环境没变(当前网络ssid=%@)，返回上次缓存的搜索结果：%@",curSSid,_searchGateways);
                
                NSDictionary *aimSearchGatewayDic = [self searchAimGatewayDic];
                if (_isSearchHost) {
                    [userAccout().gatewayDicList addEntriesFromDictionary:aimSearchGatewayDic];
                }
                BOOL find = (aimSearchGatewayDic.count > 0);
                completion(find,find ? aimSearchGatewayDic.allValues :nil);
                DLog(@"mdns日志 ---mdns/udp搜索完后 ----  应该回调的设备为 : %@",aimSearchGatewayDic);
                
                return;
            }
        }else{
            DLog(@"mdns日志 ---当前ssid=%@，上次ssid=%@",curSSid,self.ssid?:@"");
        }
    }
    
    
    if (!_isSearching) {
        
        [_searchGateways removeAllObjects];
        
        DLog(@"searchGatewaysWtihCompletion");
        
        NSArray *allGateways = userAccout().gatewayDicList.allValues;
        [allGateways setValue:nil forKey:@"host"];

        if (isWifiStatus) {
            self.ssid = [HMNetworkMonitor getSSID];
        }else{
            // 非wifi状态下
            [allGateways setValue:@(REMOTE_LOGIN) forKey:@"loginType"];
        }
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (completion && isWifiStatus) { // 只要是wifi就本地尝试qg一下
                
                DLog(@"主线程开始搜索主机");
                
                weakSelf.isSearching = YES;
                
                // wifi 发现设备
                executeAsync(^{
                    [self findGatewayWithUdp];
                });
                
                // mdns 发现设备
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self start];
                });
                
                [self.blocksArray addObject:[completion copy]];
                executeAfterDelay(self.cacheTime, ^{
                    
                    [self searchMdnsFinsish];
                });
                
            }else {
                
                weakSelf.isSearching = NO;
                DLog(@"mdns日志 --- 没有WiFi网络，返回mdns搜索结果");
                executeAfterDelay(self.cacheTime, ^{
                    if (completion) {
                        completion(NO,nil);
                    }
                });
            }
        });
        
    }else{
        DLog(@"mdns日志 ---正在执行mdns搜索时，又被调用");
        
        if (completion) {
            [self.blocksArray addObject:[completion copy]];
        }
        executeAfterDelay(self.cacheTime, ^{
            
            [self searchMdnsFinsish];
        });
        DLog(@"mdns日志 ---正在执行mdns搜索时，添加block");
    }
}


-(void)searchGatewaysWtihCompletion:(SearhMdnsBlock)completion
{
    [self searchGatewaysWtihCompletion:completion isSearchHost:YES];
}

-(void)searchMdnsFinsish
{
    DLog(@"mdns日志 ---searchMdnsFinsish -- begin");
    
    // 上一次搜索完毕，更新时间戳
    self.updateTimeStamp = YES;
    
    if (self.blocksArray.count) {
        
        NSUInteger searchCount = _searchGateways.count;
        
        if (searchCount > 0) {
            
            NSMutableString *string = [NSMutableString string];
            NSArray *tmpArray = [NSArray arrayWithArray:_searchGateways.allValues];
            
            for (Gateway *gateway in tmpArray) {
                
                [string appendFormat:@"gateway uid == %@  IP == %@  model == %@ %@\n", gateway.uid,gateway.host,gateway.model,gateway.mdns ? @"MDNS" : @"UDP"];
            }
            
            DLog(@"\n\nmdns日志 --- 此次mdns/udp 搜索共搜索到 %d 个设备:\n\n%@",searchCount,string);
        }else{
            DLog(@"\n\nmdns日志 --- 此次mdns/udp 搜索共搜索到 0 个设备");
        }
        
        NSArray *array = [NSArray arrayWithArray:self.blocksArray];
        NSString *curSSid = [HMNetworkMonitor getSSID];
        DLog(@"mdns日志 ---当前网络ssid=%@ \n返回mdns/udp搜索结果：",curSSid,_searchGateways);
        
        for (SearhMdnsBlock block in array) {
            
            if (block) {
            
                NSDictionary *aimSearchGatewayDic = [self searchAimGatewayDic];
                BOOL find = (aimSearchGatewayDic.count > 0);
                block(find,find ? aimSearchGatewayDic.allValues :nil);
                DLog(@"mdns日志 ---mdns/udp搜索完后 ----  应该回调的设备为 : %@",aimSearchGatewayDic);
                [self.blocksArray removeObject:block];
            }
        }
    }
    
    [_netServiceArray removeAllObjects];
    
    _isSearching = NO;
    [self.udpSocket setDelegate:nil];
    [self.udpSocket close];
    self.udpSocket = nil;
    DLog(@"mdns日志 --- searchMdnsFinsish -- end");
}


- (void)start
{
    DLog(@"mdns日志 --- 开始MDNS搜索 -- start");
    [self stop];
    [self.browser searchForServicesOfType:MNDS_SERVICE_TYPE inDomain:MNDS_DOMAINNAME];
}

- (void)stop
{
    [self.browser stop];
}

#pragma mark - NSNetServiceDelegate
- (void)netServiceWillPublish:(NSNetService *)sender
{
//    DLog(@"%@----  %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
- (void)netServiceDidPublish:(NSNetService *)sender
{
//    DLog(@"%@----  %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
  //  DLog(@"%@----  %@ errorDict: %@ ",NSStringFromClass([self class]),NSStringFromSelector(_cmd),errorDict);
}

- (void)netServiceWillResolve:(NSNetService *)sender
{
  //  DLog(@"%@----  %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
  //  DLog(@"%@----  %@ errorDict: %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),errorDict);
}
- (void)netServiceDidStop:(NSNetService *)sender
{
//    [self stop];
    DLog(@"%@----  %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
    NSDictionary * dic = [NSNetService dictionaryFromTXTRecordData:data];
    DLog(@"%@----  %@  dic: %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),dic);
}


- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    [self didFindGateway:sender udpInfo:nil];
}

-(void)didFindGateway:(NSNetService *)sender udpInfo:(NSDictionary *)udpInfo
{
    DLog(@"mdns日志 --- didFindGateway: %@  udpinfo:%@",sender,udpInfo);
    // mdns 发现了设备
    if (sender) {
        
        NSArray * addresses = sender.addresses;
        //NSString * name = sender.name; //orvibo_gateway
        //NSString * hostName = sender.hostName; //orvibo_gateway.local.
        NSData * textRecordData = [sender TXTRecordData];
        NSDictionary * dic = [NSNetService dictionaryFromTXTRecordData:textRecordData];
        
        if (dic) {
            
            NSString * uid = [asiiStringWithData([dic objectForKey:@"uid"]) lowercaseString];
            NSString * model = asiiStringWithData([dic objectForKey:@"model"]);
            DLog(@"mdns日志 --- ==================**************MDNS搜索到的设备model：%@  设备uid：%@",model,uid);

            for (NSData * data in addresses) {
                if ([data isKindOfClass:[NSData class]]) {
                    NSString *IP = [BLUtility getIPAddressByData:data];
                    if (![IP isEqualToString:@"0.0.0.0"]) {
                        
                        DLog(@"mdns日志 --- MDNS uid == %@,IP == %@,model == %@", uid,IP,model);
                        
                        if (isValidUID(uid)) {
                            
                            Gateway *gateway = getGateway(uid);
                            gateway.host = IP;
                            gateway.port = MNDS_PORT;
                            gateway.loginType = LOCAL_LOGIN;
                            gateway.localSsid = self.ssid;
                            gateway.model = model;
                            gateway.mdns = YES;
                            //gateway.textRecordData = textRecordData;
                            [self saveGateway:gateway];
                        }
                    }
                }
            }
        }
        
    }else if (udpInfo){ // udp 发现了主机
        
        NSString *uid = udpInfo [@"uid"];
        NSString *host = udpInfo[@"host"];
        NSString *model = udpInfo[@"model"];
        DLog(@"UDP uid == %@,IP == %@,model == %@", uid,host,model);
        
        if (isValidUID(uid)) {
            
            int port = [udpInfo[@"servicePort"]intValue];
            
            Gateway *gateway = getGateway(uid);
            gateway.host = host;
            gateway.port = port;
            gateway.loginType = LOCAL_LOGIN;
            gateway.localSsid = self.ssid;
            gateway.model = model;
            gateway.mdns = NO;
            [self saveGateway:gateway];
        }
    }
}

-(void)saveGateway:(Gateway *)gateway
{
    NSString *uid = gateway.uid;
    Gateway *oldGateway = _searchGateways[uid];
    if (!oldGateway) {
        _searchGateways[uid] = gateway;
    }else{
        
        NSString *model = oldGateway.model;
        if (!model || ([model isEqualToString:@"(null)"])) {
            oldGateway.model = gateway.model;
        }
        
        if (gateway.mdns && (!oldGateway.mdns)) { // 通过mdns发现的设备
            oldGateway.host = gateway.host;
        }
    }
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    DLog(@"mdns日志 --- %@----  %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    DLog(@"mdns日志 --- %@----  %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
    DLog(@"mdns日志 --- %@----  %@ errorDict: %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),errorDict);
    [self stop];
    [self start];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    DLog(@"mdns日志 --- %@----  %@ domainString : %@ moreComing： %d",NSStringFromClass([self class]),NSStringFromSelector(_cmd),domainString,moreComing);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    DLog(@"mdns日志 --- %@----  %@ moreComing： %d",NSStringFromClass([self class]),NSStringFromSelector(_cmd),moreComing);
    if (!aNetService) {
        return;
    }
    if (![_netServiceArray containsObject:aNetService]) {
        [_netServiceArray addObject:aNetService];
    }
    aNetService.delegate = self;
    [aNetService startMonitoring];
    [aNetService resolveWithTimeout:10];
    

    if (!moreComing) {
        
    }
}

-(void)openUdpSocket
{
    @try {
        // 忽略 SIGPIPE 信号
        struct sigaction sa;
        sa.sa_handler = SIG_IGN;
        sigaction( SIGPIPE, &sa, 0 );
        
        //初始化udp
        if (!self.udpSocket) {
            self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            
            
            self.udpSocket.delegate = self;
            [self.udpSocket bindToPort:HM_UDP_PORT error:nil];      //绑定（接收）端口
            [self.udpSocket joinMulticastGroup:HM_UDP_BROADCAST_ADDR error:nil];
            //加入群里，能接收到群里其他客户端的消息
            //[self.udpSocket joinMulticastGroup:@"224.0.0.2" error:nil];
            [self.udpSocket enableBroadcast:YES error:nil];  //允许发送广播
            [self.udpSocket beginReceiving:nil];
            
        }
    }
    @catch (NSException *exception) {
        DLog(@"[%@ %@]发生了崩溃:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),exception);
    }
    @finally {
        
    }
}

-(void)findGatewayWithUdp
{
    LogFuncName();
    
    [self openUdpSocket];
    
    BaseCmd *cmd = [QueryGatewayCmd object];
    NSData *data = [cmd data];
    NSString *host = HM_UDP_BROADCAST_ADDR;
    uint16_t port = HM_UDP_PORT;
    
    
//    DLog(@"\n\nUDP 发送%@ 长度:%d "
//         "%@:%d \n\n发送数据内容:\n%@\n data:%@",cmd,data.length,host,port,[cmd jsonDic],data);
    
    VoidBlock sendDataBlock = ^{
        
        DLog(@"\n\nUDP 发送%@ 长度:%d "
             "%@:%d \n\n发送数据内容:\n%@\n",cmd,data.length,host,port,[cmd jsonDic]);

        [self.udpSocket sendData:data
                          toHost:host
                            port:port
                     withTimeout:-1 tag:0];
    };
    
    sendDataBlock();
    // 发送两次UDP广播
    executeAfterDelay(kSearchMdnsTime / 2.0, sendDataBlock);
    
}

@end
