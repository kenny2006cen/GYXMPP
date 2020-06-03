//
//  RequestKeyCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "RequestKeyCmd.h"
#import "HMConstant.h"
#import "HMStorage.h"

@implementation RequestKeyCmd

-(NSString *)userName
{
    return nil;
}
-(KEncryptedType)protocolType
{
    return KEncryptedTypePK; // 只有申请通信密钥时使用公钥，其他指令都使用动态密钥
}
-(NSString *)sessionId
{
    return nil; // 发送此命令时 session 尚未建立
}

-(NSString *)key
{
    return PUBLICAEC128KEY; // 当前命令肯定使用公钥
}

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_RK;
}
-(NSString *)softwareVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
    
}

-(NSString *)sysVersion
{
    return [NSString stringWithFormat:@"iOS %@",[[UIDevice currentDevice] systemVersion]];
}
-(NSString *)hardwareVersion
{
    return getCurrentDeviceModel();
}
-(NSString *)source
{
    NSString * bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleId isEqualToString:@"com.orvibo.theLifeMaster"]/*&& [[HMStorage shareInstance].appName isEqualToString:@"ZhiJia365"]*/) {
        return @"HomeMateEnterprise";
    }
    return [HMStorage shareInstance].appName;
}
-(NSString *)language
{
    return language();
}

- (NSString *)identifier {
    return phoneIdentifier();

}
- (NSString *)phoneName {
    return terminalDeviceName();
}
-(NSDictionary *)payload
{
    [sendDic setObject:self.source forKey:@"source"];
    [sendDic setObject:self.softwareVersion forKey:@"softwareVersion"];
    [sendDic setObject:self.sysVersion forKey:@"sysVersion"];
    [sendDic setObject:self.hardwareVersion forKey:@"hardwareVersion"];
    [sendDic setObject:self.language forKeyedSubscript:@"language"];
    if(self.identifier){
        [sendDic setObject:self.identifier forKey:@"identifier"];
    }
    [sendDic setObject:self.phoneName forKeyedSubscript:@"phoneName"];

    return sendDic;
}


@end
