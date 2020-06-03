//
//  HMHubBusiness.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMHubBusiness.h"

@implementation HMHubBusiness

+ (void)addGateway:(Gateway *)gateway reSend:(BOOL)reSend result:(KReturnValueBlock)valueBlock
{
    [self addGateway:gateway reSend:reSend result:valueBlock completion:nil];
}

+ (void)addGateway:(Gateway *)gateway result:(KReturnValueBlock)valueBlock
{
    [self addGateway:gateway reSend:YES result:valueBlock];
}

+ (void)addGateway:(Gateway *)gateway completion:(commonBlockWithObject)completion
{
    [self addGateway:gateway reSend:YES result:nil completion:completion];
}

+ (void)addGateway:(Gateway *)gateway reSend:(BOOL)reSend result:(KReturnValueBlock)valueBlock completion:(commonBlockWithObject)completion
{
    NSAssert(gateway.uid, @"uid can no be nil");

    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NewBindHostCmd *bhCmd = [NewBindHostCmd object];
    bhCmd.uid = gateway.uid;
    if (!reSend) {
        bhCmd.resendTimes = kMaxTryTimes;
    }
    bhCmd.familyId = userAccout().familyId;
    bhCmd.language = language();
    bhCmd.dstOffset = zone.isDaylightSavingTime ? zone.daylightSavingTimeOffset : 0 ;
    // 当有夏令时的时候，系统自动把时区信息修改了，真实的时区应该减去其夏令时偏移量
    bhCmd.zoneOffset = zone.isDaylightSavingTime ? zone.secondsFromGMT - bhCmd.dstOffset : zone.secondsFromGMT;
    bhCmd.sendToServer = YES;
    DLog(@"绑定主机发送的信息：%@",[bhCmd jsonDic]);
    sendCmd(bhCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        DLog(@"绑定主机返回状态码 ： %d",returnValue);
        if (returnValue == KReturnValueSuccess) {
            
            // 删除旧此uid下面的所有数据
            [[RemoteGateway shareInstance].delegate handleDevcieDeletedReport:@{@"uid":returnDic[@"uid"]?:@""}];
            
            //如果有设备返回，则插入返回的设备
            if ([returnDic[@"device"] isKindOfClass:[NSDictionary class]]) {
                HMDevice *device = [HMDevice objectFromDictionary:returnDic[@"device"]];
                if (device) {
                    [device insertObject];
                }
            }
            // 更新 gateway 表
            HMGateway *hmGatewayModel = [HMGateway objectFromDictionary:returnDic[@"gateway"]];
            [hmGatewayModel insertObject];
            
            // 更新 userGatewayBind 表
            HMUserGatewayBind *userGatewayBindModel = [HMUserGatewayBind objectFromDictionary:returnDic[@"userGatewayBind"]];
            [userGatewayBindModel insertObject];
            
            //mixpadse 灯
            if([returnDic[@"deviceList"] isKindOfClass:[NSArray class]]){
                for (NSDictionary *dic in returnDic[@"deviceList"]) {
                    HMDevice *device = [HMDevice objectFromDictionary:dic];
                    [device insertObject];
                }
            }
            
            //mixpadse 灯状态
            if([returnDic[@"deviceStatus"] isKindOfClass:[NSArray class]]){
                for (NSDictionary *dic in returnDic[@"deviceStatus"]) {
                    NSMutableDictionary *dict = [dic mutableCopy];
                    dict[@"uid"] = returnDic[@"uid"];
                    HMDeviceStatus *status = [HMDeviceStatus objectFromDictionary:dict];
                    [status insertObject];
                }
            }
            
            // 绑定成功之后，监听通知
            [gateway addMdnsObserver];
            
            if (gateway && gateway.uid) {
                userAccout().gatewayDicList[gateway.uid] = gateway;
            }
        }
        if (valueBlock) {
            valueBlock(returnValue);
        }
        if (completion) {
            completion(returnValue,returnDic);
        }
    });
}

+ (void)openSearchZigBeeDevice:(KReturnValueBlock)valueBlock
{
    DeviceSearchCmd *dsCmd = [DeviceSearchCmd object];
    dsCmd.familyId = userAccout().familyId;
    dsCmd.Type = @"open";
    sendCmd(dsCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (valueBlock) {
            valueBlock(returnValue);
        }
    });
}

+ (void)openSearchZigBeeDeviceInGatewayUids:(NSArray *)uids completion:(commonBlockWithObject)completion
{
    DeviceSearchCmd *dsCmd = [DeviceSearchCmd object];
    dsCmd.familyId = userAccout().familyId;
    dsCmd.Type = @"open";
    dsCmd.uidList = uids;
    sendCmd(dsCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue,returnDic);
        }
    });
}

+ (void)closeSearchZigBeeDevice:(KReturnValueBlock)valueBlock
{
    DeviceSearchCmd *dsCmd = [DeviceSearchCmd object];
    dsCmd.familyId = userAccout().familyId;
    dsCmd.Type = @"close";
    sendCmd(dsCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (valueBlock) {
            valueBlock(returnValue);
        }
    });
}

