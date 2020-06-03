//
//  VhAPConfigEnDecoder.m
//  HomeMateSDK
//
//  Created by Orvibo on 15/8/6.
//  Copyright © 2017年 Orvibo. All rights reserved.
//

#import "HMAPConfigEnDecoder.h"
#import "NSData+AES.h"
#import "NSData+CRC32.h"
#import "HMConstant.h"

static HMAPConfigEnDecoder * deEncoder = nil;

@interface HMAPConfigEnDecoder ()

@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation HMAPConfigEnDecoder

{
    NSUInteger payLoadlength;
    NSUInteger CRC;
}

+ (instancetype)defaultEnDecoder {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deEncoder = [[HMAPConfigEnDecoder alloc] init];
        deEncoder.dataArray = [NSMutableArray array];
    });
    
    
    return deEncoder;
}
-(NSString *)head
{
    return @"hd";
}
-(NSUInteger)len
{
    return (payLoadlength + 42);
}

-(NSMutableData *)headData:(NSData *)payloadData
{
    payLoadlength = [payloadData length];
    
    NSMutableData * headData = [[NSMutableData alloc] init];
    
    [headData appendData:[[self head] dataUsingEncoding:NSASCIIStringEncoding]];
    headData = [self appendData:headData withInt:self.len length:2 reverse:YES];
    
    NSString *type =  @"pk";
    [headData appendData:[type dataUsingEncoding:NSASCIIStringEncoding]];
    
    int crc1 = [payloadData hm_crc32];
    
    CRC = crc1;
   headData = [self appendData:headData withInt:CRC length:4];
    
    NSString *_session = @"kjdbvjdfbkvdsj";
    NSString *session = (_session.length > 0) ? _session : @"00000000000000000000000000000000";
    NSData * sessionData = stringToData(session, 32);
    
    [headData appendData:sessionData];
    
    return headData;
}
-(NSMutableData *)appendData:(NSMutableData*)sourceData withInt:(NSUInteger)data length:(NSUInteger)length
{
    if (length == 4) {
        
        Byte * CRCByte = (Byte*)malloc(4);
        CRCByte[0] = data >> 24;
        CRCByte[1] = data >> 16;
        CRCByte[2] = data >> 8;
        CRCByte[3] = data;
        
        [sourceData appendBytes:CRCByte length:4];
        free(CRCByte);
        //        Byte *myByte = (Byte*)malloc(4);
        //        myByte[0] = data;
        //        myByte[1] = data >> 8;
        //        myByte[2] = data >> 16;
        //        myByte[3] = data >> 24;
        //        [self appendBytes:myByte length:length];
        //        free(myByte);
        return sourceData;
    }
    return [self appendData:sourceData withInt:data length:length reverse:NO];
}
-(NSMutableData *)appendData:(NSMutableData *)sourceData withInt:(NSUInteger)data length:(NSUInteger)length reverse:(BOOL)reverse
{
    Byte *myByte = (Byte*)malloc(length);
    
    if (1 == length) {
        
        myByte[0] = data;
        
    }else if (2 == length){
        
        if (reverse) {
            // 明确表示高8位与低8位的顺序，高8位在第一个字节，低8位在第二个字节
            myByte[0] = data >> 8;
            myByte[1] = data;
            
        }else {
            // 未明确表示高8位与低8位的顺序,低8位在第一个字节，高8位在第二个字节
            myByte[0] = data;
            myByte[1] = data >> 8;
        }
        
    }
    else {
        abort(); // 无法处理，给出异常
    }
    
    [sourceData appendBytes:myByte length:length];
    
    free(myByte);
    
    return sourceData;
}
-(NSData *)dataForMsg:(HMAPConfigMsg *)msg
{
    DLog(@"HMOpenSDK:AP发送数据内容:%@",msg.msgBody);

    NSError * error = nil;
    NSData * originalPayLoadData = [NSJSONSerialization dataWithJSONObject:msg.msgBody
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&error];
    
    NSData * encryptedPayLoadData = [originalPayLoadData hm_AES128EncryptWithKey:@"khggd54865SNJHGF" iv:nil];
    
    
    NSMutableData * sendData = [self headData:encryptedPayLoadData];
    [sendData appendData:encryptedPayLoadData];
    DLog(@"HMOpenSDK:AP发送加密数据:%@",sendData);
    return sendData;
}
- (NSData *)encoderWithMsg:(HMAPConfigMsg *)msg {

    NSData * data = [self dataForMsg:msg];
    
    return data;
}

