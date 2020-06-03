//
//  VhAPConfig.m
//  HomeMateSDK
//
//  Created by Orvibo on 15/8/5.
//  Copyright © 2017年 Orvibo. All rights reserved.
//

#import "HMDeviceConfig.h"
#import "HMAPSocket.h"
#import "HMAPConfigEnDecoder.h"
#import "HMAPGetIp.h"
#import "HMAPDevice.h"
#import "HMAPWifiInfo.h"
#import "HMDeviceBind.h"
#import "HMDeviceConfigTimeOutManager.h"
#import "HMSDK.h"
#import "HMConstant.h"
#import "SearchUnbindDevicesCmd.h"
#import "HMStorage.h"

static HMDeviceConfig * defaultConfig = nil;

//#import "HMApUtil.h"

#define COCOSSID @"alink_ORVIBO_LIVING_OUTLET_E10"
#define HOMEMATESSID @"HomeMate_AP"


#define TotalCount 50


@interface HMDeviceConfig ()<VhApSocketDelegate,HMAPConfigCallback>
@property (strong, nonatomic) HMAPSocket * APSocket;
@property (strong, nonatomic) NSTimer * timer;
@property (strong, nonatomic) NSMutableDictionary * soketDic;
@property (copy, nonatomic) NSString * defaultSSID;
@property (nonatomic, assign) NSInteger connectCount;
@property (nonatomic, assign) NSInteger wifiCount;
@property (nonatomic, strong) NSMutableArray * wifiList;
@property (nonatomic, strong) NSTimer * wifiTimer;
@property (nonatomic, strong)  HMDeviceBind * deviceBind;

@property (nonatomic, assign) NSTimeInterval wifiListTimeOut;

@property (nonatomic, assign) BOOL stopWiFiList;

@property (nonatomic, strong) NSMutableArray * seachCOCOArray;
@property (nonatomic, assign) BOOL addSearchCOCO;
@property (nonatomic, assign) int searchWifiTimeSpace;
/** 一直是YES，调用dontConnectToHostForAWhile:后一段时间变为NO，这时不能连接Host */
@property (nonatomic, assign) BOOL canConnectToHost;

@property (nonatomic, strong) NSMutableDictionary * cmdCallbackDict;

@end

@implementation HMDeviceConfig

+ (instancetype)defaultConfig {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultConfig = [[HMDeviceConfig alloc] init];
        
        // 开始时设置为YES
        defaultConfig.canConnectToHost = YES;
    });
    
    return defaultConfig;
}

- (instancetype)init {
    if (self= [super init]) {
        _connectCount = 0;
        self.soketDic = [NSMutableDictionary dictionary];
        self.wifiList = [NSMutableArray array];
        self.deviceBind = [[HMDeviceBind alloc] init];
        _APSocket = [[HMAPSocket alloc] initWithDelegate:self];
        self.searchWifiTimeSpace = 3;
        
        self.apDeviceType = HmAPDeviceTypeUnkown;
        self.autoRequestWifiList = YES;
        
        // 开始时设置为YES
        defaultConfig.canConnectToHost = YES;
        
    }
    
    return self;
}
- (NSString *)getCurrentAPDeviceSSID {
    NSString * ssid = nil;
    switch (self.apDeviceType) {
        case HmAPDeviceTypeCOCO: {
            ssid = COCOAPSSID;
            break;
        }
        default: {
            
            ssid = connectSSid();
            break;
        }
    }
    
    return ssid;
}





- (void)localMeasurementWithUid:(NSString *)uid cmdType:(int)cmdType
{
    if (!uid) {
        uid = @"";
    }
    HMAPConfigMsg *msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_LocalMeasurement;
    int serial = [BLUtility getTimestamp];
    msg.msgBody = @{@"uid":uid,@"serial":@(serial),@"cmdType":@(cmdType),@"cmd":@(VhAPConfigCmd_LocalMeasurement)};
    [[HMDeviceConfig defaultConfig] sendMsg:msg callback:self];
}



#pragma mark - 搜索未绑定的COCO

- (void)searchUnbindCOCO {
    
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
                NSMutableArray * dataArray = [NSMutableArray array];
                DLog(@"deviceList = %@",deviceList);
                for (NSDictionary * dic in deviceList) {
                    HMAPDevice * device = [[HMAPDevice alloc] init];
                    device.mac = [dic objectForKey:@"uid"];
                    device.modelId = [dic objectForKey:@"model"];

                    if ([self isOldCocoModel:device.modelId]) {     // 判断如果是旧版 E10 开头的 COCO，则替换为以下 model
                        device.modelId = @"7f831d28984a456698dce9372964caf3";
                    }

                    if (!isHostModel(device.modelId) && [HMProductModel productModelWithModel:device.modelId]) {
                        [dataArray addObject:device];
                    }
                }
                
                self.seachCOCOArray = dataArray;
                
                [HMBaseAPI postNotification:KNOTIFICATION_SEARCH_UNBIND_WIFI_DEVICE object:nil];
            }
        });
    }
}


