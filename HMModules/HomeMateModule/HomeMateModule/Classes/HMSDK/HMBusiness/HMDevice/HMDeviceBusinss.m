//
//  HMDeviceBusinss.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMDeviceBusinss.h"
#import "NSObject+MJKeyValue.h"

#define HttpDelayTime 3

@implementation HMDeviceBusinss

+ (NSInteger)cameraType:(NSString *)uid {
    __block NSInteger type = 0;
    NSString * sql = [NSString stringWithFormat:@"select type from camerainfo where uid = '%@'" ,uid];
    queryDatabase(sql, ^(FMResultSet *rs) {
        type = [rs intForColumn:@"type"];
    });
    return type;
}

+ (BOOL)isHasAddedP2PCameraDid:(NSString *)did {
    NSString *sql = [NSString stringWithFormat:@"select extAddr from device where delFlag = 0 "
                     "and deviceType = 14 and uid in %@",[HMUserGatewayBind uidStatement]];
    __block BOOL isHasAdded = NO;
    queryDatabase(sql, ^(FMResultSet *rs) {
        NSString *chDID = [rs stringForColumn:@"extAddr"];
        if ([chDID isEqualToString:did]) {
            isHasAdded = YES;
        }
    });
    return isHasAdded;
}

+ (void)addP2PCameraChDID:(NSString *)chDID result:(KReturnValueBlock)block {
    AddCameraCmd *addCamera = [AddCameraCmd object];
    
    addCamera.uid = [self onlineHostUid];
    addCamera.userName = userAccout().userName;
    addCamera.type = 0;
    addCamera.cameraUID = chDID;
    addCamera.user = @"admin";
    addCamera.password = @"123456";
    
    DLog(@"发送信息：%@",[addCamera jsonDic]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        sendCmd(addCamera, ^(KReturnValue returnValue, NSDictionary *dic) {
            
            if (returnValue == KReturnValueSuccess) {
                
                NSString *uid = [dic objectForKey:@"uid"];
                
                NSMutableDictionary *cameraInfo = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"camera"]];
                NSMutableDictionary *deviceInfo = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"device"]];
                
                if (cameraInfo) {
                    
                    [cameraInfo setObject:uid forKey:@"uid"];
                    
                    HMCameraInfo *camera = [HMCameraInfo objectFromDictionary:cameraInfo];
                    
                    [camera insertObject];
                }
                
                if (deviceInfo) {
                    
                    [deviceInfo setObject:uid forKey:@"uid"];
                    
                    HMDevice *device = [HMDevice objectFromDictionary:deviceInfo];
                    [device insertObject];
                    
                    // 发出通知，有新设备入网
                    [HMBaseAPI postNotification:kNOTIFICATION_NEW_DEVICE_REPORT object:device];
                }
            }
            if (block) {
                block(returnValue);
            }
        });
    });
}

+ (void)getAccessTokenFromYS:(NSString *)phoneNumber result:(void (^)(NSString *))block{
    
    NSString *registURLString   = [NSString stringWithFormat:RegisterToYSUrl,phoneNumber];
    registURLString = dynamicDomainURL(registURLString);
    NSString *getTokenURLString = [NSString stringWithFormat:GetYSAccessTokenUrl,userAccout().familyId];
    getTokenURLString = dynamicDomainURL(getTokenURLString);
    requestURL(getTokenURLString, HttpDelayTime, ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error && data) {
            
            NSError *jsonError = nil;
            NSDictionary * payloadDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            DLog(@"服务器返回获取萤石token结果 = %@",payloadDic);
            
            if (!jsonError && [payloadDic isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary * result = [payloadDic objectForKey:@"result"];
                NSDictionary * dataDic = [result objectForKey:@"data"];
                NSString * accessToken = [dataDic objectForKey:@"accessToken"];
                block(accessToken);
            }
            else {
                DLog(@"获取萤石token时jsonError:%@",jsonError);
            }
        }
        else { //如果获取token失败 尝试先注册 再去获取一次
            requestURL(registURLString, HttpDelayTime, ^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (!error) {
                    
                    requestURL(getTokenURLString, HttpDelayTime, ^(NSData *data, NSURLResponse *response, NSError *error) {
                        
                        if (!error && data) {
                            
                            NSError *jsonError = nil;
                            NSDictionary * payloadDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                            
                            DLog(@"服务器返回获取萤石token结果 = %@",payloadDic);
                            
                            if (!jsonError && [payloadDic isKindOfClass:[NSDictionary class]]) {
                                
                                NSDictionary * result = [payloadDic objectForKey:@"result"];
                                NSDictionary * dataDic = [result objectForKey:@"data"];
                                NSString * accessToken = [dataDic objectForKey:@"accessToken"];
                                block(accessToken);
                            }
                            else {
                                DLog(@"获取萤石token时jsonError:%@",jsonError);
                            }
                        }
                        else {
                            DLog(@"获取萤石token失败:error=%@",error);
                        }
                    });
                    
                }else {
                    DLog(@"萤石注册失败:error=%@",error);
                }
            });
        }
    });
}

