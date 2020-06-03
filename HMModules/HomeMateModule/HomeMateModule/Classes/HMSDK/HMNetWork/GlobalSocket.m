//
//  GlobalSocket.m
//  HomeMate
//
//  Created by Air on 15/8/14.
//  Copyright © 2017年 Air. All rights reserved.
//
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <err.h>

#import "GlobalSocket.h"
#import "HMConstant.h"

@interface GlobalSocket ()

/**
 *  时间戳，每次接收到数据之后更新这个值，如果当前时间距离最后一次接收数据的时间超过 maxLiveTime ，那么控制命令超时的时候就应该断开重连了
 */
@property(nonatomic,assign) NSTimeInterval timeStamp;

/**
 *  socket没有接收到数据时，认为其仍然存活的最大时间
 */
@property(nonatomic,assign) NSTimeInterval maxLiveTime;

-(void)dataInit;

@end

@implementation GlobalSocket

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (id)init
{
    self = [super init];
    if (self) {
        [self dataInit];
    }
    return self;
}

- (id)initWithSocketQueue:(dispatch_queue_t)sq
{
    self = [super initWithDelegate:nil delegateQueue:NULL socketQueue:sq];
    if (self) {
        [self dataInit];
    }
    return self;
}

- (id)initWithDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)dq
{
    self = [self initWithDelegate:aDelegate delegateQueue:dq socketQueue:NULL];
    if (self) {
        [self dataInit];
    }
    return self;
}

- (id)initWithDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)dq socketQueue:(dispatch_queue_t)sq
{
    self = [super initWithDelegate:aDelegate delegateQueue:dq socketQueue:sq];
    if (self) {
        [self dataInit];
    }
    return self;
}


-(void)dataInit
{
    // 初始化
    self.timeStamp = 0;
    self.maxLiveTime = 10;
    self.updateTimeStamp = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(networkChanged)
                                                    name:NOTIFICATION_NETWORKSTATUS_CHANGE
                                                  object:nil];
    });
}

-(void)networkChanged
{
    DLog(@"主动断开链接");

    self.encryptionKey = nil;
    self.updateTimeStamp = NO;
    if ([self isConnected]) {
        [self disconnect];
    }
}

#pragma 确认socket连接成功

- (void)didConnect:(int)aStateIndex
{
    [super didConnect:aStateIndex];
    
    self.updateTimeStamp = YES;
}

#pragma 确认socket关闭成功
- (void)closeWithError:(NSError *)error
{
    [super closeWithError:error];
    self.updateTimeStamp = NO;
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
    
    BOOL isExpired = (interval > self.maxLiveTime);
    return isExpired;
}

// 局域网通信暂不支持SSL，模板方法，什么都不执行
// 远程通信子类需要重新实现模板方法

- (void)socketStartTls{}