- (BOOL)isOldCocoModel:(NSString *)model {
    if (!model) {
        return NO;
    }
    if (([model rangeOfString:kCocoModel].location != NSNotFound)) {
        return YES;
    }
    return NO;
}


/**
 *  搜索coco结果
 *
 *  @return
 */
- (NSMutableArray *)getSearchCOCOResult {
    return self.seachCOCOArray;
}

- (void)removeDeviceArray {
    
    [self.seachCOCOArray removeAllObjects];
}


/**
 *  循环连接设备，直到连上为止
 */
- (void)connetToHost {
    self.stopSetDevice = NO;
    [self loopConnectToHost];
    DLog(@"aaaaaa %@",self);
    if (!_timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(loopConnectToHost) userInfo:nil repeats:YES];
    }
    
}
/**
 *  停止连接
 */
- (void)stopConnectToCOCO {
    [self.timer invalidate];
    self.timer = nil;
}
- (void)loopConnectToHost {
    LogFuncName();
    if(![self isORviboDeviceSSID]){
        _connectCount = 0;
        [self stopConnectToCOCO];
        [self delegateCandleResulte:VhAPConfigResult_CanNotConnectToDeviceWiFi];
        DLog(@"------------------当前连接非COCO  ssid,不再尝试连接------------------");
        return;
    }
    
    // 由dontConnectHostForAWhile:变成了一段时间内不允许连接
    if (self.canConnectToHost == NO) {
        _connectCount = 0;
        [self stopConnectToCOCO];
        DLog(@"------------------dontConnectHostForAWhile: 这段时间不能连接------------------");
        return;
    }
    
    [self.APSocket disconnectSocket];
    if ( _connectCount <= TotalCount) {
        if(![self.APSocket isConnectedToCOCO]){
            DLog(@"------------socket 开始连接 %ld---------------",(long)_connectCount);
            [self.APSocket connectToHost];
        }
        _connectCount ++;
    }else {
        _connectCount = 0;
        [self.timer invalidate];
        self.timer = nil;
        
        [self delegateCandleResulte:VhAPConfigResult_StopConnectCOCO];
        
    }
    
}

#pragma mark 判断是不是连接的是 设备的ssid
- (BOOL)isORviboDeviceSSID {
    
    NSString * ssid = [self currentConnectSSID];
    if ([ssid isEqualToString:HomeMateAPSSID]
        || [ssid isEqualToString:COCOAPSSID]
        || [ssid isEqualToString:LenovoAPSSID]) {
        return YES;
    }
    
    return NO;
    
}

/**
 *  获取当前连接wifi ssid
 *
 *  @return ssid
 */
- (NSString *)ssid {
    return [HMAPGetIp getCurrentSSID];
}

/**
 *  保存用户默认SSID
 */
- (void)setDefaultSSID {
    self.defaultSSID = [self currentConnectSSID];
    if (![[self currentConnectSSID] isEqualToString:COCOSSID] && ![[self currentConnectSSID] isEqualToString:HOMEMATESSID]) {
        if(self.defaultSSID.length == 0){
            self.defaultSSID = @"";
        }
        [HMUserDefaults setObject:self.defaultSSID forKey:@"defaultSSID"];
    }
}


/**
 *  判断是否连接到COCO
 *
 *  @return
 */
- (BOOL)isConnectedToDevice {
    return [self.APSocket isConnectedToCOCO];
}

/**
 *  获取默认SSID
 *
 *  @return 默认ssid
 */
- (NSString *)getDefaultSSID {
    
    _defaultSSID=  [HMUserDefaults objectForKey:@"defaultSSID"];
    
    return _defaultSSID;
}

/**
 *  判断当前的ssid  是不是连接的 alink_ORVIBO_LIVING_OUTLET_E10 或者 HomeMate_AP
 *
 *  @return YES 是  NO 不是
 */
- (BOOL)isAPDeviceSSID {
    
    NSString * ssid = [self currentConnectSSID];
    if([ssid isEqualToString:COCOSSID] || [ssid isEqualToString:HOMEMATESSID]) {
        return YES;
    }else {
        
        return NO;
    }
    
}


/**
 *  判断设备和Wifi名称是否对应
 *
 *  @return
 */
- (BOOL)isCOCOSsid {
    // 和apDeviceType对应的Wifi名称
    NSString * ssid = [[HMDeviceConfig defaultConfig] getCurrentAPDeviceSSID];
    DLog(@"正在配置的设备的ssid：%@ 手机的ssid：%@",ssid,[self ssid]);

    // 获取当前的ssid
    if([[self ssid] isEqualToString:ssid] ) {
        return YES;
    }else {
        
        if ([[HMAPGetIp getLocalIP] rangeOfString:@"172.31.254"].length != 0) {
            return YES;
        }else {
            return NO;
        }
    }
}

- (BOOL)isAlarmHubSsid {
    NSString * ssid = [[HMDeviceConfig defaultConfig] getCurrentAPDeviceSSID];
    DLog(@"正在配置的设备的ssid：%@ 手机的ssid：%@",ssid,[self ssid]);
    // 获取当前的ssid
    if([[self ssid] isEqualToString:ssid] ) {
        return YES;
    }else {
        if ([[HMAPGetIp getLocalIP] rangeOfString:@"192.168.2"].length != 0) {
            return YES;
        }else {
            return NO;
        }
    }
}