+ (void)getGatewaysAdded:(void(^)(NSArray *gateways))gatewaysBlock
{
    NSArray *devicesBindHostArr = [HMUserGatewayBind zigbeeHostBindArray];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [devicesBindHostArr enumerateObjectsUsingBlock:^(HMUserGatewayBind * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Gateway *gateway = [[Gateway alloc] init];
        gateway.model = obj.model;
        gateway.deviceType = HostType(obj.model);
        gateway.uid = obj.uid;
        [tmpArray addObject:gateway];
    }];
    if (gatewaysBlock) {
        gatewaysBlock(tmpArray);
    }
}

+ (void)searchCurrentWifiGateways:(void(^)(NSArray *gateways))gatewaysBlock
{
    [[SearchMdns shareInstance]searchGatewaysWtihCompletion:^(BOOL success, NSArray *gateways) {
        NSArray *searchGateways = success ? gateways : @[];
        if (gatewaysBlock) {
            gatewaysBlock(searchGateways);
        }
    }];
}

+ (void)queryGateway:(Gateway *)gateway status:(void(^)(HMGatewayStatus status))resultBlock
{
    [HMLoginAPI loginWithUserName:userAccout().userName
                         password:userAccout().password
                              uid:gateway.uid completion:^(KReturnValue returnValue, NSDictionary *returnDic) {
                                  
                                  HMGatewayStatus tmpStatus = HMGatewayStatusNotAdded;
                                  if (returnValue == KReturnValueSuccess) {
                                      tmpStatus = HMGatewayStatusAddedByYourCurrFamily;
                                      
                                  }else if (returnValue == KReturnValueNotBindMainframe){
                                      tmpStatus = HMGatewayStatusAddedByOther;
                                      
                                  }else if (returnValue == KReturnValueMainframeRest) {
                                      tmpStatus = HMGatewayStatusNotAdded;
                                      
                                  }else if (returnValue == KReturnValueHostHasBindByYourAnotherFamily){
                                      tmpStatus = HMGatewayStatusAddedByYourOtherFamily;
                                  }
                                  if (resultBlock) {
                                      resultBlock(tmpStatus);
                                  }
                              }];
    
}

+ (void)queryBindStatusWithUidList:(NSArray *)uidList completion:(commonBlockWithObject)completion
{
    if (![uidList isKindOfClass:[NSArray class]]) {
        if (completion) {
            completion(KReturnValueParameterError,nil);
        }
        DLog(@"所传参数错误");
        return;
    }
    QueryBindStatusCmd *queryCmd = [QueryBindStatusCmd object];
    queryCmd.uidList = uidList;
    sendCmd(queryCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue,returnDic);
        }
    });
}

+ (void)searchUnbindAlarmHostInLocalNetWorkRetBlock:(commonBlockWithObject)completion {
    // WiFi状态 且 有网络的情况下才向服务器发送命令，查找局域网内的WiFi设备
    if (isEnableWIFI() && isNetworkAvailable()) {
        
        SearchUnbindDevicesCmd * cmd = [[SearchUnbindDevicesCmd alloc] init];
        cmd.deviceType = @"";
        cmd.sendToServer = YES;
        cmd.ssid = [HMNetworkMonitor getSSID]; //发现未被绑定设备，带上当前WiFi网络的ssid
        
        sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
            if (returnValue == KReturnValueSuccess) {
                NSString *deviceListJson = [returnDic objectForKey:@"deviceList"];
                NSData *jsonData = [deviceListJson dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *deviceList = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                DLog(@"deviceList = %@",deviceList);
                Gateway *gateway = [[Gateway alloc] init];
                for (NSDictionary * dic in deviceList) {
                    NSString *model = [dic objectForKey:@"model"];
                    if (KDeviceTypeAlarmHub == HostType(model)) {
                        gateway.uid = [dic objectForKey:@"uid"];
                        gateway.deviceType = KDeviceTypeAlarmHub;
                        gateway.model = [dic objectForKey:@"model"];
                        break;
                    }
                }
                if (!isBlankString(gateway.uid)) {
                    if (completion) {
                        completion(KReturnValueSuccess,gateway);
                    }
                }else {
                    if (completion) {
                        completion(KReturnValueFail,nil);
                    }
                }
            }else {
                if (completion) {
                    completion(returnValue,nil);
                }
            }
        });
    }
}

+ (NSString *)nameWithGateway:(Gateway *)gateway {
    // 本地网关表是否有该主机
    HMGateway *tmpGateway = [HMGateway objectWithUid:gateway.uid];
    HMProductModel *pModel =  [HMProductModel productModelWithModel:gateway.model];
    
    // 本地网关表是否有该主机，有的话名字用网关表里的名字,没有就用描述表
    NSString *nameText = tmpGateway ? tmpGateway.homeName : pModel.productName;
    return nameText;
}

+ (void)queryMixPadQrcodeWithToken:(NSString *)token block:(commonBlockWithObject)completion {
    
    NSAssert(token, @"token can not be nil");
    
    QueryQrcodeTokenCmd *cmd = [QueryQrcodeTokenCmd object];
    cmd.userId = userAccout().userId;
    cmd.token = token;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completion) {
            completion(returnValue,returnDic);
        }
    });
}

@end
