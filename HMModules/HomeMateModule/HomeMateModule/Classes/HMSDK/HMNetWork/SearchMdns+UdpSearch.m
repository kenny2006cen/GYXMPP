//
//  SearchMdns+UdpSearch.m
//  HomeMate
//
//  Created by Air on 15/10/10.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "SearchMdns+UdpSearch.h"
#import "NSData+CRC32.h"
#import "NSData+AES.h"
#import "HMConstant.h"



@implementation SearchMdns (UdpSearch)


/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the connection is successful.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    DLog(@"%s",__FUNCTION__);
}

/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the connection fails.
 * This may happen, for example, if a domain name is given for the host and the domain name is unable to be resolved.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    DLog(@"%s",__FUNCTION__);
}

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    DLog(@"%s",__FUNCTION__);
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    DLog(@"%s",__FUNCTION__);
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    
    if (host) {
        [self didReceiveData:data fromHost:host port:port];
    }
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    DLog(@"%s",__FUNCTION__);
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
            NSString *key =  PUBLICAEC128KEY;
            
            //DLog(@"key:%@",[protocolType isEqualToString:@"dk"] ? @"UDP密钥类型错误" : key);
            
            NSData *crcData = [data subdataWithRange:NSMakeRange(6, 4)];
            NSUInteger receive_crc = getCrcValue(crcData);
            
            NSData * payLoadData = [data subdataWithRange:NSMakeRange(42, length - 42)];
            
            NSUInteger check_crc = [payLoadData hm_crc32];
            
            if (receive_crc == check_crc) {

                NSData * decrytedpayLoadData = [payLoadData hm_AES128DecryptWithKey:key iv:nil];
                
                if (decrytedpayLoadData)
                {
                    NSDictionary * payloadDic = [NSJSONSerialization JSONObjectWithData:decrytedpayLoadData options:NSJSONReadingAllowFragments error:nil];
                    
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
                                
                                [self didFindGateway:nil udpInfo:dic];
                            }
                            
                        }
                        
                    }else {
                        
                        int lenNum = [data hm_protocolLength];
                        int length = (int)data.length;
                        
                        DLog(@"----------数据异常 实际长度:%d 协议长度:%d----------",length,lenNum);
                        DLog(@"----------数据异常 无法转换为UTF8字符串:\n%@----------,当前秘钥:%@",decrytedpayLoadData, PUBLICAEC128KEY);
                    }
                }else {
                    DLog(@"----------数据异常 解密失败:\n%@----------",decrytedpayLoadData);
                }
                
            }else {
                
                DLog(@"----------数据异常 crc 校验失败\n%@----------",data);
                DLog(@"___当前秘钥:%@", PUBLICAEC128KEY);
            }
            
        }else {
            DLog(@"----------数据异常 长度小于42:\n%@----------",data);
        }
    }else {
        DLog(@"----------数据异常 长度小于6:\n%@----------",data);
    }
    
    return YES;
}

@end
