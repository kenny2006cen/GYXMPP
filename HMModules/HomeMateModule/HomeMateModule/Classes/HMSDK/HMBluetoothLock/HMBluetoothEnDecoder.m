//
//  HMBluetoothEnDecoder.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/10/23.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBluetoothEnDecoder.h"
#import "NSData+CRC32.h"
#import "HMBluetoothLockManager.h"
@implementation HMBluetoothEnDecoder

#pragma mark - 拼接发送数据
/**
 按协议拼接要发送的命令
 
 @param cmd 要发送的命令
 @return 拼接的数据
 */
+ (NSData *)enCoderCmd:(HMBluetoothCmd *)cmd {
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionaryWithDictionary:cmd.payload];
    int cmdInt = [[payload objectForKey:@"cmd"] intValue];
    if (cmdInt == HMBluetoothLockCmdType_FirmwareDataTransmission ||
        cmdInt == HMBluetoothLockCmdType_TerminateFirmwareUpgrade) {// 这个命令不是json格式，要单独处理
        
        return [self encodeFirmwareDataTransmissionCmd:cmd];
    }
    
    NSNumber * serialNum = [payload objectForKey:@"serial"];
    if (serialNum == nil) {
        short serial = cmd.serial;
        [payload setObject:@(serial) forKey:@"serial"];
    }
    DLog(@"蓝牙写数据，写数据加密之前payload = %@",payload);
    NSError * error = nil;
    NSData * originalPayLoadData = [NSJSONSerialization dataWithJSONObject:payload
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&error];
    if (error) {
        DLog(@"cmd = %d payLoad转data发生错误 %@",[payload objectWithKey:@"cmd"],error);
        return nil;
    }
    //加密后的payload数据
    NSString * encodeKey = @"";
    NSData * encryptedPayLoadData = [NSData data];
    if (cmd.EncryptKey == 0) {//公钥加密
        DLog(@"蓝牙写数据，payload加密密类型为公钥 公钥为 = %@",PUBLICAEC128KEY);
        encodeKey = PUBLICAEC128KEY;
        encryptedPayLoadData = [originalPayLoadData hm_AES128EncryptWithKey:encodeKey iv:nil];
    }else {// 私钥加密
        NSString * priviteKey = [[HMBluetoothLockManager defaultManager] getLockPrivateKey];
        DLog(@"蓝牙写数据，payload加密密类型为私钥 私钥为 = %@",priviteKey);
        encodeKey = priviteKey;
       encryptedPayLoadData = [originalPayLoadData hm_AES128EncryptWithHexKey:encodeKey iv:nil];
    }
    
    NSMutableData * data = [[NSMutableData alloc] init];
    
    //拼接协议头
    NSData * headData = [self headData];
    [data appendData:headData];
    
    //拼接包的总长度
    int protoclLenth = (int)[encryptedPayLoadData length] + 13;
    NSData * protoclLenthData = [self bigToSmallEndOrigin:protoclLenth length:4];
    [data appendData:protoclLenthData];

//    [data appendData:[NSData dataWithBytes: &protoclLenth length: 4]];
    
    //拼接包的流水序号
    NSData * serialData = [self bigToSmallEndOrigin:cmd.serial length:2];
    [data appendData:serialData];
//    short serial = cmd.serial;
//    [data appendData:[NSData dataWithBytes: &serial length: 2]];

    //拼接包的帧命令
    NSData * frameCommandData = [self frameCommandData:cmd];
    [data appendData:frameCommandData];
    
    //拼接加密后payload
    [data appendData:encryptedPayLoadData];
    
    //除CRC的所有数据的校验码
    int crc = [data hm_crc32];
    NSData * crcData = [self bigToSmallEndOrigin:crc length:4];
    [data appendData:crcData];
//    [data appendData:[NSData dataWithBytes: &crc length: 4]];
    
    return data;
}