+ (BOOL)isAddedYSCameraWithSerial:(NSString *)serial {
    __block BOOL result = NO;
    NSString * sql = [NSString stringWithFormat:@"select count() as count from (SELECT * FROM device WHERE uid IN %@) where uid = '%@'" ,[HMUserGatewayBind uidStatement], serial];
    
    queryDatabase(sql, ^(FMResultSet *rs) {
        
        int totalCount = [rs intForColumn:@"count"];
        result = (totalCount > 0);
    });
    return result;
}

+ (void)addYSCameraWithDeviceSerial:(NSString *)serial verifyCode:(NSString *)code isSupportPTZ:(BOOL)isSupportPTZ result:(KReturnValueBlock)block {
    // 先发解绑命令 再绑定
    
    DeviceUnbindCmd *deletecmd = [DeviceUnbindCmd object];
    deletecmd.uid = serial;
    deletecmd.sendToServer = YES;
    
    sendLCmd(deletecmd, YES, (^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            cleanDeviceData(serial);
            
        }else{
            //删除失败
        }
        
        DeviceBindCmd * cmd  = [[DeviceBindCmd alloc] init];
        cmd.deviceType = [NSString stringWithFormat:@"%d", KDeviceTypeCamera];
        cmd.bindUID = serial;
        if (isSupportPTZ) {
            cmd.type = 2;
        }else {
            cmd.type = 1;
        }
        cmd.user = userAccout().phone;
        cmd.password = code;
        
        sendLCmd(cmd, NO, ^(KReturnValue returnValue, NSDictionary *returnDic) {
            
            DLog(@"绑定摄像头 returnDic = %@",returnDic);
            
            if (returnValue == KReturnValueSuccess) {
                NSString * uid  = [returnDic objectForKey:@"uid"];
                NSDictionary * cameraDic = [returnDic objectForKey:@"camera"];
                HMCameraInfo * cameraInfo = [HMCameraInfo objectFromDictionary:cameraDic];
                [cameraInfo insertObject];
                NSDictionary * deviceDic = [returnDic objectForKey:@"device"];
                HMDevice * device = [HMDevice objectFromDictionary:deviceDic];
                device.uid = uid;
                device.model = [deviceDic objectForKey:@"model"];
                [device insertObject];
                NSDictionary * gatewayDic = [returnDic objectForKey:@"gateway"];
                HMGateway * gateway = [HMGateway objectFromDictionary:gatewayDic];
                [gateway insertObject];
                NSDictionary * userGatewayBindDic = [returnDic objectForKey:@"userGatewayBind"];
                HMUserGatewayBind * userGatewayBind = [HMUserGatewayBind objectFromDictionary:userGatewayBindDic];
                [userGatewayBind insertObject];
                
                addDeviceBind(device.uid, device.model);
            }
            
            block(returnValue);
            
        });
    }));
}

