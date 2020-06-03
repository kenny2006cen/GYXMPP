//
//  NSMutableData+Socket.m
//  ABB
//
//  Created by orvibo on 14-3-10.
//  Copyright (c) 2014年 orvibo. All rights reserved.
//

#import "NSMutableData+Socket.h"


@implementation NSMutableData (Socket)

-(NSMutableData *)appendDataWithInt:(NSUInteger)data length:(NSUInteger)length reverse:(BOOL)reverse
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
    
    [self appendBytes:myByte length:length];
    
    free(myByte);
    
    return self;
}

-(NSMutableData *)fillWithInt:(int)data length:(NSUInteger)length
{
    Byte *myByte = (Byte*)malloc(length);
    memset(myByte, data, length);
    [self appendBytes:myByte length:length];
    free(myByte);
    
    return self;

}
-(void)fillFourBytesWithInt
{
    uint time =  (uint)[[NSDate date] timeIntervalSince1970];
    Byte *myByte = (Byte*)malloc(4);
    myByte[0] = time;
    myByte[1] = time >> 8;
    myByte[2] = time >> 16;
    myByte[3] = time >> 24;
    free(myByte);

}

-(NSMutableData *)appendDataWithInt:(NSUInteger)data length:(NSUInteger)length
{
    if (length == FOUR_BYTE) {
        
        Byte * CRCByte = (Byte*)malloc(4);
        CRCByte[0] = data >> 24;
        CRCByte[1] = data >> 16;
        CRCByte[2] = data >> 8;
        CRCByte[3] = data;
        
        [self appendBytes:CRCByte length:4];
        free(CRCByte);
//        Byte *myByte = (Byte*)malloc(4);
//        myByte[0] = data;
//        myByte[1] = data >> 8;
//        myByte[2] = data >> 16;
//        myByte[3] = data >> 24;
//        [self appendBytes:myByte length:length];
//        free(myByte);
        return self;
    }
    return [self appendDataWithInt:data length:length reverse:NO];
}

-(NSMutableData *)appendDataWithIntReverse:(NSUInteger)data length:(NSUInteger)length
{
    return [self appendDataWithInt:data length:length reverse:YES];
}

-(NSMutableData *)appendDataWithString:(NSString *)string
{
    [self appendData:[string dataUsingEncoding:NSASCIIStringEncoding]];
    
    return self;
}
@end