- (NSMutableArray *)decoderWithData:(NSData *)data {
    
    DLog(@"AP data %@",data);
    DLog(@"收到ap配置数据转成asi字符串 = %@",asiiStringWithData(data));
    NSMutableArray * allMsg = [NSMutableArray array];
    
    NSMutableData * allData = [NSMutableData data];
    if (self.leftData.length) {
        DLog(@"上一包数据有剩余，先判断是不是需要组包");
        
        NSString * head = [self getProtoclDataHead:data];
        
        DLog(@"ap 先尝试解新数据包头=%@",head);
        
        if ([head rangeOfString:@"hd"].length) {
            DLog(@"新数据包头正确 不需要拼接了");
            self.leftData = nil;
            [allData appendData:data];
            
        }else {
            DLog(@"新数据包头错误 需要拼接剩余数据");
            [allData appendData:self.leftData];
            [allData appendData:data];
            DLog(@"组包后的数据 %@",allData);
            DLog(@"组包后的数据 数据包协议长度 = %d 数据长度 = %d 数据头 = %@",[self apProtcolLength:allData],allData.length,[self getProtoclDataHead:allData]);
        }
        
    }else {
        [allData appendData:data];
        
    }
    __weak typeof(self) weakSelf = self;
    [self arrayWithData:allData callback:^(NSData *data) {
        
        NSUInteger length = data.length;
        if (length > 42)
        {
            DLog(@"拆包之后 AP配置 数据包协议长度 = %d 数据长度 = %d，数据头 = %@",[data hm_protocolLength],data.length,[self getProtoclDataHead:data]);
            
            NSData *crcData = [data subdataWithRange:NSMakeRange(6, 4)];
            NSUInteger receive_crc = getCrcValue(crcData);
            
            NSData * payLoadData = [data subdataWithRange:NSMakeRange(42, length - 42)];
            
            NSUInteger check_crc = [payLoadData hm_crc32];
            DLog(@"ap配置收到crc = %d 本地 解析crc = %d",receive_crc,check_crc);
            if (receive_crc == check_crc ) {
                
                NSString *key =  PUBLICAEC128KEY;
                
                NSData * decrytedpayLoadData = [payLoadData hm_AES128DecryptWithKey:key iv:nil];
                NSString * decryptionString  = [[NSString alloc] initWithData:decrytedpayLoadData encoding:NSUTF8StringEncoding];
                DLog(@"AP配置接收解密字符串 = %@",decryptionString);
                if (decryptionString)
                {
                    NSString *rightString = [decryptionString stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                    NSData *data = [rightString dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary * payloadDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    if (payloadDic) {
                        
                        DLog(@"AP接收数据内容:%@",payloadDic);
                        int cmd = [[payloadDic objectForKey:@"cmd"] intValue];
                        
                        HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
                        msg.cmd = cmd;
                        msg.msgBody = payloadDic;
                        [allMsg addObject:msg];
                        
                    }else {
                        DLog(@"AP配置接收payloadDic 要把剩余包 清空 等待新包");
                        weakSelf.leftData = nil;
                        
                    }
                    
                }else {
                    DLog(@"AP配置接收解密字符串为空 要把剩余包 清空 等待新包");
                    weakSelf.leftData = nil;
                }
                
            }else {
                
                DLog(@"ap配置 crc校验码不对 要把剩余包 清空 等待新包");
                weakSelf.leftData = nil;
                
                
            }
            
        }else {
            
        }
        
        
    }];
    
    
    
    DLog(@"all msg %@",allMsg);
    
    return allMsg;
}

- (void)arrayWithData:(NSData *)data callback:(void(^)(NSData * data))back {
    if (data.length > 4) {
        
        int staue = [self apProtcolLength:data] ;
        DLog(@"拆包之前 AP配置 数据包协议长度 = %d 数据长度 = %d 数据头 = %@",staue,data.length,[self getProtoclDataHead:data]);
        
        if (data.length >= staue) {
            
            NSData * subData = [data subdataWithRange:NSMakeRange(0, staue)];
            self.leftData = nil;
            back(subData);
            
            
            NSData * leftSubData = [data subdataWithRange:NSMakeRange(staue, data.length - staue)];
            
            if (leftSubData.length) {
                
                [self arrayWithData:leftSubData callback:back];
                
            }
            
        }else {
            DLog(@"一包数据有多余，先保存");
            DLog(@"多余数据%@，长度%d，包的长度%d",data,data.length,staue);
            DLog(@"多余数据 数据包协议长度 = %d 数据长度 = %d 数据头 = %@",staue,data.length,[self getProtoclDataHead:data]);
            self.leftData = [NSMutableData dataWithData:data];
            
        }
        
        
    }
    
}

- (int)apProtcolLength:(NSData *)data {
    NSData * lenthData = [data subdataWithRange:NSMakeRange(2, 2)];
    Byte *satueByte = (Byte *)malloc([lenthData length]);
    memcpy(satueByte, [lenthData bytes], [lenthData length]);
    int staue = satueByte[0] << 8 | satueByte[1] ;
    return staue;
}
- (NSString *)getProtoclDataHead:(NSData *)data {
    
    if (data.length >= 4) {
        
        NSString *head = asiiStringWithData([data subdataWithRange:NSMakeRange(0, 2)]);
        return head;
    }
    return @"";
    
}


@end