+ (NSData *)encodeFirmwareDataTransmissionCmd:(HMBluetoothCmd *)cmd {
    
    NSMutableData * data = [[NSMutableData alloc] init];
    NSData * headData = [self headData];
    [data appendData:headData];
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionaryWithDictionary:cmd.payload];
    int cmdInt = [[payload objectForKey:@"cmd"] intValue];
    
    NSMutableData * payloadData = [NSMutableData data];
    //拼接cmd
    NSData *cmdData = [NSData dataWithBytes: &cmdInt length: 1];
    [payloadData appendData:cmdData];
    
    //拼接流水号
    short serial = cmd.serial;
    NSData * serialData = [self bigToSmallEndOrigin:serial length:2];
    [payloadData appendData:serialData];
    
    if(cmdInt == HMBluetoothLockCmdType_FirmwareDataTransmission){
    //拼接固件数据
        NSData * firmData = [payload objectForKey:@"firmwareSendData"];
        [payloadData appendData:firmData];
        DLog(@"固件加密之前bin data发送数据 firmData %@，payloadData",firmData,payloadData);
    }
    

    NSData * encryptedPayLoadData = [NSData data];

    
    NSString * encodeKey = @"";
    if (cmd.EncryptKey == 0) {//公钥加密
        DLog(@"蓝牙固件升级写数据，payload加密密类型为公钥 公钥为 = %@",PUBLICAEC128KEY);
        encodeKey = PUBLICAEC128KEY;
        encryptedPayLoadData = [payloadData hm_AES128EncryptWithKey:encodeKey iv:nil];
    }else {// 私钥加密
        NSString * priviteKey = [[HMBluetoothLockManager defaultManager] getLockPrivateKey];
        DLog(@"蓝牙固件升级写数据，payload加密密类型为私钥 私钥为 = %@",priviteKey);
        encodeKey = priviteKey;
        encryptedPayLoadData = [payloadData hm_AES128EncryptWithHexKey:encodeKey iv:nil];
    }
    
    
    //拼接包的总长度
    int protoclLenth = (int)[encryptedPayLoadData length] + 13;
    NSData * protoclLenthData = [self bigToSmallEndOrigin:protoclLenth length:4];
    [data appendData:protoclLenthData];
    
    //拼接包的流水序号
    NSData * totalSerialData = [self bigToSmallEndOrigin:cmd.serial length:2];
    [data appendData:totalSerialData];
    
    
    //拼接包的帧命令
    NSData * frameCommandData = [self frameCommandData:cmd];
    [data appendData:frameCommandData];
    
    [data appendData:encryptedPayLoadData];
    
    
    int crc = [data hm_crc32];
    NSData * crcData = [self bigToSmallEndOrigin:crc length:4];
    [data appendData:crcData];
    
    DLog(@"固件升级发送数据长度%i %@",data.length,data);
    
    return data;
    
}

/// 帧命令
/// @param cmd cmd
+(NSData *)frameCommandData:(HMBluetoothCmd *)cmd {
    Byte ackReq = (Byte) (cmd.ACKRequire & 0xFF);
    Byte ackFlag = (Byte) (cmd.ACKFlag & 0xFF);
    Byte fcmd = (Byte) (cmd.frameCommand & 0xFF);
    Byte encrypt = (Byte) (cmd.EncryptKey & 0xFF);
    Byte cmdByte = (Byte) ((ackReq << 7) | (ackFlag << 6) | (encrypt << 5) | (fcmd & 0x1F));
    NSData *data = [NSData dataWithBytes: &cmdByte length: 1];
    return data;
}

/**
 大端转小端 高8位在第一个字节，低8位在最后字节
 
 @param origin 源数据
 @param length 长度
 @return 转换后的NSData
 */