+ (void)deleteYSCameraWithDevice:(HMDevice *)device result:(KReturnValueBlock)block {
    __block HMDevice *cameraDevice = device;
    DeleteDeviceCmd *deletecmd = [DeleteDeviceCmd object];
    deletecmd.uid = device.uid;
    deletecmd.userName = userAccout().userName;
    deletecmd.sendToServer = YES;

    sendLCmd(deletecmd, NO, (^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess || returnValue == KReturnValueDataNotExist) {
            
            [cameraDevice deleteObject];
            
            //删除置顶数据(如果置顶过)
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM securityDeviceSort WHERE sortUserId = '%@' and sortFamilyId = '%@' and sortDeviceId = '%@'",userAccout().userId, userAccout().familyId, device.deviceId];
            
            __block HMSecurityDeviceSort *securityDeviceSort = nil;
            
            queryDatabase(sql, ^(FMResultSet *rs) {
                securityDeviceSort = [HMSecurityDeviceSort object:rs];
                if (securityDeviceSort) {
                    [securityDeviceSort deleteObject];
                }
            });
        }
        block(returnValue);
    }));
}

+ (NSString *)onlineHostUid {
    NSArray *hostArr = [HMUserGatewayBind zigbeeHostBindArray];
    
    return [[hostArr lastObject] uid];
}


+ (void)controlClothesHangerWithDevice:(HMDevice *)device
                              ctrlType:(HMClothesHangerCtrlType)cType
                                result:(KReturnValueBlock)block {
    // 无网络
    if (!isNetworkAvailable()) {
        if (block) {
            block(KReturnValueNetWorkProblem);
            return;
        }
    }
    
    // 参数错误
    if (!device || ![device isKindOfClass:[HMDevice class]]) {
        if (block) {
            block(KReturnValueParameterError);
            return;
        }
    }

    // 设备类型错误
    if (device.deviceType != kDeviceTypeClothesHorse) {
        if (block) {
            block(KReturnValueWrongDeviceType);
            return;
        }
    }
    
    kClothesHorseType clothHorseType = clothesType(device);
    
    // RF 晾衣架走单独控制流程
    if (clothHorseType == kClothesHorseTypeRF) {
        ControlDeviceCmd *rfCmd = [self rfClothesConctrlCmdWithDevice:device ctrlType:cType];
        sendCmd(rfCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
            if (block) {
                block(returnValue);
            }
        });
        return;
    }
    
    // 不是RF晾衣架的话，有各种前提判断
    HMClotheshorseStatus *chStatus = [HMClotheshorseStatus objectWithDeviceId:device.deviceId];

    if (cType == HMClothesHangerCtrlTypeAirDry) {  // 操作风干前提
        if ([chStatus.heatDryingState isEqualToString:@"on"]) {
            if (clothHorseType == kClothesHorseTypeZiCheng
                || clothHorseType == kClothesHorseTypeLiangBa
                || clothHorseType == kClothesHorseTypeORVIBO_30w)
            {
                if (block) {
                    block(KReturnValueAirDryForbidWhenHeatOn);
                }
                return;
            }
        }
    }else if (cType == HMClothesHangerCtrlTypedisinfect && (clothHorseType != kClothesHorseTypeYuShun)) { // 开启消毒前提
        // 禹顺晾衣机94895bb583964b2780460a35d18a8768上没有限位反馈功能，需要取消“到达上限位”才能开启消毒灯的限制，变成可直接开启消毒灯
        if ([chStatus.sterilizingState isEqualToString:@"off"]) {
            
            // 晾霸的晾衣杆在没有上升到最顶端之前，不能开启消毒功能
            if (clothHorseType == kClothesHorseTypeLiangBa
                || clothHorseType == kClothesHorseTypeORVIBO
                || clothHorseType == kClothesHorseTypeORVIBO_30w)
            {
                if (chStatus.motorPosition != 0) {
                    if (block) {
                        block(KReturnValueCannotDisinfectWhenNotAtTop);
                    }
                    return;
                }
                
                // 紫程系列的位置与协议相反
            }else if (clothHorseType == kClothesHorseTypeZiCheng)
            {
                if (chStatus.motorPosition != 100) {
                    if (block) {
                        block(KReturnValueCannotDisinfectWhenNotAtTop);
                    }
                    return;
                }
            }
        }
        
    }else if (cType == HMClothesHangerCtrlTypeStop
              || cType == HMClothesHangerCtrlTypeUpMove
              || cType == HMClothesHangerCtrlTypeDownMove) {
        if ([chStatus.exceptionInfo isEqualToString:@"overWeight"]) {
            if (block) {
                block(KReturnValueClothesHangerOverWeight);
            }
            return;
        }
    }
    
    // 开始发控制命令
    ClotheshorseControlCmd *clothesCmd = [self ClotheshorseControlCmdWithDevice:device ctrlType:cType];
    sendCmd(clothesCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (block) {
            block(returnValue);
        }
    });
}

