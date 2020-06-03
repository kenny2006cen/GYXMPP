//
//  HMUdpAPI.m
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/8/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMUdpAPI.h"
#import "HMUdpBusiness.h"
#import "NSData+CRC32.h"


@interface HMUdpAPI ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic , strong) GCDAsyncUdpSocket *udpSocket; // upd 发广播查找主机
@property (nonatomic , strong)dispatch_queue_t myQueue;
@property (nonatomic , copy)NSString *host;
@property (nonatomic , copy)NSString *lanCommunicationKey;
@property (nonatomic , assign)uint16_t port;


@end

@implementation HMUdpAPI

+ (id)shareInstance
{
    Singleton();
}

-(id)init
{
    self = [super init];
    if (self) {
        
        __weak typeof(self) weakSelf = self;
        _myQueue = dispatch_queue_create("com.musiccontrol.queue", 0);
        [HMUdpAPI lanCommunicationKeyWithFamilyId:userAccout().familyId callBlock:^(NSString *lanCommunicationKey) {
            if (lanCommunicationKey) {
                weakSelf.lanCommunicationKey = lanCommunicationKey;
            }
        }];
        // 监听网络
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(netWorkStatusChanged:)
                                                     name:NOTIFICATION_NETWORKSTATUS_CHANGE object:nil];
    }
    return self;
}

- (void)sendData:(NSData *)data
          toHost:(NSString *)host
            port:(uint16_t)port
     withTimeout:(NSTimeInterval)timeout
             tag:(long)tag
{
    _host = host;
    _port = port;
    [self openUdpSocket];
    
    VoidBlock sendDataBlock = ^{
        
        //        DLog(@"\n\nUDP 发送%@ 长度:%d "
        //             "%@:%d \n\n发送数据内容:\n%@\n",cmd,data.length,host,port,[cmd jsonDic]);
        
        [self.udpSocket sendData:data
                          toHost:host
                            port:port
                     withTimeout:-1 tag:0];
    };
    
    sendDataBlock();
    //    // 发送两次UDP广播
    //    executeAfterDelay(0.6, sendDataBlock);
}

-(void)openUdpSocket
{
    @try {
        
        
        //初始化udp
        if (!self.udpSocket) {
            // 忽略 SIGPIPE 信号
            struct sigaction sa;
            sa.sa_handler = SIG_IGN;
            sigaction( SIGPIPE, &sa, 0 );
            self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_myQueue];
            
            NSError *udpError = nil;
            [self.udpSocket bindToPort:_port error:&udpError];      //绑定（接收）端口
            
            if (!udpError) {
                
                [self.udpSocket enableBroadcast:YES error:&udpError];  //允许发送广播
                
                if (!udpError) {
                    [self.udpSocket beginReceiving:nil];
                }else {
                    DLog(@"允许广播发生错误 ： %@",udpError);
                }
                
                
            }else {
                
                DLog(@"绑定端口发生错误 ： %@",udpError);
            }
        }
    }
    @catch (NSException *exception) {
        DLog(@"[%@ %@]发生了崩溃:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),exception);
    }
    @finally {
        
    }
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    DLog(@"%s",__FUNCTION__);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    DLog(@"%s",__FUNCTION__);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    DLog(@"%s",__FUNCTION__);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    DLog(@"%s",__FUNCTION__);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    DLog(@"%s",__FUNCTION__);
    //    NSString *host = nil;
    //    uint16_t port = 0;
    //    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    //
    //    if (host) {
    //        [self didReceiveData:data fromHost:host port:port];
    //    }
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    [self closeUdpSocket];
    DLog(@"%s  error：%@",__FUNCTION__,error);
}