+ (NSData *)bigToSmallEndOrigin:(int)origin length:(int)length {
    Byte *byte = (Byte*)malloc(length);
    if (2 == length){
        byte[1] = origin >> 8;
        byte[0] = origin;
    }else if (4 == length){
        byte[3] = origin >> 24;
        byte[2] = origin >> 16;
        byte[1] = origin >> 8;
        byte[0] = origin;
    }
    NSData * data = [NSData dataWithBytes:byte length:length];
    return data;
}

/// 协议头
+ (NSData *)headData {
    Byte * headByte = (Byte*)malloc(2);
    headByte[0] = 0x55;
    headByte[1] = 0xaa;
    NSData *  headData = [NSData dataWithBytes: headByte length: 2];
    return headData;
    
}
#pragma mark - 解析收到的数据
/**
 解析接收到的数据
 
 @param data 接收的数据
 @return 解析到的cmd
 */
+ (HMBluetoothCmd *)deCoderData:(NSData *)data {
    // 判断要解包数据的长度是不是合法
    if(data.length <= 13) {
        DLog(@"蓝牙接收到数据长度有问题 收到数据长度是 %d",data.length);
        return nil;
    }
    
    //判断包头是否正确
    NSData * headData = [data subdataWithRange:NSMakeRange(0, 2)];
    if([self headError:headData]) {// 包头错误
        DLog(@"蓝牙接收到数据包头错误");
        return nil;
    }
    
    // 判断crc校验是否正确
    if([self crcError:data]) {
        DLog(@"蓝牙接收到数据crc校验错误");
        return nil;
    }
    
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    //序列号
    NSData * serialData = [data subdataWithRange:NSMakeRange(6, 2)];
//    cmd.serial = [self cmdSerial:serialData];
    short serial;
    [serialData getBytes:&serial length:2];
    cmd.serial = serial;

    
    //帧命令
    NSData * frameCommandData = [data subdataWithRange:NSMakeRange(8, 1)];
    cmd = [self cmdFrameCommand:cmd frameCommandData:frameCommandData];
    
    // payload
    NSData * payloadData = [data subdataWithRange:NSMakeRange(9, data.length - 13)];
    NSDictionary * payloadDic = [self cmdPayloadData:payloadData cmd:cmd];
    if (payloadDic == nil) {
        DLog(@"蓝牙接收到数据payload错误");
        return nil;
    }
    cmd.payload = payloadDic;
    
    return cmd;
}


/**
 判断CRC是否错误

 @param originData 需要校验的数据
 @return NO crc正确 YES crc 错误
 */
+ (BOOL)crcError:(NSData *)originData {
    NSData * crcData = [originData subdataWithRange:NSMakeRange(originData.length - 4, 4)];
//    int receiveCRC = [self smallTobigEndOrigin:crcData];
    int receiveCRC;
    [crcData getBytes:&receiveCRC length:4];

    NSData * checkData = [originData subdataWithRange:NSMakeRange(0, originData.length - 4)];
    int localCRC = [checkData hm_crc32];
    DLog(@"蓝牙接收到数据校验crc = %d,本地校验数据crc = %d",receiveCRC,localCRC);
    if (receiveCRC == localCRC) {
        return NO;
    }else {
        return YES;
    }
}

/**
 判断包头是否有错误

 @param headData 包头数据
 @return YES 包头错误  NO 包头正确
 */
+ (BOOL)headError:(NSData *)headData {
    Byte *headByte = (Byte *)malloc([headData length]);
    memcpy(headByte, [headData bytes], [headData length]);
    int byte1 = headByte[1];
    int byte0 = headByte[0];
    if (byte1 == 0xaa && byte0 == 0x55) {
        return NO;
    }else {
        return YES;
    }
}

