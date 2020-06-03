//
//  Gateway+Tcp.m
//  Vihome
//
//  Created by Air on 15-1-27.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "Gateway+Tcp.h"
#import "Gateway+Receive.h"
#import "HMConstant.h"


@implementation Gateway (Tcp)


- (void)socket:(GlobalSocket *)sock didAcceptNewSocket:(GlobalSocket *)newSocket
{
    DLog(@"tcp --- socket accepts a connection");
}

- (void)socket:(GlobalSocket *)sock didConnectToHost:(NSString *)host_ port:(uint16_t)port_
{
    DLog(@"tcp --- socket链接正式建立 ip:%@ port:%d",host_,port_);
    [sock socketStartTls];
}

- (void)socket:(GlobalSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler {
    [sock socket:sock didReceiveTrust:trust completionHandler:completionHandler];
}

- (void)socketDidSecure:(GlobalSocket *)sock {
    DLog(@"SSL握手成功，安全通信链接已建立");
}

- (void)socket:(GlobalSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    {
        //DLog(@"tcp --- socke接收到数据报 长度:%d",data.length);
        
#if 0
        if (data.length > 42) {
            NSData * payLoadData = [data subdataWithRange:NSMakeRange(42, data.length - 42)];
            DLog(@"↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓");
            NSString * payloadString = [payLoadData description];
            payloadString = [payloadString stringByReplacingOccurrencesOfString:@"<" withString:@""];
            payloadString = [payloadString stringByReplacingOccurrencesOfString:@" " withString:@""];
            payloadString = [payloadString stringByReplacingOccurrencesOfString:@">" withString:@""];
            DLog(@"\npayLoad:\n%@",payloadString);
            DLog(@"↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑");
        }
#endif
        
        
        [self handleUdpTcpData:data socket:sock]; // tcp 协议层会自己把小的数据包封装成大的数据包，此处要解包
        
        [sock readDataWithTimeout:-1 tag:0];
        
    }
}

- (void)socket:(GlobalSocket *)sock didWriteDataWithTag:(long)tag
{
    // DLog(@"tcp --- socket数据报发送完毕 tag:%d",tag);
}

- (NSTimeInterval)socket:(GlobalSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    DLog(@"tcp --- socke接收数据报超时 tag:%d",tag);
    return 0;
}
- (NSTimeInterval)socket:(GlobalSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    DLog(@"tcp --- socke发送数据报超时 tag:%d",tag);
    return 0;
}

- (void)socketDidDisconnect:(GlobalSocket *)sock withError:(NSError *)err
{
    sock.encryptionKey = nil;// socket 关闭之后就将 通信密钥置空，下次通信的时候重新申请
    
    self.isGrouping = NO;
    self.groupData = nil;
    DLog(@"%@ --- socket确认关闭",sock.uid ? [NSString stringWithFormat:@"uid:%@",sock.uid] : @"server");
}

@end
