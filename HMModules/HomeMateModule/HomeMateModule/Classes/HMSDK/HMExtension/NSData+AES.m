//
//  NSData+AES.m
//  KeplerSDK
//
//  Created by Ned on 14-7-22.
//  Copyright (c) 2014年 orvibo. All rights reserved.
//

#import "NSData+AES.h"
#import <CommonCrypto/CommonCryptor.h>
#import "HMConstant.h"


@implementation NSData (AES)

-(char *)stringFromHexString:(NSString *)hexString {//
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 +1);
    if(hexString.length < 2) {
        DLog(@"蓝牙蓝牙蓝牙蓝牙蓝牙蓝牙蓝牙蓝牙蓝牙蓝牙蓝牙蓝牙蓝牙蓝牙 私钥错误 %@",hexString);
        
        return myBuffer;
    }
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i =0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr] ;
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
//        DLog(@"myBuffer is %c",myBuffer[i /2] );
    }
//    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
//    DLog(@"———字符串=======%@",unicodeString);
    return myBuffer;
}

- (NSData *)hm_AES128EncryptWithHexKey:(NSString *)key iv:(NSString *)iv {
    char * string = [self stringFromHexString:key];
    return [self hm_AES128EncryptWithBufferKey:string iv:iv];
}



- (NSData *)hm_AES128DecryptWithHexKey:(NSString *)key iv:(NSString *)iv {
    
    if(key.length == 0){
        DLog(@"蓝牙蓝牙蓝牙蓝 解密秘钥错误，尝试用公钥解密");
        return [self hm_AES128DecryptWithKey:PUBLICAEC128KEY iv:nil];
    }
    
    char * string = [self stringFromHexString:key];
    return [self hm_AES128DecryptWithBufferKey:string iv:iv];
}

- (NSData *)hm_AES128EncryptWithBufferKey:(char *)key iv:(NSString *)iv
{
    return [self hm_AES128Operation:kCCEncrypt bufferKey:key iv:iv];
}

- (NSData *)hm_AES128DecryptWithBufferKey:(char *)key iv:(NSString *)iv
{
    return [self hm_AES128Operation:kCCDecrypt bufferKey:key iv:iv];
}


- (NSData *)hm_AES128Operation:(CCOperation)operation bufferKey:(char *)key iv:(NSString *)iv
{
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128 + 1024;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionECBMode | kCCOptionPKCS7Padding,
                                          key,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:numBytesCrypted];
        free(buffer);
        return [NSData dataWithData:data];
    }
    
    return nil;
}




- (NSData *)hm_AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self hm_AES128Operation:kCCEncrypt key:key iv:iv];
}

- (NSData *)hm_AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self hm_AES128Operation:kCCDecrypt key:key iv:iv];
}

- (NSData *)hm_AES128Operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128 + 1024;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;

    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionECBMode | kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:numBytesCrypted];
        free(buffer);
        return [NSData dataWithData:data];
    }
    
    return nil;
}

- (NSData *)hm_cipherData:(NSData *)data key:(NSString *)key
{
    return [self hm_aesOperation:kCCEncrypt OnData:data key:key];
}

- (NSData *)hm_decipherData:(NSData *)data key:(NSString *)key
{
    return [self hm_aesOperation:kCCDecrypt OnData:data key:key];
}


- (NSData *)hm_aesOperation:(CCOperation)op OnData:(NSData *)data  key:(NSString *)encKey
{
    NSData *outData = nil;
    
    int BUFFER_SIZE=16;
    // Data in parameters
    char * keyPtr = nil;// (__bridge const void *)([NSData dataWithBase64EncodedString:encKey]);
    [encKey getCString:keyPtr maxLength:sizeof(encKey) encoding:NSUTF8StringEncoding];
    keyPtr = (char *)[encKey cStringUsingEncoding:NSUTF8StringEncoding];
    const void *dataIn = data.bytes;
    size_t dataInLength = data.length;
    // Data out parameters
    size_t outMoved = 0;
    
    // Init out buffer
    unsigned char outBuffer[BUFFER_SIZE];
    memset(outBuffer, 0, BUFFER_SIZE);
    CCCryptorStatus status = -1;
    
    status = CCCrypt(op, kCCAlgorithmAES128, kCCOptionECBMode, keyPtr, kCCKeySizeAES256, NULL,
                     dataIn, dataInLength, &outBuffer, BUFFER_SIZE, &outMoved);
    
    if(status == kCCSuccess) {
        outData = [NSData dataWithBytes:outBuffer length:outMoved];
    }
    else if(status == kCCBufferTooSmall) {
        // Resize the out buffer
        size_t newsSize = outMoved;
        void *dynOutBuffer = malloc(newsSize);
        memset(dynOutBuffer, 0, newsSize);
        outMoved = 0;
        
        status = CCCrypt(op, kCCAlgorithmAES128, kCCOptionECBMode, keyPtr, kCCKeySizeAES256, NULL,
                         dataIn, dataInLength, &outBuffer, BUFFER_SIZE, &outMoved);
        
        if(status == kCCSuccess) {
            outData = [NSData dataWithBytes:outBuffer length:outMoved];
        }
        
        free(dynOutBuffer);
    }
    
    return outData;
}

-(int)hm_protocolLength
{
    if (self.length >= 4) {
        
        NSString *head = asiiStringWithData([self subdataWithRange:NSMakeRange(0, 2)]);
        if ([head isEqualToString:@"hd"]) {
            
            //数据长度
            NSData *len = [self subdataWithRange:NSMakeRange(2, 2)];
            Byte *lenByte = (Byte *)malloc([len length]);
            memcpy(lenByte, [len bytes], [len length]);
            int lenNum = lenByte[1] | (lenByte[0] << 8);
            free(lenByte);
            return lenNum;
            
        }else{
            DLog(@"数据头错误，直接抛弃此数据包：%@",self);
        }
    }
    return 0;
}

@end