+ (ControlDeviceCmd *)rfClothesConctrlCmdWithDevice:(HMDevice *)device
                                           ctrlType:(HMClothesHangerCtrlType)cType
{
    ControlDeviceCmd *cmd = [ControlDeviceCmd object];
    cmd.deviceId = device.deviceId;
    cmd.uid = device.uid;
    cmd.order = @"rf control";
    cmd.delayTime = 0;
    cmd.qualityOfService = 0; //0：不需要重发，不关心是否一定能达到 1：需要重发，保证命令一定能达到设备
    cmd.defaultResponse = 0;  // 0表示需要默认返回  1表示不需要默认返回
    cmd.userName = userAccout().userName;
    cmd.sendToServer = YES;
    
    switch (cType) {
        case HMClothesHangerCtrlTypeAirDry:
            cmd.value1 = kRFMotorControlValue1ClotherHorseAirDry;
            
            break;
        case HMClothesHangerCtrlTypeHeatDry:
            cmd.value1 = kRFMotorControlValue1ClotherHorseStoving;
            break;
            
        case HMClothesHangerCtrlTypedisinfect:
            cmd.value1 = kRFMotorControlValue1ClotherHorseDisinfect;
            break;
            
        case HMClothesHangerCtrlTypeLight:
            cmd.value1 = kRFMotorControlValue1ClotherHorseIllumination;
            break;
            
        case HMClothesHangerCtrlTypeUpMove:
            cmd.value1 = kRFMotorControlValue1ClotherHorseMoveUp;
            break;
            
        case HMClothesHangerCtrlTypeDownMove:
            cmd.value1 = kRFMotorControlValue1ClotherHorseMoveDown;
            break;
            
        case HMClothesHangerCtrlTypeStop:
            cmd.value1 = kRFMotorControlValue1ClotherHorseStop;
            break;
            
        case HMClothesHangerCtrlTypeCloseAll:
            cmd.value1 = kRFMotorControlValue1ClotherHorseOff;
            break;
            
        default:
            break;
    }
    return cmd;
}

+ (ClotheshorseControlCmd *)ClotheshorseControlCmdWithDevice:(HMDevice *)device
                                                    ctrlType:(HMClothesHangerCtrlType)cType
{
    HMClotheshorseStatus *chStatus = [HMClotheshorseStatus objectWithDeviceId:device.deviceId];
    ClotheshorseControlCmd *controlCmd = [ClotheshorseControlCmd object];
    controlCmd.userName = userAccout().userName;
    controlCmd.deviceId = device.deviceId;
    controlCmd.uid = device.uid;
    controlCmd.sendToServer = YES;
    switch (cType) {
        case HMClothesHangerCtrlTypeAirDry:
            controlCmd.windDryingCtrl = [chStatus.windDryingState isEqualToString:@"on"] ? @"off":@"on";

            break;
        case HMClothesHangerCtrlTypeHeatDry:
            controlCmd.heatDryingCtrl = [chStatus.heatDryingState isEqualToString:@"on"] ? @"off":@"on";
            break;
            
        case HMClothesHangerCtrlTypedisinfect:
            controlCmd.sterilizingCtrl =[chStatus.sterilizingState isEqualToString:@"on"] ? @"off":@"on";
            break;
            
        case HMClothesHangerCtrlTypeLight:
            controlCmd.lightingCtrl = [chStatus.lightingState isEqualToString:@"on"] ? @"off":@"on";
            break;
            
        case HMClothesHangerCtrlTypeUpMove:
            controlCmd.motorCtrl = @"up";
            break;
            
        case HMClothesHangerCtrlTypeDownMove:
            controlCmd.motorCtrl = @"down";
            break;
            
        case HMClothesHangerCtrlTypeStop:
            controlCmd.motorCtrl = @"stop";
            break;
            
        case HMClothesHangerCtrlTypeCloseAll:
            controlCmd.mainSwitchCtrl = @"off";
            break;
            
        default:
            break;
    }
    return controlCmd;
}