/**
 *  获取当前连接wifi ssid
 *
 *  @return ssid
 */
- (NSString *)currentConnectSSID {
    return [HMAPGetIp getCurrentSSID];
}

/**
 *  断开设备连接
 */
- (void)disConnect {

    DLog(@"--------------断开COCO，初始化数据------------");
    [self.wifiTimer invalidate];
    [self.timer invalidate];
    self.wifiTimer = nil;
    self.timer = nil;
    _connectCount = 0;
    _wifiCount = 0;
    apBindDeviceCount = 5;
    _stopWiFiList = NO;
    [self stopConnectToCOCO];
    self.defaultSSID = nil;
    [self.wifiList removeAllObjects];
    [self.APSocket disconnectSocket];
    [HMAPConfigEnDecoder defaultEnDecoder].leftData = nil;
    
    DLog(@"HMOpenSDK AP STATUS:结束AP配置");

}

/**
 *  停止请求wifi
 */
- (void)stopRequestWiFi {
    
    _stopWiFiList = YES;
}

/**
 *  刷新wifi
 */
- (void)reFreshWiFiList {
    _stopWiFiList = NO;
    [self getWifiList];
}

/**
 *  请求WiFi列表
 */
- (void)requestWifiListTimeOut:(NSTimeInterval)timeOut {
    _wifiListTimeOut = timeOut;
    _stopWiFiList = NO;
    [self getWifiList];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 5; i ++) {
            sleep(weakSelf.searchWifiTimeSpace);
            weakSelf.wifiCount = i;
            [weakSelf getWifiList];
            
            if (weakSelf.wifiCount == 4) {
                sleep(weakSelf.searchWifiTimeSpace + 1);
                DLog(@"--------- 请求wifi列表完成----------");
                [HMAPConfigEnDecoder defaultEnDecoder].leftData = nil;
                [weakSelf delegateCandleResulte:VhAPConfigResult_getWifiListFinish];
            }
            
        }
    });
    
}

/**
 *  获取wifi列表
 */
- (void)getWifiList {
    if (_stopWiFiList) {
        return;
    }
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_WIFIList;
    msg.timeoutSeconds = _wifiListTimeOut;
    NSDictionary *dic = @{@"cmd":[NSNumber numberWithInt:msg.cmd],@"scanChannel":@0};
    msg.msgBody =dic;
    
    [[HMDeviceConfig defaultConfig] sendMsg:msg callback:self];
    
    
}

/**
 *  一段时间内都不允许再连接Host[待删除]
 */
- (void)dontConnectHostForAWhile:(NSTimeInterval)littleTime {
    if (littleTime > 0) {
        _canConnectToHost = NO;
        
        __weak typeof(self)wself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(littleTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            wself.canConnectToHost = YES;
        });
    }
}

#pragma mark - 发送命令

/**
 *  修改设备名称
 *
 *  @param deveceName
 */
- (void)modifyDeviceName:(NSString *)deviceName {
    
    ServerModifyDeviceCmd * cmd = [ServerModifyDeviceCmd object];
    cmd.uid = self.vhDevice.uid;
    cmd.deviceId = self.vhDevice.deviceId;
    cmd.deviceName = deviceName;
    cmd.roomId = self.vhDevice.roomId;
    cmd.irDeviceId = self.vhDevice.irDeviceId;
    cmd.deviceType = self.vhDevice.deviceType;
    cmd.sendToServer = YES;
    
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            [self delegateCandleResulte:VhAPConfigResult_modifyNameSuccess];
        }else {
            [self delegateCandleResulte:VhAPConfigResult_modifyNameFail];
        }
    });
    
    
}

/**
 *  获取设备信息
 */
- (void)getDeviceInfoTimeOut:(NSTimeInterval)timeOut {
    
    
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_DeviceInfo;
    msg.timeoutSeconds = timeOut;
    NSDictionary *dic = @{@"cmd":[NSNumber numberWithInt:msg.cmd]};
    msg.msgBody =dic;
    
    [[HMDeviceConfig defaultConfig] sendMsg:msg callback:self];
}


/**
 *  配置设备wifi
 *
 *  @param ssid
 *  @param pwd
 */
- (void)settingDevice:(NSString *)ssid pwd:(NSString *)pwd timeOut:(NSTimeInterval)timeOut{
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_SetWifi;
    msg.timeoutSeconds = timeOut;
    NSDictionary *dic = @{@"cmd":[NSNumber numberWithInt:msg.cmd],@"ssid":ssid,@"password":pwd};
    msg.msgBody =dic;
    
    [[HMDeviceConfig defaultConfig] sendMsg:msg callback:self];
}


/**
 *  发送消息
 *
 *  @param msg      消息
 *  @param callback 回调
 */
