//
//  HMNetworkMonitor.m
//  KeplerSDK
//
//  Created by Ned on 14-7-23.
//  Copyright (c) 2014年 orvibo. All rights reserved.
//

#import "HMNetworkMonitor.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <netdb.h>
#import <arpa/inet.h>
#import "HMConstant.h"

@interface HMNetworkMonitor()

@property (nonatomic,strong) Reachability *reachability;

@end

@implementation HMNetworkMonitor
@synthesize reachability;
@synthesize networkStatus;
@synthesize curSSID;
@synthesize hostIP;

+ (instancetype)shareInstance
{
    static HMNetworkMonitor *__singletion;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __singletion=[[self alloc] init];
        
    });
    
    return __singletion;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        self.reachability = [Reachability reachabilityWithHostName:TEST_HOST_NAME];
        self.networkStatus = NotReachable;//[reachability currentReachabilityStatus];//默认无网络
        
        [self setNetworkNotifierBlock];// 设置状态检测的block
        //[self startNetworkNotifier];// 开启网络检测

    }
    return self;
}

-(NetworkStatus)NetworkStatus
{
    @autoreleasepool {
        
        if (networkStatus == ReachableViaWiFi // 3G
            || networkStatus == ReachableViaWWAN) { // WIFI
            
            return networkStatus;
            
        }else {  // 无网络
            
            if ([[Reachability reachabilityForLocalWiFi]isReachableViaWiFi]) {
                
                return ReachableViaWiFi; // WIFI
                
            }else if ([[Reachability reachabilityForInternetConnection] isReachableViaWWAN]){
                
                return ReachableViaWWAN; // 3G
                
            }else{
                
                return [[Reachability reachabilityWithHostname:TEST_HOST_NAME]currentReachabilityStatus];
            }
        }
    }
}

-(void)startNetworkNotifier// 开启网络检测
{
    DLog(@"开启网络检测");
    
    [self.reachability stopNotifier];// 每次先关闭再打开
    [self.reachability startNotifier];
}

-(void)setNetworkNotifierBlock
{
    __block HMNetworkMonitor *weakSelf = self;
    
    reachability.reachableBlock = ^(Reachability * _reachability) // 有网络但发生变化
    {
        NetworkStatus curNtwkStus = [_reachability currentReachabilityStatus];
        
        NSString *_curSSid = (curNtwkStus == NotReachable) ? @"无网络链接":[HMNetworkMonitor getSSID];
        
        if (curNtwkStus == NotReachable) {
            DLog(@"无网络链接");
        }
        
        if ((weakSelf.networkStatus == NotReachable) // 从 无网 切换到wifi
            &&(curNtwkStus == ReachableViaWiFi)) {
            
            DLog(@"从 无网 切换到wifi:%@",_curSSid);
            
        }
        else if ((weakSelf.networkStatus == ReachableViaWiFi) // 从 wifi 切换到另一个 wifi
                 &&(curNtwkStus == ReachableViaWiFi)) {
            
            DLog(@"从 wifi:%@ 切换到另一个 wifi:%@",weakSelf.curSSID,_curSSid);
            
        }else if ((weakSelf.networkStatus == ReachableViaWWAN) // 从3G 切换到 wifi
                  &&(curNtwkStus == ReachableViaWiFi)) {
            
            DLog(@"从3G 切换到 wifi:%@",_curSSid);
            if([_curSSid isEqualToString:@"3G"]) {
              [HMBaseAPI postNotification:APNOTIFICATION_NETWORKSTATUS_CHANGE
                                                                    object:nil];
            }
            
        }
        else if ((weakSelf.networkStatus == ReachableViaWiFi) // 从 wifi 切换到3G
                 &&(curNtwkStus == ReachableViaWWAN)) {
            
            DLog(@"从 wifi:%@ 切换到3G",_curSSid);
        }
        else if ((weakSelf.networkStatus == NotReachable) // 从 无网 切换到3G
                 &&(curNtwkStus == ReachableViaWWAN)) {
            DLog(@"从 无网 切换到3G");
        }
        else if ((weakSelf.networkStatus == ReachableViaWWAN) // 从 3G 切换到无网
                 &&(curNtwkStus == NotReachable)) {
            DLog(@"从 3G 切换到无网");
        }
        else if ((weakSelf.networkStatus == ReachableViaWiFi) // 从 wifi 切换到无网
                 &&(curNtwkStus == NotReachable)) {
            DLog(@"从 wifi:%@ 切换到无网",_curSSid);
        }
        
        // ssid发生变化或者网络状态发生变化才发送通知
        
        if ((![_curSSid isEqualToString:weakSelf.curSSID])
            || weakSelf.networkStatus != curNtwkStus) {
            
            weakSelf.curSSID = _curSSid;
            weakSelf.networkStatus = curNtwkStus;
            
            DLog(@"SSID发生变化或者网络状态发生变化");
            
            [weakSelf postNetworkStatus];
        }
    };
   
    reachability.unreachableBlock = ^(Reachability * _reachability)// 从有网络变为无网络
    {
        DLog(@"无网络连接");
        [HMBaseAPI postNotification:APNOTIFICATION_NETWORKSTATUS_CHANGE
                                                            object:nil];
        weakSelf.networkStatus = [_reachability currentReachabilityStatus];
        // 网络发生变化
        [weakSelf postNetworkStatus];

    };
}