+ (void)controlAlarmDevice:(HMDevice *)device isStartAlarm:(BOOL)isStartAlarm result:(KReturnValueBlock)block
{
    ControlDeviceCmd *cdCmd = [ControlDeviceCmd object];
    cdCmd.uid = device.uid;
    cdCmd.userName = userAccout().userName;
    cdCmd.deviceId = device.deviceId;
    cdCmd.order = isStartAlarm ? @"start alarm" : @"stop alarm";
    cdCmd.value1 = isStartAlarm ? 1 : 0;
    sendCmd(cdCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (block) {
            block(returnValue);
        }
    });
}

+ (void)setDeviceParmWithDevice:(HMDevice *)device paramId:(NSString *)paramId paramType:(int)paramType paramValue:(NSString *)paramValue completeBlock:(SocketCompletionBlock)completionBlock
{
    if (isBlankString(device.deviceId) || isBlankString(paramId)) {
        DLog(@"deviceId 或者 paramId 不能为空");
        return;
    }
    SetDeviceParamCmd *setCmd = [SetDeviceParamCmd object];
    setCmd.deviceId = device.deviceId;
    setCmd.paramId = paramId;
    setCmd.paramType = paramType;
    setCmd.paramValue = paramValue;
    setCmd.uid = device.uid;
    setCmd.userName = userAccout().userName;
    sendCmd(setCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            HMDeviceSettingModel *dsModel = [[HMDeviceSettingModel alloc] init];
            dsModel.deviceId = device.deviceId;
            dsModel.paramId = paramId;
            dsModel.paramType = paramType;
            dsModel.paramValue = paramValue;
            [dsModel insertObject];
        }
        if (completionBlock) {
            completionBlock(returnValue,returnDic);
        }
    });
}

+ (void)controlDevice:(HMDevice *)device
                order:(NSString *)order
               value1:(int)value1
               value2:(int)value2
               value3:(int)value3
               value4:(int)value4
       isIgnoreReport:(int)isIgnoreReport
        completeBlock:(SocketCompletionBlock)completionBlock {
    NSAssert(device && order, @"device or order can not be nil");
    ControlDeviceCmd *cdCmd = [ControlDeviceCmd object];
    cdCmd.uid = device.uid;
    cdCmd.userName = userAccout().userName;
    cdCmd.deviceId = device.deviceId;
    cdCmd.order = order;
    cdCmd.value1 = value1;
    cdCmd.value2 = value2;
    cdCmd.value3 = value3;
    cdCmd.value4 = value4;
    cdCmd.propertyResponse = isIgnoreReport;
    sendCmd(cdCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completionBlock) {
            completionBlock(returnValue,returnDic);
        }
    });
}

+ (void)colorLightThemeControlDevice:(HMDevice *)device
                      themeParameter:(NSDictionary *)themeParameter
                       completeBlock:(SocketCompletionBlock)completionBlock {
    NSAssert(device && themeParameter, @"device or themeParameter can not be nil");
    ControlDeviceCmd *cdCmd = [ControlDeviceCmd object];
    cdCmd.uid = device.uid;
    cdCmd.userName = userAccout().userName;
    cdCmd.deviceId = device.deviceId;
    cdCmd.order = @"theme control";
    cdCmd.themeParameter = themeParameter;
    sendCmd(cdCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (completionBlock) {
            completionBlock(returnValue,returnDic);
        }
    });
}