- (BOOL)didReceiveData:(NSData *)data fromHost:(NSString *)host port:(UInt16)port
{
    NSUInteger length = data.length;
    
    if (length > 6)
    {
        if (length > 42)
        {
            //            NSData *ptData = [data subdataWithRange:NSMakeRange(4, 2)];
            //            NSString *protocolType = [[NSString alloc]initWithData:ptData encoding:NSASCIIStringEncoding];
            
            __weak typeof(self) weakSelf = self;
            if (!_lanCommunicationKey) {
                [HMUdpAPI lanCommunicationKeyWithFamilyId:userAccout().familyId callBlock:^(NSString *lanCommunicationKey) {
                    if (lanCommunicationKey) {
                        weakSelf.lanCommunicationKey = lanCommunicationKey;
                    }
                }];
            }
            NSString *key =  _lanCommunicationKey;
            
            
            //DLog(@"key:%@",[protocolType isEqualToString:@"dk"] ? @"UDP密钥类型错误" : key);
            
            NSData *crcData = [data subdataWithRange:NSMakeRange(6, 4)];
            NSUInteger receive_crc = getCrcValue(crcData);
            
            NSData * payLoadData = [data subdataWithRange:NSMakeRange(42, length - 42)];
            
            NSUInteger check_crc = [payLoadData hm_crc32];
            
            if (receive_crc == check_crc) {
                
                NSData * decrytedpayLoadData = [payLoadData hm_AES128DecryptWithKey:key iv:nil];
                
                if (decrytedpayLoadData)
                {
                    NSError *error = nil;
                    NSDictionary * payloadDic = [NSJSONSerialization JSONObjectWithData:decrytedpayLoadData options:NSJSONReadingAllowFragments error:&error];
                    
                    if (payloadDic)
                    {
                        //                        DLog(@"\n\n接收数据总长度:%d 解密后数据长度:%d %@:%d \n接收数据内容:%@",data.length,decrytedpayLoadData.length
                        //                             ,host,port,payloadDic);
                        
                        int cmd = [payloadDic [@"cmd"] intValue];
                        
                        
                        // 查找主机命令
                        if (cmd == VIHOME_CMD_UDP){
                            
                            NSNumber *status = payloadDic [@"status"];
                            if (status && ([status intValue] == KReturnValueSuccess)) {
                                
                                //                                DLog(@"\n\n接收数据总长度:%d 解密后数据长度:%d %@:%d \n接收数据内容:%@",data.length,decrytedpayLoadData.length
                                //                                     ,host,port,payloadDic);
                                
                                NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:payloadDic];
                                dic[@"host"] = host;
                                
                                //                                [self didFindGateway:nil udpInfo:dic];
                            }
                            
                        }
                        
                    }else {
                        
                        int lenNum = [data hm_protocolLength];
                        int length = (int)data.length;
                        
                        DLog(@"----------数据异常 实际长度:%d 协议长度:%d----------",length,lenNum);
                        DLog(@"----------数据异常 无法转换为UTF8字符串:\n%@----------,当前秘钥:%@",decrytedpayLoadData, key);
                    }
                }else {
                    DLog(@"----------数据异常 解密失败:\n%@----------",decrytedpayLoadData);
                }
                
            }else {
                
                DLog(@"----------数据异常 crc 校验失败\n%@----------",data);
                DLog(@"___当前秘钥:%@", key);
            }
            
        }else {
            DLog(@"----------数据异常 长度小于42:\n%@----------",data);
        }
    }else {
        DLog(@"----------数据异常 长度小于6:\n%@----------",data);
    }
    
    return YES;
}

- (void)netWorkStatusChanged:(NSNotification *)notification
{
    NSNumber * number = (NSNumber *)notification.object;
    NetworkStatus status = number.integerValue;
    DLog(@"HMUdpAPI -- 收到网络变化通知 status: %d",status);

    if(status == NotReachable || status == ReachableViaWWAN){
        [self closeUdpSocket];
    }else {
        
    }
}

- (void)closeUdpSocket {
    LogFuncName();
    [self.udpSocket close];
    self.udpSocket = nil;
}

+ (void)lanCommunicationKeyWithFamilyId:(NSString *)familyId callBlock:(void(^)(NSString *lanCommunicationKey))block {
    [HMUdpBusiness lanCommunicationKeyWithFamilyId:familyId callBlock:block];
}
+ (void)queryNewestLanCommunicationKeyFromServerWithFamilyId:(NSString *)familyId callBlock:(void(^)(NSString *lanCommunicationKey))block {
    [HMUdpBusiness queryNewestLanCommunicationKeyFromServerWithFamilyId:familyId callBlock:block];
}

- (void)dealloc {
    [self hm_removeAllObserver];
}



@end
