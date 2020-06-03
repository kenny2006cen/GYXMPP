//
//  QueryGatewayCmd.m
//  HomeMate
//
//  Created by Air on 15/10/10.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "QueryGatewayCmd.h"
#import "HMConstant.h"

@implementation QueryGatewayCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_UDP;
}
-(KEncryptedType)protocolType
{
    return KEncryptedTypePK; // 查找主机时使用公钥
}

-(NSString *)key
{
    return PUBLICAEC128KEY; // 当前命令肯定使用公钥
}

-(NSDictionary *)payload
{
    // uid 选填，如果不填写的话表示查找所有网关
    // 如果填写了的话表示查找指定uid的网关
    [sendDic setObject:@"" forKey:@"uid"];
    return sendDic;
}

-(NSData *)data
{
    DLog(@"UDP 发送查找网关命令");
    return [super data];
}
@end