+ (void)themeSetingWithDeviceUid:(NSString *)uid
                         themeId:(NSString *)themeId
                 themeParameter:(NSDictionary *)themeParameter
                  completeBlock:(SocketCompletionBlock)completionBlock {
    NSAssert(uid && themeParameter, @"uid or themeParameter can not be nil");
    ThemeSettingCmd *cmd = [ThemeSettingCmd object];
    cmd.userName = userAccout().userName;
    cmd.uid = uid;
    cmd.themeParameter = themeParameter;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            
            HMThemeModel *themeModel = [HMThemeModel themeOfThemeId:themeId];
            if (themeParameter[@"speed"]) {
                themeModel.speed = (int)[themeParameter[@"speed"] floatValue];
            }
            if (themeParameter[@"angle"]) {
                themeModel.angle = (int)[themeParameter[@"angle"] integerValue];
            }
            if (themeParameter[@"variation"]) {
                themeModel.variation = (int)[themeParameter[@"variation"] integerValue];
            }
            
            if (themeParameter[@"color"]) {
                NSArray *colorArr = themeParameter[@"color"];
                if ([colorArr isKindOfClass:[NSArray class]]) {
                    themeModel.color = (NSString *)[self objArrayToJSON:colorArr];
                }
            }
            
            [themeModel insertObject];
            /*
             发送数据内容:
             {
             cmd = 271;
             serial = 280292055;
             themeParameter =     {
             color =         {
             colorSequence = 2;
             value1 = 0;
             value2 = 0;
             value3 = 0;
             value4 = 6;
             };
             nameType = 2;
             speed = 3000;
             themeType = 2;
             };
             uid = bcddc2e2a0ff;
             userName = "hank@orvibo.com";
             ver = "3.5.0";
             }
             */
        }
        
        if (completionBlock) {
            completionBlock(returnValue,returnDic);
        }
        
    });
}

//把多个json字符串转为一个json字符串

+ (NSString *)objArrayToJSON:(NSArray *)array {
    
    
    
    NSString *jsonStr = @"[";
    
    
    
    for (NSInteger i = 0; i < array.count; ++i) {
        
        if (i != 0) {
            
            jsonStr = [jsonStr stringByAppendingString:@","];
            
        }
        
        jsonStr = [jsonStr stringByAppendingString:[self convertToJSONData:array[i]]];
        
    }
    
    jsonStr = [jsonStr stringByAppendingString:@"]"];
    
    
    
    return jsonStr;
    
}

+ (NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (!jsonData)
    {
        DLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}



+ (void)setLockSettingsWithArray:(NSArray<HMDeviceSettingModel *> *)array
                          device:(HMDevice *)device
                   completeBlock:(SocketCompletionBlock)completionBlock {
    SetDeviceParamCmd *setCmd = [SetDeviceParamCmd object];
    setCmd.uid = device.uid;
    setCmd.userName = userAccout().userName;
    setCmd.deviceSettings = [HMDeviceSettingModel mj_keyValuesArrayWithObjectArray:array];
    sendCmd(setCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            for (HMDeviceSettingModel *model in array) {
                [model insertObject];
            }
        }
        if (completionBlock) {
            completionBlock(returnValue,returnDic);
        }
        
    });
    
    
}

+ (void)musicControlColorLightWithUid:(NSString *)uid lightValue:(int)lightValue changeTime:(int)changeTime lanCommonuicationKey:(NSString *)lanCommonuicationKey {
    UdpControlCmd *udpCmd = [UdpControlCmd object];
    udpCmd.key = lanCommonuicationKey;
    udpCmd.order = @"music control";
    udpCmd.value2 = lightValue;
    udpCmd.value3 = changeTime;
    udpCmd.uid = uid;
    udpCmd.propertyResponse = 1;
    NSData *data = [udpCmd data];
    [[HMUdpAPI shareInstance] sendData:data toHost:HM_UDP_BROADCAST_ADDR port:HM_UDP_PORT withTimeout:-1 tag:0];
}

+(BOOL)shoudSendCmdToServer:(HMDevice *)device cmd:(ControlDeviceCmd *)cmd
{
    if ([RemoteGateway shareInstance].isSocketConnected) {
        return YES; // 远程网络可用，优先发送指令到服务器
    }
    
    if (cmd.sendToServer) {
        DLog(@"命令已指定发送到服务器");
        return YES;
    }
    
    if (device.isWifiDevice) {
        DLog(@"WiFi设备的控制命令，发送指令到服务器");
        return YES;
    }
    if (!isEnableWIFI()) {
        DLog(@"当前非WiFi环境，发送指令到服务器");
        return YES;
    }
    return NO;
}

