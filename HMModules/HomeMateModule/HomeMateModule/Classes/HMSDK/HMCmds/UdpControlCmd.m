//
//  UdpControlCmd.m
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/8/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "UdpControlCmd.h"
#import "HMConstant.h"

@implementation UdpControlCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_CD;
}

-(NSDictionary *)payload {
    if (self.order) {
        [sendDic setObject:self.order forKey:@"order"];
    }
    [sendDic setObject:@(self.value1) forKey:@"value1"];
    [sendDic setObject:@(self.value2) forKey:@"value2"];
    [sendDic setObject:@(self.value3) forKey:@"value3"];
    [sendDic setObject:@(self.value4) forKey:@"value4"];
    [sendDic setObject:@(self.propertyResponse) forKey:@"propertyResponse"];


    return sendDic;
}

- (int)propertyResponse {
    return 1;
}

-(KEncryptedType)protocolType
{
    return KEncryptedTypeDK; //
}

-(NSData *)data:(GlobalSocket *)socket
{
    return [self data];
}

-(NSData *)data
{
    DLog(@"UDP 发送控制灯带命令");
    return [super data];
}

@end