- (void)sendMsg:(HMAPConfigMsg *)msg callback:(id<HMAPConfigCallback>)callback {

    DLog(@"AP 将发送cmd: %@", @(msg.cmd));
    if(![self.APSocket isconnected]) {
        DLog(@"发送命令ap配置命令连接断开，重新连接");
        [self connetToHost];
        return;
    }
    
    DLog(@"ap 配置发送命令 %@",msg.msgBody);
    
    DLog(@"add msg = %@",self.soketDic);
    
    
    msg.callback = callback;
    
    [self.APSocket sendData:[[HMAPConfigEnDecoder defaultEnDecoder] encoderWithMsg:msg]];
    [self.soketDic setObject:msg forKey:[NSNumber numberWithInt:msg.cmd]];
    [[HMDeviceConfigTimeOutManager getTimeOutManager] addVhAPConfigMsg:msg];
    
}

- (void)onTimeout:(HMAPConfigMsg *)msg {
    
    HMAPConfigMsg * oldMsg = [self.soketDic objectForKey:[NSNumber numberWithInt:msg.cmd]];
    if (oldMsg.cmd == VhAPConfigCmd_DeviceInfo) {
        [self.soketDic removeObjectForKey:[NSNumber numberWithInt:oldMsg.cmd]];
    }
    [oldMsg.callback onResponseWithCmd:msg.cmd MsgBody:msg.msgBody IsTimeout:YES IsNetDisconnect:NO];
}

/**
 *  取消绑定
 */
- (void)stopBindDevice {
    [self.deviceBind stopBindDevice:YES];
}


int apdeviceTimeOut = 0;