+(BOOL)shoudReturnDirectly:(KReturnValue)returnValue
{
    if(returnValue == KReturnValueSuccess  // 远程控制成功，直接返回
     || returnValue == KReturnValueMainframeOffline // 远程返回离线，直接返回
     || returnValue == KReturnValueControlTimeOut
     || returnValue == KReturnValueControlOffline
     || returnValue == KReturnValueNoData
     || returnValue == KReturnValueDataNotExist
     || returnValue == KReturnValueBindInvalid
     || returnValue == KReturnControlCmdCancel){
        return YES;
    }
    return NO;
}
/**
 支持设备和设备组控制，以及两者的局域网控制
 灯组需要虚拟成 HMDevice 对象，deviceType = KDeviceTypeDeviceGroup
 局域网控制时，接口会自动查询灯组中的设备所在的主机，分别向各个主机发送控制指令
 */
+ (void)controlDevice:(HMDevice *)device cmd:(ControlDeviceCmd *)cmd completion:(commonBlockWithObject)completion
 {
     if ([self shoudSendCmdToServer:device cmd:cmd]) {   // 判断是否直接发送指令到服务器，还是局域网控制
        
        ControlDeviceCmd *newCmd = [cmd copy];
        sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
            
            if ([self shoudReturnDirectly:returnValue]) {
                
                if (completion) {
                    completion(returnValue, returnDic);
                }
                
            }else{ // 远程控制失败，则尝试本地控制
                // 注意此处不能直接使用 cmd，因为cmd命令在超时之后，finishBlock 已经被赋值
                // 如果继续使用这个cmd，finishBlock不会被修改，会导致回调时出错
                [self localControlWithDevice:device cmd:newCmd completion:^(KReturnValue value, id object) {
                    KReturnValue reValue = (value == KReturnValueSuccess)?value:returnValue;
                    if (completion) {
                        completion (reValue,object);
                    }
                }];
            }
        });
        
    }else {    // 远程失败则尝试本地控制
        
        [self localControlWithDevice:device cmd:cmd completion:completion];
    }
}

+ (void)localControlWithDevice:(HMDevice *)device cmd:(ControlDeviceCmd *)cmd completion:(commonBlockWithObject)completion {
    
    NSMutableArray *uidArray = [@[] mutableCopy];
    if (device.deviceType == KDeviceTypeDeviceGroup) {
        NSArray *members = [HMGroupMember groupMembers:device.deviceId];
        NSArray *uids = [members valueForKey:@"uid"];
        NSSet *set = [NSSet setWithArray:uids];
        [uidArray setArray:[set allObjects]];
    }else{
        [uidArray addObject:device.uid?:@""];
    }
    
    [self localDeviceControlWithCmd:cmd uidArray:uidArray completion:completion];
}

/**
 支持设备和设备组控制，以及两者的局域网控制
 局域网控制时，接口根据传入的主机uidArray，分别向各个主机发送控制指令
 */
+ (void)controlDeviceWithCmd:(ControlDeviceCmd *)cmd uidArray:(NSArray *)uidArray completion:(commonBlockWithObject)block{
    
    commonBlockWithObject completion = ^(KReturnValue returnValue, NSDictionary *returnDic) {
        // 如果返回控制失败，则再尝试一次远程控制，仍然失败则返回
        if (returnValue == KReturnValueFail) {
            ControlDeviceCmd *newCmd = [cmd copy];
            newCmd.sendToServer = YES;
            sendCmd(newCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
                if (block) {
                    block(returnValue, returnDic);
                }
            });
        }else{
            if (block) {
                block(returnValue, returnDic);
            }
        }
    };
    
    if ([self shoudSendCmdToServer:nil cmd:cmd]) { // 判断是否直接发送指令到服务器，还是局域网控制
        
        ControlDeviceCmd *newCmd = [cmd copy];
        sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
            
            if ([self shoudReturnDirectly:returnValue] ) {
                
                if (completion) {
                    completion(returnValue, returnDic);
                }
                
            }else{ // 远程控制失败，则尝试本地控制
                // 注意此处不能直接使用 cmd，因为cmd命令在超时之后，finishBlock 已经被赋值
                // 如果继续使用这个cmd，finishBlock不会被修改，会导致回调时出错
                [self localDeviceControlWithCmd:newCmd uidArray:uidArray completion:^(KReturnValue value, id object) {
                    KReturnValue reValue = (value == KReturnValueSuccess)?value:returnValue;
                    if (completion) {
                        completion (reValue,object);
                    }
                }];
            }
        });
        
    }else {    // 远程失败则尝试本地控制
        
        [self localDeviceControlWithCmd:cmd uidArray:uidArray completion:completion];
    }
}