- (void)socket:(GlobalSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler{}

@end


@interface HMServerSocket ()

@property(nonatomic,assign) BOOL needSwitchAddress;

@end


@implementation HMServerSocket

-(void)dataInit
{
    // 到服务器的链接，IPv6优先
    //self.IPv4PreferredOverIPv6 = NO;
    self.needSwitchAddress = NO;
    [super dataInit];
}

//- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError **)errPtr
//{
//    if (self.isConnectToServer && [self isIPV4Address:host] && [self is_IPV6_Environment]) {
//        
//        NSArray *ipv4 = [host componentsSeparatedByString:@"."];
//        if (ipv4.count == 4) {
//            host = [NSString stringWithFormat:@"0064:ff9b:0000:0000:0000:0000:%02x%02x:%02x%02x", [ipv4[0] intValue], [ipv4[1]intValue], [ipv4[2]intValue], [ipv4[3]intValue]];
//        }
//    }else{
//        DLog(@"socket通信开始连接 Host:%@ Port:%d",host,port);
//    }
//    
//    return [super connectToHost:host onPort:port error:errPtr];
//}

-(BOOL)isConnectedSSL{

    BOOL sslSecure = [super isSecure];
    if (!sslSecure) {
        DLog(@"SSL状态异常，重新执行SSL配置");
        [self socketStartTls];
    }
    return sslSecure;
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag {
    if ([self isConnectedSSL]) {
        [super readDataWithTimeout:timeout tag:tag];
    }else {
        DLog(@"ssl 还未连接，不读取数据！");
    }
}

- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag {
    if ([self isConnectedSSL]) {
        [super writeData:data withTimeout:timeout tag:tag];
    }else {
        DLog(@"ssl 还未连接，不发送数据！");
    }
}

- (BOOL)connectWithAddress4:(NSData *)address4 address6:(NSData *)address6 error:(NSError **)errPtr
{
    
    self.needSwitchAddress = address4 && address6;
    if (self.needSwitchAddress) {
        
        DLog(@"同时获取了IPv4和IPv6通信地址");
        
        NSString *IPv6Host = [[self class] hostFromAddress:address6];
        
        DLog(@"IPv4: %@:%hu", [[self class] hostFromAddress:address4], [[self class] portFromAddress:address4]);
        DLog(@"IPv6: %@:%hu", IPv6Host, [[self class] portFromAddress:address6]);
        
        if ([IPv6Host isEqualToString:@"::1"]) {
            
            DLog(@"IPv6地址非法，采用IPv4的地址来连接");
            
            return [super connectWithAddress4:address4 address6:nil error:errPtr];
        }
        
    }else{
        
        if (address6 && (!address4)) {
            DLog(@"只获取到了IPv6地址 %@:%hu，未获取到IPv4地址"
                 ,[[self class] hostFromAddress:address6]
                 ,[[self class] portFromAddress:address6]);
        }
        
        if (address4 && (!address6)) {
            
            DLog(@"只获取到了IPv4地址 %@:%hu，未获取到IPv6地址"
                 ,[[self class] hostFromAddress:address4]
                 ,[[self class] portFromAddress:address4]);
        }
        
        // 只获取到一个地址的情况下恢复默认设置
        self.IPv4PreferredOverIPv6 = NO;
    }
    return [super connectWithAddress4:address4 address6:address6 error:errPtr];
}

-(void)setConnectFailed:(BOOL)connectFailed
{
    if (connectFailed && self.needSwitchAddress) {
        
        DLog(@"同时获取了IPv4和IPv6通信地址情况下，使用%@地址通信失败",self.IPv4PreferredOverIPv6?@"IPv4":@"IPv6");
        self.IPv4PreferredOverIPv6 = !self.IPv4PreferredOverIPv6;
        DLog(@"下一次重新建立链接时优先尝试%@网络",self.IPv4PreferredOverIPv6?@"IPv4":@"IPv6");
    }
}

- (void)socketStartTls {
    NSMutableDictionary *sslSettings = [[NSMutableDictionary alloc] init];
    NSData *pkcs12data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"]];
    CFDataRef inPKCS12Data = (CFDataRef)CFBridgingRetain(pkcs12data);
    CFStringRef password = CFSTR("SdxxGwrx2018");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    
    OSStatus securityError = SecPKCS12Import(inPKCS12Data, options, &items);
    CFRelease(options);
    CFRelease(password);
    
    if(securityError == errSecSuccess) {
        DLog(@"Success opening p12 certificate.");
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef myIdent = (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                                                      kSecImportItemIdentity);
        
        SecIdentityRef  certArray[1] = { myIdent };
        CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
        
        [sslSettings setObject:(id)CFBridgingRelease(myCerts) forKey:GCDAsyncSocketSSLCertificates];
        [sslSettings setObject:@(kTLSProtocol1) forKey:(NSString *)GCDAsyncSocketSSLProtocolVersionMin];
        [sslSettings setObject:@(YES) forKey:(NSString *)GCDAsyncSocketManuallyEvaluateTrust];
        [self startTLS:sslSettings];
    }else{
        DLog(@"Fail opening p12 certificate.ErrorCode = %d",securityError);
    }
}

- (void)socket:(GlobalSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler {
    
    DLog(@"%@ -- socket:didReceiveTrust",NSStringFromClass([self class]));
    NSString *certFilePath1 = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"der"];
    NSData *certData1 = [NSData dataWithContentsOfFile:certFilePath1];
    
    OSStatus status = -1;
    SecTrustResultType result = kSecTrustResultDeny;
    
    if(certData1)
    {
        SecCertificateRef   cert1;
        cert1 = SecCertificateCreateWithData(NULL, (__bridge_retained CFDataRef) certData1);
        // 设置证书用于验证
        SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef)[NSArray arrayWithObject:(__bridge id)cert1]);
        // 验证服务器证书和本地证书是否匹配
        status = SecTrustEvaluate(trust, &result);
    }
    else
    {
        DLog(@"local certificates could not be loaded");
        completionHandler(NO);
    }
    
    if ((status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)))
    {
        //成功通过验证，证书可信
        completionHandler(YES);
    }
    else
    {
        CFArrayRef arrayRefTrust = SecTrustCopyProperties(trust);
        DLog(@"error in connection occured\n%@", arrayRefTrust);
        completionHandler(NO);
    }
}
//-(BOOL)isIPV4Address:(NSString *)host
//{
//    BOOL isIPV4 = isValidString(host,@"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)");
//    
//    DLog(@"host = %@ 是一个%@",host,isIPV4 ? @"IPv4地址" : @"域名");
//    return isIPV4;
//}
//
//- (BOOL)is_IPV6_Environment
//{
//    LogFuncName();
//    
//    BOOL IPV6_Environment = NO;
//    
//    struct addrinfo hints, *res, *res0;
//    
//    memset(&hints, 0, sizeof(hints));
//    hints.ai_family   = PF_UNSPEC;
//    hints.ai_socktype = SOCK_STREAM;
//    hints.ai_protocol = IPPROTO_TCP;
//    
//    int gai_error = getaddrinfo([HM_DOMAIN_NAME UTF8String], "10001", &hints, &res0);
//    
//    if (!gai_error){
//        
//        for (res = res0; res; res = res->ai_next)
//        {
//            if (res->ai_family == AF_INET6){
//                // Found IPv6 address.
//                // Wrap the native address structure, and add to results.
//                
//                IPV6_Environment = YES;
//                DLog(@"当前网络环境：IPv6");
//                break;
//                
//            }else if (res->ai_family == AF_INET){
//                DLog(@"当前网络环境：IPv4");
//                break;
//            }
//            else{
//                DLog(@"当前网络环境：%d",res->ai_family);
//            }
//        }
//        freeaddrinfo(res0);
//    }
//    
//    //DLog(@"当前网络环境：%@",IPV6_Environment?@"IPV6":@"IPV4");
//    
//    return IPV6_Environment;
//}

@end