/// 处理服务器的响应消息
/// @param cmd 命令字
/// @param msg 响应消息
/// @param isTimeout 是否超时
/// @param isNetDisconnect 是否网络断开
-(void)onResponseWithCmd:(int)cmd
                 MsgBody:(NSDictionary*)msg
               IsTimeout:(BOOL)isTimeout
         IsNetDisconnect:(BOOL)isNetDisconnect {
    switch (cmd) {
        case VhAPConfigCmd_DeviceInfo:
        {
            if (!isTimeout) {
                HMAPDevice * device = [[HMAPDevice alloc] init];
                device.deviceName = [msg objectForKey:@"deviceName"];
                device.mac = [msg objectForKey:@"mac"];
                device.protocolVersion  = [msg objectForKey:@"protocolVersion"];
                device.modelId = [msg objectForKey:@"modelId"];
                device.softwareVersion = [msg objectForKey:@"softwareVersion"];
                device.hardwareVersion = [msg objectForKey:@"hardwareVersion"];
                if ([[msg allKeys] containsObject:@"deviceState"]) {
                    device.deviceState = [[msg objectForKey:@"deviceState"] integerValue];
                }else {
                    device.deviceState = HMAPDeviceStateUnkown;
                }
                if([device.modelId isEqualToString:kHuanCaiModelId]) {
                    self.searchWifiTimeSpace = 15;
                }else {
                    self.searchWifiTimeSpace = 3;

                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HMBaseAPI postNotification:kNOTIFICATION_AP_ACCESS_WIFIMODEL object:device.modelId userInfo:nil];
                });
                
                if(!device.modelId.length || [device.modelId isEqualToString:kHanFengCocoModelId]) {// 汉枫的COCO
                    self.apDeviceType = HmAPDeviceTypeCOCO;
                } else if ([device.modelId isEqualToString:@"90ce712071d0415abde23fad05fbad16"]) {// 联想智能插座
                    self.apDeviceType = HmAPDeviceTypeLenovo;
                } else {
                    self.apDeviceType = HmAPDeviceTypeHomeMate;
                }
                
                self.APDevice = device;
                
                [self delegateCandleResulte:VhAPConfigResult_getDeviceInfoFinish];

                if (self.autoRequestWifiList && device.deviceState != HMAPDeviceStateInSetting) {
                    [self requestWifiListTimeOut:20];
                }
                
            } else {
                
                DLog(@"------获取device信息 超时--------");
                // 防止获取设备信息超时后老弹框   bug 10480
                //                [self requestWifiListTimeOut:20];
                
                if (apdeviceTimeOut < 5) {
                    [self connetToHost];
                    apdeviceTimeOut ++;
                }else {
                    apdeviceTimeOut = 0;
                    [self delegateCandleResulte:VhAPConfigResult_getDeviceInfoTimeOut];
                    
                }
                
            }
            
        }
            break;
        case VhAPConfigCmd_WIFIList: {
            
            if (!isTimeout) {
                HMAPWifiInfo * wifiDeviceInfo = [[HMAPWifiInfo alloc] initForDic:msg];
                [self addWifi:wifiDeviceInfo];
                
                [self delegateCandleResulte:VhAPConfigResult_getOneWifi];
                
            } else {
                
                [self delegateCandleResulte:VhAPConfigResult_getWifiListTimeOut];
                
            }
            
        }
            break;
            
        case VhAPConfigCmd_SetWifi: {
            _wifiCount = _wifiListTimeOut;
            if (!isTimeout) {
                NSInteger result = [[msg objectForKey:@"result"] integerValue];
                
                if (result == 0) {
                    self.stopSetDevice = YES;
                    [self delegateCandleResulte:VhAPConfigResult_setDeviceFinish];
                    
                }else {
                    [self delegateCandleResulte:VhAPConfigResult_setDeviceFail];
                    
                }
                
                DLog(@"setting  result = %ld",(long)result);
            } else {
                DLog(@"setting  result time out");
                DLog(@"------配置device 超时 重新连接--------");;
                [self disConnect];
                [self connetToHost];
                
                [self delegateCandleResulte:VhAPConfigResult_getWifiListTimeOut];
                
            }
            
        }
            break;
            
        case VhAPConfigCmd_LocalMeasurement:{
            
            if (!isTimeout) {
                int status = [[msg objectForKey:@"status"] intValue];
                VhAPConfigResult result = status == 0 ? VhAPConfigResult_Success:VhAPConfigResult_Fail;
                [self delegateCandleResulte:result cmd:VhAPConfigCmd_LocalMeasurement obj:nil];
                
            } else {
                [self delegateCandleResulte:VhAPConfigResult_TimeOut cmd:VhAPConfigCmd_LocalMeasurement obj:nil];
            }
            
            break;
        }
            
        case VhAPConfigCmd_SENSOR_DATA_REPORT:{
            
            HMSensorData *sensorData = [HMSensorData sensorDataWithDictionary:msg];
            [self delegateCandleResulte:VhAPConfigResult_Success cmd:VhAPConfigCmd_SENSOR_DATA_REPORT obj:sensorData];
            
            //获取到传感器状态数据后需要回复
            int serial = [[msg objectForKey:@"serial"] intValue];
            NSString *uid = [msg objectForKey:@"uid"];
            HMAPConfigMsg *msg = [[HMAPConfigMsg alloc] init];
            msg.cmd = VhAPConfigCmd_SENSOR_DATA_REPORT;
            msg.msgBody = @{@"serial":@(serial),@"uid":uid,@"status":@(0),@"cmd":@(VhAPConfigCmd_SENSOR_DATA_REPORT)};
            DLog(@"【本地测量模式】回复传感器数据上报");
            [self sendMsg:msg callback:nil];
            
            break;
        }
        case VhAPConfigCmd_REMAIN_TIME:{
            
            NSString *uid = [msg objectForKey:@"uid"];
            DLog(@"uid = %@,本地测量模式剩余时间(单位为秒)",uid);
            NSNumber *remainTime = [msg objectForKey:@"remainTime"];
            [self delegateCandleResulte:VhAPConfigResult_Success cmd:VhAPConfigCmd_REMAIN_TIME obj:remainTime];
            
            int serial = [[msg objectForKey:@"serial"] intValue];
            HMAPConfigMsg *msg = [[HMAPConfigMsg alloc] init];
            msg.cmd = VhAPConfigCmd_REMAIN_TIME;
            msg.msgBody = @{@"serial":@(serial),@"uid":uid,@"status":@(0),@"cmd":@(VhAPConfigCmd_REMAIN_TIME)};
            [self sendMsg:msg callback:nil];
            
            break;
        }
        case VhAPConfigCmd_Quit_AP:
        case VhAPConfigCmd_LOCK_GETUSERINFO:
        case VhAPConfigCmd_LOCK_ADDUSER:
        case VhAPConfigCmd_LOCK_DELETEUSER:
        case VhAPConfigCmd_LOCK_ADDUSERKEY:
        case VhAPConfigCmd_LOCK_DELETEUSERKEY:
        case VhAPConfigCmd_LOCK_CANCELADDFP:
        case VhAPConfigCmd_CANCELADDRF:
        case VhAPConfigCmd_LOCK_GETOPENRECORD:
        case VhAPConfigCmd_LOCK_STOPGETOPENRECORD:
        case VhAPConfigCmd_LOCK_SETVOLUME:
        case VhAPConfigCmd_LOCK_ADDFPREPORT:
        case VhAPConfigCmd_LOCK_ADDRFREPORT:
        case VhAPConfigCmd_LOCK_DELETEFPREPORT:{
            
            HMC1LockCallBack callback = self.cmdCallbackDict[@(cmd)];
            
            if(callback){
                if(isTimeout){
                    DLog(@"C1 门锁超时命令 %d",cmd);
                    callback(1,nil);
                }else{
                    callback(0,msg);
                }
            }
            
        }
            break;
        case VhAPConfigCmd_LOCK_ASYNUSERINFO:{
            
            HMC1LockCallBack callback = self.cmdCallbackDict[@(cmd)];
            
            if(callback){
                if(isTimeout){
                    callback(1,nil);
                }else{
                    
                    if (![[msg allKeys] containsObject:@"pageCount"]) {//说明是旧版本
                        callback(0,msg);
                    }else {
                        int pageCount = [[msg objectForKey:@"pageCount"] intValue];
                        int pagePos = [[msg objectForKey:@"pagePos"] intValue];
                        NSArray * userInfo = [msg objectForKey:@"userInfo"];
                        if(pagePos == pageCount) {//说明是最后一页
                            [self.lockUserInfo addObjectsFromArray:userInfo];
                            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                            [dic setObject:self.lockUserInfo forKey:@"userInfo"];
                            [dic setObject:@(0) forKey:@"status"];
                            callback(0,dic);
                            [self.soketDic removeObjectForKey:[NSNumber numberWithInt:VhAPConfigCmd_LOCK_ASYNUSERINFO]];

                        }else {
                            [self.lockUserInfo addObjectsFromArray:userInfo];//暂存起来
                        }
                    }
                    
                }
            }
            
        }
            break;

        default:
            break;
    }
    
}