+ (void)localDeviceControlWithCmd:(ControlDeviceCmd *)cmd uidArray:(NSArray *)uidArray completion:(commonBlockWithObject)completion
{
    // WiFi环境 && 有主机uid信息，才允许本地控制，否则直接返回失败
    if (isEnableWIFI() && uidArray.count) {
        
        NSMutableArray *gateways = [NSMutableArray array];
        for (NSString *uid in uidArray) {
            [gateways addObject:getGateway(uid)];
        }
        
        // 如果有一个uid在本地，则先尝试本地控制
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.isLocalNetwork = %d",YES];
        NSArray *filter = [gateways filteredArrayUsingPredicate:pred];
        
        // 有至少一台主机在本地
        if (filter.count) {
            
            DLog(@"本地主机数量：%d uid:%@",filter.count,filter);
            [self didLocalDeviceControlWithCmd:cmd uidArray:[filter valueForKey:@"uid"] completion:completion];
            
        }else{
            // 如果所有的uid都不在本地，则先mdns搜索一次，再本地控制
            searchGatewaysWtihCompletion(^(BOOL success, NSArray *gateways) {
                
                if (success) {
                    
                    // 本地搜索到主机，则判断是否有传入的uid，如果有，则对本地的uid进行控制
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self in (%@)",[gateways valueForKey:@"uid"]];
                    NSArray *localGateways = [uidArray filteredArrayUsingPredicate:predicate];
                    
                    if (localGateways.count) {
                        
                        DLog(@"本地主机数量：%d uid:%@",localGateways.count,localGateways);
                        [self didLocalDeviceControlWithCmd:cmd uidArray:localGateways completion:completion];
                        
                    }else{
                        
                        DLog(@"本地搜索到的主机不包含在传入的数组中，返回错误码 1");
                        if (completion) {
                            completion(KReturnValueFail, nil);
                        }
                    }
                    
                }else{
                    
                    DLog(@"本地未搜索到主机，直接返回失败，返回错误码 1");
                    if (completion) {
                        completion(KReturnValueFail, nil);
                    }
                }
            });
        }
        
        
    }else {
        DLog(@"如果没有WiFi或者没有uid，则直接返回失败，返回错误码 1");
        if (completion) {
            completion(KReturnValueFail, nil);
        }
    }
}
+ (void)didLocalDeviceControlWithCmd:(ControlDeviceCmd *)cmd uidArray:(NSArray *)uidArray completion:(commonBlockWithObject)completion
{
    __block BOOL didReceiveSuccess = NO;
    __block int returnFailCount = 0;
    
    for (NSString *uid in uidArray) {
        
        ControlDeviceCmd * ctrlCmd = [cmd copy];
        ctrlCmd.uid = uid;
        ctrlCmd.sendToGateway = YES;
        sendCmd(ctrlCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
            if (returnValue == KReturnValueSuccess) {
                
                if (completion && didReceiveSuccess == NO) {    // 如果收到成功，就马上返回成功（且只返回一次）
                    DLog(@"收到了成功了，准备返回！");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(returnValue, returnDic);
                    });
                } else {
                    
                    DLog(@"收到了成功，但是已经返回了一次了！！！！");
                    
                }
                didReceiveSuccess = YES;
            } else {
                returnFailCount ++;
                if (completion && returnFailCount == uidArray.count) {     // 如果返回失败的次数为发送的次数，则返回最后一次失败的原因
                    DLog(@"失败次数跟发送次数一样！，要返回失败洛！！！");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(returnValue, nil);
                    });
                }
            }
        });
    }
}

@end