-(void)postNetworkStatus
{
    // 如果正处于AP配置模式，则不做重连操作
    if (userAccout().isInAPConfiguring) {
        return;
    }
    
    // 如果当前处于后台，则不做重连操作
    if (userAccout().isEnterBackground) {
        return;
    }
    NSNumber  *number = @(self.networkStatus);
    [HMBaseAPI postNotification:NOTIFICATION_NETWORKSTATUS_CHANGE
                                                        object:number];
}


- (NSString *)getBSSID
{
    
    NSArray *interfaces = (__bridge NSArray*)CNCopySupportedInterfaces();
    NSDictionary *info = nil;
    for (NSString *ifname in interfaces) {
        info = (__bridge NSDictionary*)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if (info && [info count]) {
            break;
        }

        info = nil;
    }
    
    if ( info ){
        NSString *ssid = [NSString stringWithString:[info objectForKey:@"BSSID"]];
        CFRelease((__bridge CFTypeRef)(info));
        return ssid;
    }
    return nil;
    
}

#pragma mark - 获取WIFI网络名称
+ (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    NSDictionary * info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CFBridgingRelease(CNCopyCurrentNetworkInfo((CFStringRef)ifnam));
        if (info && [info count]) {
            break;
        }
        
    }
    
    return info;
}
+(NSString *)getSSID
{
    NSDictionary *ifs = [[self class] fetchSSIDInfo];
    
    NSString *ssid = [ifs objectForKey:@"SSID"];
    return ssid;
}

#pragma mark - 域名解析
-(NSString *)getHostIP
{
    if (hostIP) {
        return hostIP;
    }else {
        
        [self getIPWithHostName:@"www.orvibo.com"];
        
        // 如果还未解析出来ip 则 先返回上次保存在本地的 IP 地址
        return [HMUserDefaults objectForKey:@"hostIP"];
    }
    return nil;
}

-(void)getIPWithHostName:(const NSString *)hostName
{
    if (isNetworkAvailable()) { // 有外部网络时进行解析，否则直接返回nil
        
        dispatch_queue_t queue = dispatch_queue_create("com.orvibo.getIPWithHostName", NULL);
        dispatch_async(queue, ^{
            __weak typeof(self) weakSelf = self;
            weakSelf.hostIP = [weakSelf ipWithHost:hostName];
            if (weakSelf.hostIP) { // 保存在本地，防止下次域名不能立即解析出来时出错
                [HMUserDefaults setObject:weakSelf.hostIP forKey:@"hostIP"];
            }
            
        });
    }
}

-(NSString *)ipWithHost:(const NSString *)hostName
{
    const char *hostN = [hostName UTF8String];
    struct hostent* phot;
    
    @try {
        phot = gethostbyname(hostN);
        
    }
    @catch (NSException *exception) {
        DLog(@"[%@ %@]发生了崩溃:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),exception);
        return nil;
    }
    if (phot == NULL) {
        return nil;
    }
    struct in_addr ip_addr;
    memcpy(&ip_addr, phot->h_addr_list[0], 4);
    char ip[20] = {0};
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    
    NSString* strIPAddress = [NSString stringWithUTF8String:ip];
    DLog(@"远程登录域名: %@ 远程登录IP:%@",hostName,strIPAddress);
    return strIPAddress;
}



@end