/// 解析payload
/// @param payloadData payloadData
/// @param cmd 根据已经解析cmd来判断是公钥还是私钥
+ (NSDictionary *)cmdPayloadData:(NSData *)payloadData cmd:(HMBluetoothCmd *)cmd{
    NSString * decodeKey = @"";
    NSData * decrytedpayLoadData = [NSData data];

    if (cmd.EncryptKey == 0) {//公钥解密
        decodeKey = PUBLICAEC128KEY;
        DLog(@"蓝牙接收到数据payload解密类型为公钥 公钥为 = %@",PUBLICAEC128KEY);
        decrytedpayLoadData = [payloadData hm_AES128DecryptWithKey:decodeKey iv:nil];
    }else {//私钥解密
        NSString * priviteKey = [[HMBluetoothLockManager defaultManager] getLockPrivateKey];
        DLog(@"蓝牙接收到数据，payload加密密类型为私钥 私钥为 = %@",priviteKey);
        decodeKey = priviteKey;
        decrytedpayLoadData = [payloadData hm_AES128DecryptWithHexKey:decodeKey iv:nil];

    }
    
    if (decrytedpayLoadData == nil) {
        DLog(@"蓝牙接收到数据payload解密错误 payload = %@",payloadData);
        return nil;
    }
    NSString * decryptionString  = [[NSString alloc] initWithData:decrytedpayLoadData encoding:NSUTF8StringEncoding];
    if (decryptionString.length == 0) {
        DLog(@"蓝牙接收到数据payload解密之后转成字符串错误 payload = %@",payloadData);
        return nil;
    }
    NSString *rightString = [decryptionString stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    DLog(@"蓝牙接收到数据payload解密之后转成字符串 payload = %@",rightString);
    NSData *data = [rightString dataUsingEncoding:NSUTF8StringEncoding];
    if(data == nil) {
        DLog(@"蓝牙接收到数据payload解密之后转成NSDictionary时Data出错 payload = %@",rightString);
        return nil;
    }
    NSDictionary * payloadDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (payloadDic == nil) {
        DLog(@"蓝牙接收到数据payload解密之后转成NSDictionary时出错 payload = %@",rightString);
        return nil;

    }
    return payloadDic;
}


/**
 给cmd的ACKRequire、ACKFlag、EncryptKey、frameCommand赋值

 @param cmd 需要赋值的cmd
 @param data 要解析的数据
 @return 传入的cmd
 */
+ (HMBluetoothCmd *)cmdFrameCommand:(HMBluetoothCmd *)cmd frameCommandData:(NSData *)data {
    Byte byte;
    [data getBytes:&byte length:1];
    
    cmd.ACKRequire = (byte & 0x80) >> 7;
    cmd.ACKFlag = (byte & 0x40) >> 6;
    cmd.EncryptKey = (byte & 0x20) >> 5;
    cmd.frameCommand = byte & 0x1F;
    return cmd;
}


/**
 获取cmd的序列号

 @param data 序列号data
 @return 序列号
 */
+ (short)cmdSerial:(NSData *)data {
    Byte *serialByte = (Byte *)malloc([data length]);
    memcpy(serialByte, [data bytes], [data length]);
    short serial = serialByte[0] << 8 | serialByte[1] ;
    return serial;
}

/**
 小端转大端 低8位在第一个字节，高8位在最后字节
 
 @param originData 需要装换的数据
 @return 转换后的int
 */
+ (int)smallTobigEndOrigin:(NSData *)originData{
    NSUInteger length = originData.length;
    Byte *byte = (Byte*)malloc(length);
    if (2 == length){
        memcpy(byte, [originData bytes], length);
        short serial = byte[0] << 8 | byte[1] ;
        return serial;
    }else if (4 == length){
        memcpy(byte, [originData bytes], [originData length]);
        unsigned int value = byte[3]| (byte[2] << 8) | (byte[1] << 16) | (byte[0] << 24);
        return value;
    }
    return 0;
}

/**
 计算包的长度
 
 @param data 表示包长度的data
 @return 包的长度
 */
+ (int)headLenth:(NSData *)data {
    int headLenth;
    [data getBytes:&headLenth length:4];
    return headLenth;
    return [self smallTobigEndOrigin:data];
}
@end
