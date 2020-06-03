//
//  VhAPSocket.m
//  HomeMateSDK
//
//  Created by Orvibo on 15/8/6.
//  Copyright © 2017年 Orvibo. All rights reserved.
//

#import "HMAPSocket.h"
#import "GCDAsyncSocket.h"
#import "HMAPGetIp.h"
#include <arpa/inet.h>
#import <netdb.h>
#import <sys/socket.h>
#import "HMConstant.h"


@interface HMAPSocket () <GCDAsyncSocketDelegate>
{
    GCDAsyncSocket * _socket;

}

@property (nonatomic, assign) id <VhApSocketDelegate> delegate;

@end


@implementation HMAPSocket


- (instancetype)initWithDelegate:(id <VhApSocketDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;

    }
    
    return self;
}

//断开连接
- (void)disconnectSocket
{
    if(_socket)
    {
        if ([_socket isConnected]) {
            [_socket disconnect];
            [_socket setDelegate:nil];
        }
    }
}
- (void)connectToHost {
    if ([_socket isConnected]) {
        [self disconnectSocket];

    }
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

//    _socket = [[AsyncSocket alloc] initWithDelegate:self];
//    DLog(@"连接Socket = %@",_socket);
    
    
    NSString * ip = [HMAPGetIp getIp];
    DLog(@"wifi配置 连接Socket = %@ ip = %@",_socket,ip);

    NSError *error = nil;
    uint16_t port = 8295;
    BOOL connected = [_socket connectToHost:ip onPort:port error:&error];
    if (connected) {

    }

}
/**
 *  判断是否连接
 *
 *  @return bool
 */
- (BOOL)isConnectedToCOCO {
    return [_socket isConnected];
}
//发送数据
- (void)sendData:(NSData *)binaryData{
    
    if(_socket) {
        [_socket writeData:binaryData withTimeout:-1 tag:0];
    }
}
#pragma mark -  GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    [self.delegate onDeliverData:data];
    
    [sock readDataWithTimeout:-1 tag:tag];
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [sock readDataWithTimeout:-1 tag:0];
    
    [self.delegate didConnected];
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [sock readDataWithTimeout:-1 tag:tag];
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    DLog(@"断开Socket = %@",sock);
    if (sock == nil) {
        DLog(@"sock 为空值了");
    }
    if(err && [err code] == GCDAsyncSocketConnectTimeoutError) {
        if (self.delegate) {
            [self.delegate onConnectTimeout];
        }
    }else {
        if (self.delegate) {
            [self.delegate onDisconnectWithError:err];
        }
    }
   
}


- (BOOL)isconnected {
    
    return [_socket isConnected];
    
}
@end
