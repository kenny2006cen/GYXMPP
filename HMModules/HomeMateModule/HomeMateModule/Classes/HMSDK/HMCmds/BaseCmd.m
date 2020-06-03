//
//  CmdBase.m
//  Vihome
//
//  Created by Air on 15-1-24.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"
#import "NSMutableData+Socket.h"
#import "NSData+AES.h"
#import "NSData+CRC32.h"
#import "HMConstant.h"

#define DEFAULTSESSION                      @"00000000000000000000000000000000"


@interface BaseCmd ()
// header
@property (nonatomic,strong) NSString *head;
@property (nonatomic,assign) NSUInteger len;
@property (nonatomic,assign) KEncryptedType protocolType;
@property (nonatomic,assign) NSUInteger crc;
@property (nonatomic,assign) int serialNumber;
@property (nonatomic,strong) NSString *sessionId;
@property (nonatomic,strong) NSString *ver; // 接口版本号


-(NSMutableData *)headData:(NSData *)payloadData;

@end

@implementation BaseCmd
{
    NSUInteger payLoadlength;
    NSUInteger CRC;
}

+(instancetype)object
{
    return [[[self class]alloc]init];
}

-(NSString *)head
{
    return @"hd";
}
-(NSUInteger)len
{
    return (payLoadlength + 42);
}
-(KEncryptedType)protocolType
{
    return KEncryptedTypeDK;// 只有申请通信密钥时使用公钥，其他指令都使用动态密钥
}
-(NSUInteger)crc
{
    return CRC;
}

-(NSString *)ver
{
    NSString *identifier = [[NSBundle mainBundle]bundleIdentifier];
    if ([identifier isEqualToString:@"com.orvibo.cloudPlatform"]
        || [identifier isEqualToString:@"com.orvibo.theLifeMaster"]) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        // Fix Bug：HM-10654
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleVersion"];
        return app_Version;
    }
    return @"4.2.0.210";
}

-(NSMutableData *)headData:(NSData *)payloadData
{
    payLoadlength = [payloadData length];
    
    NSMutableData * headData = [[NSMutableData alloc] init];
    
    [headData appendData:[self.head dataUsingEncoding:NSASCIIStringEncoding]];
    [headData appendDataWithIntReverse:self.len length:TWO_BYTE];

    NSString *type = (self.protocolType == KEncryptedTypeDK) ? @"dk" : @"pk";
    [headData appendData:[type dataUsingEncoding:NSASCIIStringEncoding]];
        
    CRC = [payloadData hm_crc32];
    //DLog(@"CRC = %d",CRC);
    [headData appendDataWithInt:CRC length:FOUR_BYTE];
    
    NSString *_session = self.sessionId;
    NSString *session = (_session.length > 0) ? _session : DEFAULTSESSION;
    NSData * sessionData = stringToData(session, 32);
    
    [headData appendData:sessionData];
    
    return headData;
}


-(NSDictionary *)payload
{
    [NSException raise:@"异常信息" format:@"子类需要自己实现此方法"];
    return nil;
}

-(VIHOME_CMD)cmd
{
    [NSException raise:@"异常信息" format:@"子类需要自己实现此方法"];
    return -1;
}

-(int)serialNo
{
    if (_serialNumber == 0) {
        _serialNumber = [BLUtility getTimestamp];
    }
    return _serialNumber;
}
-(void)setSerialNo:(int)serialNo
{
    _serialNumber = serialNo;
}

/**
 *  发送指令后，返回 41错误码 主机数据已修改，请重新同步最新数据 或 70错误码 服务器数据已修改，请重新同步最新数据
 *  时先同步数据，数据同步完成之后，再次发送命令时更新一下流水号，避免服务器返回一分钟内流水号重复
 *  @param dic 指令返回的数据
 */

-(void)updateSerialNo
{
    int newSerialNumber = [BLUtility getTimestamp];
    
    DLog(@"更新流水号，旧流水号：%d 新流水号：%d",_serialNumber,newSerialNumber);
    
    _serialNumber = newSerialNumber;
    
    if (sendDic) {
        [sendDic setObject:@(self.serialNo)forKey:@"serial"];
        if (self.start) {
            [sendDic setObject:self.start forKey:@"start"];
        }
    }
}

-(NSDictionary *)jsonDic
{
    if (!sendDic) {
        sendDic = [[NSMutableDictionary alloc] init];
        [sendDic setObject:@(self.cmd) forKey:@"cmd"];
        [sendDic setObject:@(self.serialNo)forKey:@"serial"];
        
        if (self.ver) {
            [sendDic setObject:self.ver forKey:@"ver"];
        }
        if (self.uid) {
            [sendDic setObject:self.uid forKey:@"uid"];
        }
        if (self.userName) {
            [sendDic setObject:[self.userName lowercaseString] forKey:@"userName"];
        }
        if (self.start) {
            [sendDic setObject:self.start forKey:@"start"];
        }
        if (self.limit) {
            [sendDic setObject:self.limit forKey:@"limit"];
        }
        return [self payload];
    }
    return sendDic;
}
-(NSData *)data:(GlobalSocket *)socket
{
    self.sessionId = socket.session;
    self.key = socket.encryptionKey;
    
    // DLog(@"命令:%@ 流水号:%d key:%@ session:%@",NSStringFromClass([self class]),_serialNumber,self.key,self.sessionId);
    
    return [self data];
}
-(NSData *)data
{
    NSError * error = nil;
    NSData * originalPayLoadData = [NSJSONSerialization dataWithJSONObject:[self jsonDic]
                                                                   options:0
                                                                     error:&error];
    
    //DLog(@"%@",[[NSString alloc]initWithData:originalPayLoadData encoding:NSUTF8StringEncoding]);
    //DLog(@"加密前的长度：%d",[originalPayLoadData length]);
    
    NSData * encryptedPayLoadData = [originalPayLoadData hm_AES128EncryptWithKey:self.key iv:nil];
    
    //DLog(@"加密后的长度：%d",[encryptedPayLoadData length]);
    
    NSMutableData * sendData = [self headData:encryptedPayLoadData];
    [sendData appendData:encryptedPayLoadData];
    
    return sendData;
}

-(instancetype)taskWithCompletion:(SocketCompletionBlock)completion
{
    if (!self.finishBlock && completion) {
        self.finishBlock = completion;
    }
    return self;
}
-(NSString *)description
{
    if (self.uid) {
        return [NSString stringWithFormat:@"cmd: %@ uid: %@ serial: %d",NSStringFromClass([self class]),self.uid,self.serialNo];
    }
    return [NSString stringWithFormat:@"cmd: %@ serial: %d",NSStringFromClass([self class]),self.serialNo];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[self class] mj_objectWithKeyValues:[self mj_JSONObject]];
    
}
@end