/**
 *  解绑设备
 */
- (void)startUnBindDevice {
    
    self.deviceBind.isStop = NO;
    apBindDeviceCount = 0;
    
    [self.deviceBind unBindDevice:self.APDevice callback:^(KReturnValue retunValue, NSDictionary *returnDic) {
        switch (retunValue) {
                
            case KReturnValueServerUnbindFail:{
                DLog(@"-----------解绑失败--------------");
                [self delegateCandleResulte:VhAPConfigResult_unbindFail];
                break;
            }
                
            default:
            {
                DLog(@"-----------解绑成功--------------");
                [self delegateCandleResulte:VhAPConfigResult_unbindSuccess];
            }
                
                break;
        }
    }];
     
    
}


/**
 *  绑定设备
 */

int apBindDeviceCount = 0;

- (void)startBindDevice {
    
    self.deviceBind.isStop = YES;
    [self.deviceBind bindDevice:self.APDevice callback:^(KReturnValue retunValue, NSDictionary *returnDic) {
        switch (retunValue) {
                
            case KReturnValueSuccess: {
                apBindDeviceCount = 0;
                DLog(@"----------服务器返回绑定成功-----------------------");
                [self insertToDataBase:returnDic isSearch:NO];
            }
                break;
                
            case KReturnValueMainframeOffline: {
                apBindDeviceCount = 0;
                [self delegateCandleResulte:VhAPConfigResult_bindDeviceOffLine];
            }
                break;
            case KReturnValueDeviceIsBinded: {
                
                DLog(@"----------服务器返回绑定设备已被绑定，再发解绑命令-----------------------");
                [self startUnBindDevice];
                break;
            }
            default:
                
            {
                if (apBindDeviceCount < 5) {
                    DLog(@"-----------绑定失败，重新绑定%d次",apBindDeviceCount);
                    apBindDeviceCount ++;
                    sleep(2);
                    [self startBindDevice];
                }else {
                    DLog(@"-----------完全绑定失败，放弃绑定",apBindDeviceCount);
                    
                    apBindDeviceCount = 0;
                    [self delegateCandleResulte:VhAPConfigResult_bindFail];
                }
                
            }
                break;
        }
    }];
    
}
- (void)insertToDataBase:(NSDictionary *)returnDic isSearch:(BOOL)isSearch{
    
    DLog(@"-------绑定成功返回数据 %@", returnDic);
    DLog(@"先删除数据再插入新数据");
    
    [self deleteHmDevice:returnDic];
    
    if ([HMDeviceConfig defaultConfig].apDeviceType == HmAPDeviceTypeHuaDingSocket
        ||[HMDeviceConfig defaultConfig].apDeviceType == HmAPDeviceTypeHuaDingStrip ) {
        
        NSArray * deviceArray = [returnDic objectForKey:@"device"];
        for(NSDictionary * dict in deviceArray) {
            
            NSString * uid = [returnDic objectForKey:@"uid"];
            HMDevice * device = [HMDevice objectFromDictionary:dict];
            
            if (!device.uid) {
                device.uid = uid;
            }
            
            [device insertObject];
            
            self.vhDevice = device;
        }
        
        NSArray * deviceStatus = [returnDic objectForKey:@"deviceStatus"];
        for (NSDictionary * dict in deviceStatus) {
            HMDeviceStatus * status = [HMDeviceStatus objectFromDictionary:dict];
            [status insertObject];
        }
        
    }else{
        NSDictionary * deviceDic = [returnDic objectForKey:@"device"];
        
        HMDevice * device = [HMDevice objectFromDictionary:deviceDic];
        NSString * uid = [returnDic objectForKey:@"uid"];
        device.uid = uid;
        if (!device.model) {
            device.model = [returnDic objectForKey:@"model"];
        }
        [device insertObject];
        self.vhDevice = device;
        
        NSDictionary * deviceStatus = [returnDic objectForKey:@"deviceStatus"];
        HMDeviceStatus * status = [HMDeviceStatus objectFromDictionary:deviceStatus];
        [status insertObject];
        
    }
    
    // 重配后服务器会把messagepush的数据置为delFlag=1
    // 解绑前有可能是关掉了开关，所以重绑后打开定时执行提醒开关
    //    [self openTimerTipSwitch];
    
    NSDictionary * gatewayDic = [returnDic objectForKey:@"gateway"];
    if (gatewayDic) {
        HMGateway * gateway = [HMGateway objectFromDictionary:gatewayDic];
        [gateway insertObject];
    }
    
    // 常用模式表

    NSArray *frequentlyModeArray = returnDic[@"frequentlyMode"];
    if ([frequentlyModeArray isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in frequentlyModeArray) {
            NSMutableDictionary *frequentlyModeDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            HMFrequentlyModeModel *frequentlyMode = [HMFrequentlyModeModel objectFromDictionary:frequentlyModeDic];
            [frequentlyMode insertObject];
        }
    }

    NSDictionary * userGatewayBindDic = [returnDic objectForKey:@"userGatewayBind"];
    if (userGatewayBindDic) {
        HMUserGatewayBind * userGatewayBind = [HMUserGatewayBind objectFromDictionary:userGatewayBindDic];
        [userGatewayBind insertObject];
    }
    
    NSArray * timingGroupArray = [returnDic objectForKey:@"timingGroupList"];
    if (timingGroupArray) {
        for (NSDictionary * timingGroupDic in timingGroupArray) {
            HMTimingGroupModel * timingGroupObj = [HMTimingGroupModel objectFromDictionary:timingGroupDic];
            [timingGroupObj insertObject];
        }
    }
    
    NSArray * timingArray = [returnDic objectForKey:@"timingList"];
    
    if (timingArray) {
        for (NSDictionary * timingDic in timingArray) {
            HMTiming * timingObj = [HMTiming objectFromDictionary:timingDic];
            [timingObj insertObject];
        }
    }
    
    addDeviceBind(self.vhDevice.uid, self.vhDevice.model);
    
    //重新读一次表
    [HMLoginAPI readDataInFamily:userAccout().familyId completion:^(KReturnValue value, id object) {
        
    }];
    
    if (isSearch) {
        DLog(@"-------局域网发现coco绑定成功-----------");
        
    }else {
        if([self.vhDevice.uid isEqualToString:self.APDevice.mac]){
            DLog(@"-------绑定成功返回给代理函数-----------");
            
            [self delegateCandleResulte:VhAPConfigResult_bindSuccess];
        }else {
            DLog(@"-------绑定的mac地址跟返回的deviceUid 不一致");
        }
    }
}

/**
 *  删除设备信息
 */
- (void)deleteHmDevice:(NSDictionary *)bindDeviceInfo{
    
    NSString *uid = bindDeviceInfo[@"uid"];
    DLog(@"====================获取要删除wifi设备uid息：%@",uid);
    
    HMDevice * device = [HMDevice wifiObjectWithUid:uid];
    
    if (device) {
        
        DLog(@"deleteHmDevice: 设备表查找到设备信息 %@",device);
        
        if (device.deviceType == KDeviceTypeAllone) {
            
            if (self.deleteDataDelegate && [self.deleteDataDelegate respondsToSelector:@selector(deleteMagicCubeFileDataWithUid:)]) {
                [self.deleteDataDelegate deleteMagicCubeFileDataWithUid:device.uid];
            }
            [HMDevice deleteAllRelatedObjectDBDataWithUid:device.uid];

        } else {
            if (device.deviceType == kDeviceTypeCoco || device.deviceType == KDeviceTypeS20) {
                
                // 删除相应消息
                BOOL result =  [HMMessage deleteMsgWithDeviceId:device.deviceId];
                
                if (!result) {
                    DLog(@"====================删除设备的推送消息失败，设备uid：%@",device.uid);
                }else {
                    DLog(@"====================删除设备的推送消息成功，设备uid：%@",device.uid);
                }
                
                //删除对应倒计时
                result = [HMCountdownModel deleteCountdownObjWithDeviceId:device.deviceId];
                
                if (!result) {
                    DLog(@"====================删除设备倒计时失败,设备uid：%@",device.uid);
                }else {
                    DLog(@"====================删除设备倒计时成功,设备uid：%@",device.uid);
                }
                
                // 删除是否需要推送的数据
                [HMMessagePush deleteWifiSockectPushSettingWithDeviceId:device.deviceId];
            
            }else if (device.deviceType == kDeviceTypeCODetector || device.deviceType == kDeviceTypeHCHODetector) {
                [HMSensorData deleteWithDeviceId:device.deviceId];
                [HMSensorEvent deleteWithDeviceId:device.deviceId];
                [HMStatusRecordModel deleteWithDeviceId:device.deviceId];
            }else if(device.deviceType == KDeviceTypeCasement
                     ||device.deviceType == KDeviceTypeRoller
                     || device.deviceType == KDevicePercentTypeRollupDoor
                     || device.deviceType == KDevicePercentTypeAwning
                     || device.deviceType == KDeviceTypePercentScreen) {
                [HMFrequentlyModeModel deleteAllCurtainModeWithDevice:device];
            }
            
            cleanDeviceData(device.uid);
        }
    }else{
        DLog(@"deleteHmDevice: 设备表未查找到设备信息 uid = %@ 也调用数据清除接口，清除旧的定时，模式等信息",uid);
        cleanDeviceData(uid);
    }
}

- (void)addWifi:(HMAPWifiInfo *)wifi {
    
    
    if(!wifi.ssid.length || wifi == nil)
        return;
    
    if([wifi.ssid isEqualToString:COCOSSID] || [wifi.ssid isEqualToString:HOMEMATESSID]) {
        return; //不处理搜索到的设备SSSID
    }
    
    HMAPWifiInfo * oldWifi = nil;
    for (HMAPWifiInfo * tempWifi in self.wifiList) {
        if ([tempWifi.ssid isEqualToString:wifi.ssid]) {
            oldWifi = tempWifi;
            break;
        }
    }
    
    if (oldWifi) {
        if (oldWifi.rssi < wifi.rssi) {
            [self.wifiList removeObject:oldWifi];
            [self.wifiList addObject:wifi];
        }
    }else {
        [self.wifiList addObject:wifi];
    }
}

/**
 *  获取wifi列表
 *b
 *  @return wifi
 */
- (NSMutableArray *)getOrderWifiList {
    [self.wifiList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        HMAPWifiInfo * wifi1 = (HMAPWifiInfo *)obj1;
        HMAPWifiInfo * wifi2 = (HMAPWifiInfo *)obj2;
        
        
        return wifi1.rssi < wifi2.rssi;
    }];
    
    return self.wifiList;
}


#pragma mark - self delegate

- (void)delegateCandleResulte:(VhAPConfigResult)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(vhApConfigResult:)]) {
            [self.delegate vhApConfigResult:result];
        }
    });
}


- (void)delegateCandleResulte:(VhAPConfigResult)result cmd:(int)cmd obj:(id)obj{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(vhApConfigResult:cmd:returnObj:)]) {
            [self.delegate vhApConfigResult:result cmd:cmd returnObj:obj];
        }else {
            DLog(@"------------VhAPConfig 代理不存在----------------");
        }
    });
}

- (void)setDelegate:(id<VhAPConfigDelegate>)delegate {
    if (_delegate != delegate) {
        DLog(@"HMDeviceConfig change delegate from %@ to %@", _delegate, delegate);
    }
    _delegate = delegate;
}

#pragma mark - VhApSocketDelegate
- (void)onDeliverData:(NSData *)data {
    
    NSMutableArray * newMsgArray = [[HMAPConfigEnDecoder defaultEnDecoder] decoderWithData:data];
   
    for (HMAPConfigMsg * newMsg in newMsgArray) {
        HMAPConfigMsg * oldMsg = [self.soketDic objectForKey:[NSNumber numberWithInt:newMsg.cmd]];
        
        if (newMsg.cmd == VhAPConfigCmd_SENSOR_DATA_REPORT ||
            newMsg.cmd == VhAPConfigCmd_REMAIN_TIME ||
            newMsg.cmd == VhAPConfigCmd_LOCK_ADDFPREPORT ||
            newMsg.cmd == VhAPConfigCmd_LOCK_ADDRFREPORT ||
            newMsg.cmd == VhAPConfigCmd_LOCK_DELETEFPREPORT) {
            [[HMDeviceConfig defaultConfig] onResponseWithCmd:newMsg.cmd MsgBody:newMsg.msgBody IsTimeout:NO IsNetDisconnect:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_C1UPLOADDATA object:newMsg.msgBody userInfo:nil];
        }else if (oldMsg.cmd != VhAPConfigCmd_WIFIList && oldMsg.cmd != VhAPConfigCmd_LOCK_ASYNUSERINFO) {
            [self.soketDic removeObjectForKey:[NSNumber numberWithInt:oldMsg.cmd]];
            [[HMDeviceConfigTimeOutManager getTimeOutManager] removeMsg:oldMsg];
        }
       
        [oldMsg.callback onResponseWithCmd:oldMsg.cmd MsgBody:newMsg.msgBody IsTimeout:NO IsNetDisconnect:NO];
    }
}
- (void)didConnected {
    
    DLog(@"------------socket 连接成功 ip = %@---------------",[HMAPGetIp getIp]);
    
    [self getDeviceInfoTimeOut:8];
    
    [self.timer invalidate];
    self.timer = nil;
    
    [self delegateCandleResulte:VhAPConfigResult_Connected];
    
}



- (void)onConnectTimeout {
    [self delegateCandleResulte:VhAPConfigResult_disconnectSocket];
}

- (void)onDisconnectWithError:(NSError *)err {
    DLog(@"------------socket 断开 %@------------------",err);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_AP_SOCKET_DISCONNECT object:nil userInfo:nil];
    [self delegateCandleResulte:VhAPConfigResult_disconnectSocket];
}

+ (NSString *)appName {
    return [HMStorage shareInstance].appName;
}

- (void)sendLockMsg:(HMAPConfigMsg *)msg callback:(HMC1LockCallBack)callback {
    
    if (callback) {
        [self.cmdCallbackDict setObject:callback forKey:@(msg.cmd)];
    }
    
    [self sendMsg:msg callback:self];
    
}

- (NSMutableDictionary *)cmdCallbackDict {
    
    if (_cmdCallbackDict == nil) {
        _cmdCallbackDict = [NSMutableDictionary dictionary];
    }
    
    return _cmdCallbackDict;
    
}
- (BOOL)connectedToDevice:(HMDevice*)device {
    return [self.APDevice.mac isEqualToString:device.uid]&&[self.APSocket isconnected];
}

- (NSMutableArray *)lockUserInfo {
    if (_lockUserInfo == nil) {
        _lockUserInfo = [NSMutableArray array];
    }
    return _lockUserInfo;
}

@end
