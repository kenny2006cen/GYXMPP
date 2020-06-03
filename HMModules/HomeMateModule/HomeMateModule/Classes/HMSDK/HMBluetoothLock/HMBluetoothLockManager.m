//
//  HMBlurtoothLockManager.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/10/23.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBluetoothLockManager.h"
#import "HMBluetoothCmd.h"
#import "HMBluetoothEnDecoder.h"
#import "HMBluetoothDataCenter.h"
#import "NSData+CRC32.h"
static HMBluetoothLockManager * bluetoothManager = nil;
static int uploadRecordPageCount = 20;
static int reconnectBlutoothSecond = 60;
@interface HMBluetoothLockManager()
@property (nonatomic, strong)HMBluetoothDataCenter * dataCenter;
@property (nonatomic, strong)HMBluetoothCmdCallback addLockCallBack;//添加门锁的回调
@property (nonatomic, strong)HMBluetoothLockModel * lockModel;
@property (nonatomic, strong)NSString * currentHandleLockBleMac;//当前正在操作的门锁的蓝牙地址
@property (nonatomic, assign)int doorLockNetworkInformation;//当前添加门锁的组网状态
@property (nonatomic, strong)NSString * privateKey;
@property (nonatomic, strong)HMDevice * device;
@property (nonatomic,assign)int pageIndex;
@property (nonatomic, assign)int paried;
@property (nonatomic,strong) NSMutableArray * blueLockTotalRecord;
@property (nonatomic,assign) int   firmwareTransmissionLenth;//上传固件总的已经上传的长度
@property (nonatomic,assign) int   everyFirmwareTransmissionLenth;//每次上传的长度
@property (nonatomic,assign) short   currentFirmwareTransmissionSerial;//当前上传固件包的序列号
@property (nonatomic,strong) NSURL * currentFirmwareTransmissionPath;//当前上传固件的路径
@property (nonatomic, strong)HMBluetoothCmdCallback firmwareTransmissionCallBack;//上传固件的回调
@property (nonatomic, assign)BOOL firmwareUpdate;
@property (nonatomic, strong)HMDevice * updateDevice;
@property (nonatomic, strong)NSMutableArray <HMFirmwareModel *> * updateFilesArray;
@property (nonatomic, assign) int leftSecond;
@property (nonatomic,assign) FirmwareUpdateStatus updateStatus;
@property (nonatomic,assign) int updateCRC;
@property (nonatomic,assign) int transmissionPercent;
@property (nonatomic,strong) NSTimer * updateTimer;
@end

@implementation HMBluetoothLockManager
- (void)dealloc {
    DLog(@"%@ dealloc",self);
}
+ (HMBluetoothLockManager * )defaultManager {
    if(bluetoothManager == nil){
        bluetoothManager = [[HMBluetoothLockManager alloc] init];
        bluetoothManager.dataCenter = [[HMBluetoothDataCenter alloc] init];
        bluetoothManager.pageIndex = 1;
        bluetoothManager.leftSecond = reconnectBlutoothSecond;
        bluetoothManager.transmissionPercent = 1;
        bluetoothManager.updateStatus = FirmwareUpdateStatusNormal;
    };
    return bluetoothManager;
}
- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}


#pragma mark - 业务逻辑相关API

/**
 当前配置成功的device
 
 @return
 */
- (HMDevice *)addSuccessDevice {
    return self.device;
}

/**
 获取当前操作门锁的蓝牙mac地址，没有搜索到门锁为nil
 
 @return
 */
- (NSString *)getCurrentLockBleMac {
    return self.currentHandleLockBleMac;
}


/**
 扫描到门锁之后要保存
 
 @param bleMac
 */
- (void)setCurrentLockBleMac:(NSString *)bleMac {
    DLog(@"HMBlurtoothLockManager 保存当前蓝牙地址 = %@",bleMac);
    self.currentHandleLockBleMac = bleMac;
}


/**
 1、向服务器绑定门锁，这个过程请保证蓝牙不会断开，因为这个过程还会通过蓝牙跟门锁通信
 2、调用这个方法之前，务必调用握手命令，根据握手命令返回的状态做不同的处理

 @param errorCode  deviceHandshakeCallback: 返回的errorCode
 @param callback
 */
- (void)addLockToServerBluetoothLockErrorCode:(HMBluetoothLockStatusCode)errorCode callback:(HMBluetoothCmdCallback)callback {
    self.addLockCallBack = callback;
    if(errorCode == HMBluetoothLockStatusAppPublicKeyLockPrivateKey){//搜到门锁，握手失败，app是公钥门锁是私钥，要去服务器查一下是否有绑定关系，有绑定关系提示该设备已被其他家庭添加，没有绑定关系提示该设备已被设置。
        DLog(@"添加T1门锁，握手失败，app是公钥门锁是私钥，要去服务器查一下是否有绑定关系");
        [self checkLockBindingelationship];
    }else if(errorCode == HMBluetoothLockStatusAppPrivateKeyLockPublicKey){//搜到门锁，握手失败，app是私钥门锁是公钥，应用场景：绑定之后删除门锁，不重置再来添加，这时候要删除设备之后在走添加流程，、
        DLog(@"添加T1门锁，握手失败，app是私钥门锁是公钥");
        [self deleteLockThenAdd];
    }else if(errorCode == HMBluetoothLockStatusAppPublicDifferentKey){//搜到门锁，握手失败，都是私钥，但是值不对，这时候也要去查绑定关系
        DLog(@"添加T1门锁，握手失败，APP、门锁都是私钥，但是值不对");
        [self checkLockBindingelationship];
    }else if(errorCode == HMBluetoothLockStatusSuccess){//搜到门锁，判断门锁是否有私钥
        DLog(@"添加T1门锁，握手成功");
        [self checkLockExistencePrivateKey];
    }else {//其他情况，暂不处理，直接返回
        DLog(@"添加T1门锁，其他错误类型%d，不处理直接返回",errorCode);
        [self handleAddLockCallback:errorCode payload:nil];
    }
    
}
/**
 上传门锁里面的状态到服务器，这个方法会调用 readOpenDoorRecord，然后直接上传到服务器
 
 @param device 当前设备
 @param callback
 */
- (void)uploadDoorRecordToServerDevice:(HMDevice *)device callback:(HMBluetoothCmdCallback)callback {
    NSInteger time = [HMStatusRecordModel maxRecordUpdateTimeForDevice:device];//要从表里面取当前设备的最大时间
    self.blueLockTotalRecord = [NSMutableArray array];
    [self readOpenDoorRecord:(int)time callback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
        if(payload) {
            int status = [[payload objectForKey:@"status"] intValue];
            if (status == 0) {
                NSArray * messages = [payload objectForKey:@"messages"];
                for (NSDictionary * dic in messages) {
                    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                    [dict setObject:[dic objectForKey:@"userId"] forKey:@"authorizedId"];
                    [dict setObject:[dic objectForKey:@"type"] forKey:@"type"];
                    [dict setObject:[dic objectForKey:@"mode"] forKey:@"mode"];
                    [dict setObject:[dic objectForKey:@"time"] forKey:@"time"];
                    [self.blueLockTotalRecord addObject:dict];
                }
                if (self.blueLockTotalRecord.count) {
                    NSDictionary * dict = self.blueLockTotalRecord.lastObject;
                    int lastTime = [[dict objectForKey:@"time"] intValue];
                    [self loopReadRecordFromLockTime:lastTime device:device callback:callback];
                }
            }
        }
    }];
}


#pragma mark - 业务逻辑API内部方法

- (void)loopReadRecordFromLockTime:(int)time device:(HMDevice *)device callback:(HMBluetoothCmdCallback)callback{
    
    [self readOpenDoorRecord:time callback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
        if(payload) {
            int status = [[payload objectForKey:@"status"] intValue];
            if (status == 0) {
                NSArray * messages = [payload objectForKey:@"messages"];
                if (messages.count) {//说明有数据,要取最后一条时间，继续读
                    for (NSDictionary * dic in messages) {
                        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                        [dict setObject:[dic objectForKey:@"userId"] forKey:@"authorizedId"];
                        [dict setObject:[dic objectForKey:@"type"] forKey:@"type"];
                        [dict setObject:[dic objectForKey:@"mode"] forKey:@"mode"];
                        [dict setObject:[dic objectForKey:@"time"] forKey:@"time"];
                        [self.blueLockTotalRecord addObject:dict];
                    }
                    if (self.blueLockTotalRecord.count) {
                        NSDictionary * dict = self.blueLockTotalRecord.lastObject;
                        int lastTime = [[dict objectForKey:@"time"] intValue];
                        [self loopReadRecordFromLockTime:lastTime device:device callback:callback];
                    }
                }else {//说明没有数据了，要停止读，并且将数据上传到服务器
                    [self createUploadRecordData:device totalData:self.blueLockTotalRecord callback:callback];
                }
            }
        }
    }];
}

- (void)createUploadRecordData:(HMDevice *)device totalData:(NSArray *)allData callback:(HMBluetoothCmdCallback)callback {
    self.pageIndex = 1;//当前页数，默认为1
    unsigned long totalPage = 1;
    if (allData.count <= uploadRecordPageCount) {
        totalPage = 1;
    }else if (allData.count%uploadRecordPageCount == 0) {
        totalPage = allData.count/uploadRecordPageCount;
    }else if (allData.count%uploadRecordPageCount != 0) {
        totalPage = allData.count/uploadRecordPageCount + 1;
    }
    NSArray * pageArray = nil;
    if (allData.count <= uploadRecordPageCount) {
      pageArray = [allData subarrayWithRange:NSMakeRange((self.pageIndex - 1) * uploadRecordPageCount, allData.count)];
    }else {
      pageArray = [allData subarrayWithRange:NSMakeRange((self.pageIndex - 1) * uploadRecordPageCount, uploadRecordPageCount)];
    }
    [self sendUploadRecordDataCmd:device totalPage:totalPage allData:allData sendData:pageArray callback:callback];
}

- (void)sendUploadRecordDataCmd:(HMDevice *)device
                      totalPage:(unsigned long)totalPage
                        allData:(NSArray *)allData
                       sendData:(NSArray *)sendData
                       callback:(HMBluetoothCmdCallback)callback {
    UploadDeviceStatusRecordCmd * cmd = [UploadDeviceStatusRecordCmd object];
    cmd.uploadDeviceId = device.deviceId;
    cmd.uploadDeviceType = device.deviceType;
    cmd.uploadTPage = (int)totalPage;
    cmd.uploadPageIndex = self.pageIndex;
    cmd.uploadCount = (int)sendData.count;
    cmd.allList = sendData;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            if (self.pageIndex == totalPage) {//全部发完，回调
                callback(HMBluetoothLockStatusUploadRecordSuccess ,nil);
            }else {//没有发送完成
                self.pageIndex ++; //先开始发送后面一页
                int leftCount = (int)allData.count - (self.pageIndex - 1) * uploadRecordPageCount;//还剩多少条
                NSArray * pageArray = nil;
                if (leftCount <= uploadRecordPageCount) {
                    pageArray = [allData subarrayWithRange:NSMakeRange((self.pageIndex - 1) * uploadRecordPageCount, leftCount)];
                }else {
                    pageArray = [allData subarrayWithRange:NSMakeRange((self.pageIndex - 1) * uploadRecordPageCount, uploadRecordPageCount)];
                }
                [self sendUploadRecordDataCmd:device totalPage:totalPage allData:allData sendData:pageArray callback:callback];
            }
        }else {
            
        }
    });
}


- (void)resetLockPaired:(HMDevice *)device paired:(int)paried {
    
    ServerModifyDeviceCmd *modifydevice = [ServerModifyDeviceCmd object];
    modifydevice.userName = userAccout().userName;
    modifydevice.uid = device.uid;
    modifydevice.deviceId = device.deviceId;
    modifydevice.deviceType = device.deviceType;
    modifydevice.sendToServer = YES;
    modifydevice.isPreset = paried;
    
    sendCmd(modifydevice, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            DLog(@"修改门锁%@的配套信息成功",device.deviceName);
            device.isPreset = paried;
            [device updateObject];
        }else {
            DLog(@"修改门锁%@的配套信息成功",device.deviceName);

        }
    });
    
}



/**
 先删除旧的数据然后在添加
 */
- (void)deleteLockThenAdd {
    if (self.currentHandleLockBleMac) {
        [self deleteLocalData];
    }else {
        DLog(@"添加T1门锁，握手失败，app是私钥门锁是公钥,当前操作门锁蓝牙地址为空");
        [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
    }
}

- (void)deleteLocalData {
    HMGateway * gateWay = [HMGateway bluetoothLockGateWayWithbleMac:self.currentHandleLockBleMac];
    [gateWay deleteObject];
    HMUserGatewayBind * userGateWay = [HMUserGatewayBind bindWithUid:self.currentHandleLockBleMac];
    [userGateWay deleteObject];
    HMDevice * device = [HMDevice lockWithBlueMacId:self.currentHandleLockBleMac];
    [device deleteObject];
    [HMDoorUserBind deleteAllObjectWithExtAddr:device.extAddr];
    [self getLockDeviceThenAddToServer];
}

- (void)getLockDeviceThenAddToServer {
    [self getEquipmentInformationCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
        
        if (payload) {
            
            int status = [[payload objectForKey:@"status"] intValue];
            if (status == 0) {
                DLog(@"添加T1门锁，握手失败，app是私钥门锁是公钥,删除绑定关系成功,获取设备信息成功");
                HMBluetoothLockModel * lockModel = [[HMBluetoothLockModel alloc] init];
                lockModel.ModelID= [payload objectForKey:@"ModelID"];
                lockModel.hardwareVersion = [payload objectForKey:@"hardwareVersion"];
                lockModel.bleMAC = self.currentHandleLockBleMac;
                lockModel.mcuUniqueID = [payload objectForKey:@"mcuUniqueID"];
                lockModel.zigbeeMAC = [[payload objectForKey:@"zigbeeMAC"] lowercaseString];
                lockModel.bleVersion = [payload objectForKey:@"bleVersion"];
                lockModel.mcuVerion = [payload objectForKey:@"mcuVerion"];
                lockModel.zigbeeVersion = [payload objectForKey:@"zigbeeVersion"];
                self.lockModel = lockModel;
                [self gettingTheStateOfZigbeeNetworkingCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
                    if (payload) {//查询到配对网关信息成功
                        DLog(@"添加T1门锁，查询配对网关，查询门锁的配对信息成功",errorCode);
                        int nwkStatus = [[payload objectForKey:@"nwkStatus"] intValue];
                        self.lockModel.nwkStatus = nwkStatus;
                        self.lockModel.paried = [[payload objectForKey:@"paried"] intValue];
                        [self bindDoorLock];
                    }else {//查询到配对网关信息失败
                        DLog(@"添加T1门锁，查询配对网关，查询失败%d",errorCode);
                        [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
                    }
                }];
            }else {
                DLog(@"添加T1门锁，握手失败，app是私钥门锁是公钥,删除绑定关系成功,获取设备信息返回值不为0");
                [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];

            }
        }else {
            DLog(@"添加T1门锁，握手失败，app是私钥门锁是公钥,删除绑定关系成功,获取设备信息失败");
            [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
        }
    }];
}


/**
 保存蓝牙获取的门锁信息
 
 @param lockModel
 */
- (void)saveLockModel:(HMBluetoothLockModel *)lockModel {
    self.lockModel = lockModel;
}

/**
 判断门锁是否存在私钥
 */
- (void)checkLockExistencePrivateKey {
    
    HMGateway * lock = [HMGateway bluetoothLockGateWayWithbleMac:self.currentHandleLockBleMac];//门锁的蓝牙地址
    if(lock == nil || lock.password.length == 0) {//说明没有私钥，通过蓝牙绑定
        DLog(@"添加T1门锁，不存在私钥，通过蓝牙绑定");
        [self bindDoorLock];
    }else {//有私钥，要查家庭的绑定关系
        DLog(@"添加T1门锁，存在私钥，检查是否服务器是否存在绑定关系");
        [self checkLockBindingelationship];
    }
}


/**
 查询是否有在线的主机
 */
- (void)checkOnlineEmbHubCallback:(HMBluetoothCmdCallback)callback {
    
   __block BOOL hasSupportT1Ember = NO;
    
    GetHubStatusCmd *hubStatusCmd = [GetHubStatusCmd object];
    hubStatusCmd.familyId = userAccout().familyId;
    hubStatusCmd.userId = userAccout().userId;
    sendCmd(hubStatusCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {//查询是否有在线的主机成功
            NSArray *onlineStatusArr = returnDic[@"onlineStatus"];
            if ([onlineStatusArr isKindOfClass:[NSArray class]]){//查询是否有在线返回数据格式正确
                DLog(@"添加T1门锁，查询是否有在线的主机，返回数据正确%@",returnDic);

                for (NSDictionary *itemDic in onlineStatusArr)
                {
                    HMHubOnlineModel * hubOnlineModel = [[HMHubOnlineModel alloc] init];
                    hubOnlineModel.familyId = userAccout().familyId;
                    hubOnlineModel.uid = [itemDic objectForKey:@"uid"];
                    hubOnlineModel.online = [[itemDic objectForKey:@"online"] intValue];
                    [hubOnlineModel insertObject];
                    
                    if ([itemDic[@"online"] intValue] == 1) {//有在线主机,先让蓝牙进行组网状态 ,再通知通知网关开启组网
                        DLog(@"添加T1门锁，查询是否有在线的主机，有在线的主机，让门锁开启组网");
                        if(isSppportT1EmberHub(hubOnlineModel.uid)){
                            DLog(@"添加T1门锁，查询是否有在线的主机，有在线的主机uid = %@，并且支持t1门锁,让门锁开启组网",hubOnlineModel.uid);
                            hasSupportT1Ember = YES;
                            callback(HMBluetoothLockStatusLockHasOnlineEmberHub,nil);
                            return;
                        }else {
                            DLog(@"添加T1门锁，查询是否有在线的主机，有在线的主机uid = %@，但是不支持支持t1门锁,不让门锁开启组网",hubOnlineModel.uid);
                        };
                    }else {
                        if (isSppportT1EmberHub(hubOnlineModel.uid)) {
                           hasSupportT1Ember = YES;
                        }
                    }
                }
                
                [HMBaseAPI postNotification:kNOTIFICATION_CHECKHUBONLINE object:nil];

                if(onlineStatusArr.count){
                    if (hasSupportT1Ember) {
                        DLog(@"添加T1门锁，查询是否有在线的主机，没有在线的主机");
                        callback(HMBluetoothLockStatusLockHasOnOffEmberHub,nil);//走到这里认为没有在线网关，要走单独绑定网关
                    }else {
                        DLog(@"添加T1门锁，查询是否有在线的主机，没有Ember主机");
                        callback(HMBluetoothLockStatusLockHasNoEmberHub,nil);
                    }
                   
                }else {
                    DLog(@"添加T1门锁，查询是否有在线的主机，没有Ember主机");
                    callback(HMBluetoothLockStatusLockHasNoEmberHub,nil);
                }
                
            }else {//查询是否有在线返回数据格式错误
                DLog(@"添加T1门锁，查询是否有在线的主机，返回数据格式不对%@",returnDic);
                callback(HMBluetoothLockStatusError,nil);
            }
        }else {//查询是否有在线的主机失败
            DLog(@"添加T1门锁，查询是否有在线的主机，查询失败");
            callback(HMBluetoothLockStatusError,nil);
        }
    });
}


/**
 让门锁开启组网状态
 */
- (void)lockOpenZigbee {
    [self zigbeeNetworkControlNWKCmd:0 callback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
        if (payload) {
            int status = [[payload objectForKey:@"status"] intValue];
            if (status == 0) {//开启组网成功,要通知主机开组网
                DLog(@"添加T1门锁，让门锁开启组网状态，开启成功");
                [self handleAddLockCallback:HMBluetoothLockStatusLockOpenZigbeeSuccess payload:nil];
                
            }else {//开启组网失败
                DLog(@"添加T1门锁，让门锁开启组网状态，蓝牙返回开启失败");
                [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
            }
        }else {//开启组网失败
            DLog(@"添加T1门锁，让门锁开启组网状态，开启失败");
            [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
        }
    }];
}


/**
 查询门锁的绑定关系
 */
- (void)checkLockBindingelationship {
    
    OrviboLockQueryBindingCmd * cmd = [OrviboLockQueryBindingCmd object];
    cmd.uid = self.currentHandleLockBleMac;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {//查询成功
            //有绑定关系，要判断是否是当前的家庭
                NSString * familyId = [returnDic objectForKey:@"familyId"];
                if (familyId.length) {
                    if ([familyId isEqualToString: userAccout().familyId]) {//有绑定关系，并且是当前家庭
                        DLog(@"添加T1门锁， 查询门锁的绑定关系，有绑定关系，并且是当前家庭");
                        [self handleAddLockCallback:HMBluetoothLockStatusLockBindSelfFamily payload:nil];
                    }else {//有绑定关系，但是不是当前家庭
                        DLog(@"添加T1门锁， 查询门锁的绑定关系，有绑定关系，但是不是当前家庭");
                        [self handleAddLockCallback:HMBluetoothLockStatusLockBindOtherFamily payload:nil];
                    }
                    
                }else {
                    DLog(@"添加T1门锁， 查询门锁的绑定关系，没有绑定关系");
                    [self handleAddLockCallback:HMBluetoothLockStatusLockBindNoneFamily payload:nil];
                }
        }else {//查询失败
            DLog(@"添加T1门锁， 查询门锁的绑定关系，有绑定关系，查询失败");
            [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
        }
    });
}

/**
 绑定门锁
 */
- (void)bindDoorLock {
    if(self.lockModel) {//当前有门锁信息，先发绑定命令，再绑定
        DLog(@"添加T1门锁， 绑定门锁，当前有门锁的信息");
        [self unbindDoorLockFromServer];
    }else {//当前没有门锁信息
        DLog(@"添加T1门锁， 绑定门锁，当前没有门锁的信息");
        [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
    }
}
/**
 从服务器解绑门锁
 */
- (void)unbindDoorLockFromServer {
    DeviceUnbindCmd *deviceUnbind = [DeviceUnbindCmd object];
    deviceUnbind.uid = self.lockModel.zigbeeMAC;
    sendCmd(deviceUnbind, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {//解绑成功,要绑定设备
            DLog(@"添加T1门锁， 从服务器解绑门锁，解锁成功");
            [self bindDoorLockToServer];
        }else {//解绑失败
            DLog(@"添加T1门锁， 从服务器解绑门锁，解锁失败");
            [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
        }
    });
}

/**
 绑定门锁到服务器
 */
- (void)bindDoorLockToServer {
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    if (self.currentHandleLockBleMac.length) {
        [payload setObject:self.currentHandleLockBleMac forKey:@"blueExtAddr"];
    }
    if (self.lockModel.mcuVerion.length) {
        [payload setObject:self.lockModel.mcuVerion forKey:@"mcuVersion"];
    }
    if (self.lockModel.bleVersion.length) {
        [payload setObject:self.lockModel.bleVersion forKey:@"bleVersion"];
    }
    if(self.lockModel.ModelID.length) {
        [payload setObject:self.lockModel.ModelID forKey:@"modelId"];
    }
    [payload setObject:@(self.lockModel.nwkStatus) forKey:@"nwkStatus"];
    [payload setObject:@(self.lockModel.paried) forKey:@"isPreset"];
    
    DeviceBindCmd * cmd  = [[DeviceBindCmd alloc] init];
    cmd.bindUID = [self.lockModel.zigbeeMAC lowercaseString];
    cmd.deviceBindPayload = payload;
    cmd.deviceType = [NSString stringWithFormat:@"%d",KDeviceTypeOrviboLock];
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {//绑定成功,要重新生成门锁秘钥
            DLog(@"添加T1门锁， 绑定门锁到服务器，绑定成功");
            
            NSString *uid = [returnDic objectForKey:@"uid"];
            NSDictionary * deviceDic = [returnDic objectForKey:@"device"];
            HMDevice * device = [HMDevice objectFromDictionary:deviceDic];
            if (device.uid.length == 0) {
                device.uid = uid;
            }

            HMGateway * gateWay = [HMGateway bluetoothLockGateWayWithbleMac:self.currentHandleLockBleMac];
            [gateWay deleteObject];
            HMUserGatewayBind * userGateWay = [HMUserGatewayBind bindWithUid:self.currentHandleLockBleMac];
            [userGateWay deleteObject];
            HMDevice * oldDevice = [HMDevice lockWithBlueMacId:self.currentHandleLockBleMac];
            [oldDevice deleteObject];
            [HMDoorUserBind deleteAllObjectWithExtAddr:device.extAddr];
            
            
            self.privateKey = nil;
            
            if (!device.model) {
                device.model = [returnDic objectForKey:@"model"];
            }
            NSString * gatewayUID  = [deviceDic objectForKey:@"gatewayUID"];
            if (isEmberHub(gatewayUID)) {//如果是网关的uid，要把门锁的uid换成网关的uid
                device.uid = gatewayUID;
            }
            [device insertObject];
            self.device = device;
            [HMDoorUserBind deleteAllObjectWithExtAddr:device.extAddr];

            NSDictionary * deviceStatus = [returnDic objectForKey:@"deviceStatus"];
            HMDeviceStatus * status = [HMDeviceStatus objectFromDictionary:deviceStatus];
            [status insertObject];
            
            NSDictionary * gatewayDic = [returnDic objectForKey:@"gateway"];
            if (gatewayDic) {
                HMGateway * gateway = [HMGateway objectFromDictionary:gatewayDic];
                [gateway insertObject];
            }
            
            NSDictionary * userGatewayBindDic = [returnDic objectForKey:@"userGatewayBind"];
            if (userGatewayBindDic) {
                HMUserGatewayBind * userGatewayBind = [HMUserGatewayBind objectFromDictionary:userGatewayBindDic];
                [userGatewayBind insertObject];
            }
            
            addDeviceBind(device.uid, device.model);

            [self getPrivatekeyCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
                if (payload) {//获取私钥成功
                    int status = [[payload objectForKey:@"status"] intValue];
                    if (status == 0) {
                        NSString * privateKey = [payload objectForKey:@"privateKey"];
                        if (privateKey.length) {
                            DLog(@"添加T1门锁， 绑定门锁到服务器，绑定成功,要重新生成门锁秘钥成功%@",privateKey);
                            [self sendDoorLockPrivateToServer:privateKey];
                            
                        }else {
                            DLog(@"添加T1门锁， 绑定门锁到服务器，绑定成功,要重新生成门锁秘钥门锁返回失败%@",payload);
                            [self privateKeySaveFailedDeleteBindedDevice];
                            [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
                        }
                    }else {
                        DLog(@"添加T1门锁， 绑定门锁到服务器，绑定成功,要重新生成门锁秘钥门锁返回值不为0");
                        [self privateKeySaveFailedDeleteBindedDevice];
                        [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
                    }
                    
                    
                }else {//获取私钥失败
                    DLog(@"添加T1门锁， 绑定门锁到服务器，绑定成功要重新生成门锁秘钥 失败");
                    [self privateKeySaveFailedDeleteBindedDevice];
                    [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
                }
            }];
            
        }else {//绑定失败
            DLog(@"添加T1门锁， 绑定门锁到服务器，绑定成功");
            [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
            
        }
    });
    
}


/**
 发送门锁私钥到服务器
 */
- (void)sendDoorLockPrivateToServer:(NSString *)privateKey {
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    if (privateKey.length) {
        [payload setObject:privateKey forKey:@"password"];
    }
    DLog(@"添加T1门锁， 发送门锁私钥到服务器，门锁信息 %@",payload);
    UpdateGatewayPassword * cmd  = [[UpdateGatewayPassword alloc] init];
    cmd.uid = self.lockModel.zigbeeMAC;
    cmd.password = privateKey;
    cmd.blueExtAddr = self.currentHandleLockBleMac;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {//发送门锁私钥到服务器成功
            DLog(@"添加T1门锁， 发送门锁私钥到服务器，发送成功");
            NSDictionary * gatewayDic = [returnDic objectForKey:@"gateway"];
            HMGateway * gateWay = [HMGateway objectFromDictionary:gatewayDic];
            [gateWay insertObject];
            NSDictionary * userGatewayBind = [returnDic objectForKey:@"userGatewayBind"];
            HMUserGatewayBind * userBind = [HMUserGatewayBind objectFromDictionary:userGatewayBind];
            [userBind insertObject];
            [self handleAddLockCallback:HMBluetoothLockStatusLockAddToServerSuccess payload:nil];
            [self updateLockVersionInfo];
            [self timeSynchronizationCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
                if (payload) {
                    int status = [[payload objectForKey:@"status"] intValue];
                    if (status == 0) {
                        DLog(@"添加T1门锁， 发送门锁私钥到服务器，发送成功,同步时间成功");
                    }else {
                        DLog(@"添加T1门锁， 发送门锁私钥到服务器，发送成功,同步时间门锁返回不为0");
                    }
                }else {
                    DLog(@"添加T1门锁， 发送门锁私钥到服务器，发送成功,同步时间门锁时间失败");
                }
            }];
            
        }else {//发送门锁私钥到服务器失败
            DLog(@"添加T1门锁， 发送门锁私钥到服务器，发送失败 %d",returnValue);
            [self privateKeySaveFailedDeleteBindedDevice];
            [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
            
        }
    });
}


- (void)privateKeySaveFailedDeleteBindedDevice {
    DeleteDeviceCmd *dlCmd = deleteCmdWithDevice(self.device);
    sendCmd(dlCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {//发送门锁私钥到服务器成功
            DLog(@"添加T1门锁， 生成或者上传门锁私钥失败，删除绑定关系成功");
            cleanDeviceDataWithDevice(self.device);
        }else {
            DLog(@"添加T1门锁， 生成或者上传门锁私钥失败，删除绑定关系失败%d",returnValue);
            
        }
            
    });
    

}


/**
 调用添加设备的回调

 @param errorCode errorCode
 @param payload payload
 */
- (void)handleAddLockCallback:(HMBluetoothLockStatusCode)errorCode payload:(NSDictionary *)payload {
    if (self.addLockCallBack) {
        self.addLockCallBack(errorCode, payload);
    }
}


#pragma mark -
#pragma mark - 蓝牙相关的API

/**
 获取门锁的zigbee门锁状态
 
 @param callback
 */
- (void)getNetworkInformationOfDoorLockCallback:(HMBluetoothCmdCallback)callback {
    
}


/**
 清除私钥
 
 @param callback
 */
- (void)cleanPrSivateKeyCallback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_CleanPrSivateKey)};
    cmd.EncryptKey = 0;
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}


/**
 设备握手命令，主要判断密钥是否正确
 
 @param callback
 */
- (void)deviceHandshakeCallback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_Handshake)};
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}


/**
 获取私钥
 
 @param callback
 */
- (void)getPrivatekeyCallback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_GetPrSivateKey)};
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}


/**
 用户身份验证
 
 @param callback
 */
- (void)userAuthenticationCallback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_IdentityVerification)};
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}


/**
 时间同步命令
 
 @param callback
 */
- (void)timeSynchronizationCallback:(HMBluetoothCmdCallback)callback {
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    [payload setObject:@(HMBluetoothLockCmdType_TimeSynchronization) forKey:@"cmd"];
    NSUInteger time =[[NSDate date] timeIntervalSince1970];
    [payload setObject:@(time) forKey:@"time"];
    [payload setObject:@(0) forKey:@"zoneYear"];
    [payload setObject:@(0) forKey:@"zoneOffset"];
    [payload setObject:@(0) forKey:@"zoneDst"];
    [payload setObject:@(0) forKey:@"dstStartTime"];
    [payload setObject:@(0) forKey:@"dstEndTime"];
    cmd.payload = payload;
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}


/**
 获取设备信息
 
 @param callback
 */
- (void)getEquipmentInformationCallback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_GettingDeviceInformation)};
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}


/**
 Zigbee组网控制命令(组网 or 清网)
 
 
 @param nwkcmd 0 : 操作成功，开启组网  1 : 结束组网  2 : 清除组网
 @param callback
 */
- (void)zigbeeNetworkControlNWKCmd:(int)nwkcmd
                          callback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_ZigBeeNetworkingControl),@"nwkCmd":@(nwkcmd)};
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}


/**
 获取Zigbee组网状态命令
 
 
 @param callback
 */
- (void)gettingTheStateOfZigbeeNetworkingCallback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_GetZigbeeNetworkingStatus)};
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}



/**
 获取成员信息
 
 @param userId 仅在希望查询某个特定成员时传入 0为查询全部
 @param callback
 */
- (void)getMemberInformationUserId:(int)userId callback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    if (userId == 0) {
        cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_GetMembernformation)};
    }else {
        cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_GetMembernformation),@"userID":@(userId)};
    }
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}


/**
 增加成员
 
 @param callback
 */
- (void)addMembersCallback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_AddMember)};
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}


/**
 删除成员
 
 @param callback
 */
- (void)deleteMembersUserId:(int)userId callback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_DeleteMember),@"userID":@(userId)};
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}

/**
  添加用户验证信息

 @param userId 添加用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 @param value 表示密码，如果 item 是“pwdx” 格式时起作用，是“fpx”格式 传nil
 @param callback
 */
- (void)addingUserAuthenticationUserId:(int)userId item:(NSString *)item value:(NSString *)value callback:(HMBluetoothCmdCallback)callback {
    
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@(userId) forKey:@"userId"];
    [dict setObject:@(HMBluetoothLockCmdType_AddUserAuthenticationInformation) forKey:@"cmd"];
    if (item.length) {
        [dict setObject:item forKey:@"item"];
    }
    if (value.length) {
        [dict setObject:value forKey:@"value"];
    }
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    cmd.payload = dict;
    [self.dataCenter sendCmd:cmd];
}


/**
 删除用户验证信息
 
 @param userId 删除用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 */
- (void)deleteUserAuthenticationUserId:(int)userId item:(NSString *)item callback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@(userId) forKey:@"userId"];
    [dict setObject:@(HMBluetoothLockCmdType_DeleteUserAuthenticationInformation) forKey:@"cmd"];
    if (item.length) {
        [dict setObject:item forKey:@"item"];
    }
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    cmd.payload = dict;
    [self.dataCenter sendCmd:cmd];
}


/**
 取消指纹录入

 @param userId 取消指纹录入用户id
 @param callback
 */
- (void)cancellationOfFingerprintEntryUserId:(int)userId callback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_CancelFingerprintInput),@"userID":@(userId)};
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}


/**
 启动热点扫描
 
 @param callback
 */
- (void)hotSpotScanCallback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    cmd.payload = @{@"cmd":@(HMBluetoothLockCmdType_HotSpotScan)};
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    [self.dataCenter sendCmd:cmd];
}


/**
 热点信息传输
 
 @param seq wifi的序列号
 @param pwd wifi的密码
 @param callback
 */
- (void)hotInformationTransmissionSeq:(NSInteger)seq pwd:(NSString *)pwd callback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@(HMBluetoothLockCmdType_HotInformationTransmission) forKey:@"cmd"];
    [dict setObject:@(seq) forKey:@"seq"];
    if (pwd.length) {
        [dict setObject:pwd forKey:@"pwd"];
    }else {
        [dict setObject:@"" forKey:@"pwd"];

    }
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    cmd.payload = dict;
    [self.dataCenter sendCmd:cmd];
}


/**
 读门锁里面的开锁记录
 
 @param time 读该时间之后的记录
 @param callback
 */
- (void)readOpenDoorRecord:(int)time callback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@(HMBluetoothLockCmdType_ReadOpenDoorReacord) forKey:@"cmd"];
    [dict setObject:@(time) forKey:@"time"];
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    cmd.payload = dict;
    [self.dataCenter sendCmd:cmd];
}


/// 调用上传固件回调
/// @param errorCode errorCode
/// @param payload payload
- (void)handleFirmwareTransmissionCallBack:(HMBluetoothLockStatusCode)errorCode payload:(NSDictionary *)payload {
    [self setFirmwareUpdate:NO];
    if (self.firmwareTransmissionCallBack) {
        self.firmwareTransmissionCallBack(errorCode, payload);
        self.firmwareTransmissionCallBack = nil;
    }
}

- (void)setFirmwareUpdate:(BOOL)firmwareUpdate {
    _firmwareUpdate = firmwareUpdate;
}
- (BOOL)getFirmwareUpdate {
    return _firmwareUpdate;
}

- (FirmwareUpdateStatus)firmwareUpdateStatus {
    return _updateStatus;
}

- (int)firmwareUpdateReconnectBluetoothLeftSecond {
    return _leftSecond;
}

- (void)setUpdateStatus:(FirmwareUpdateStatus)updateStatus {
    _updateStatus = updateStatus;
    DLog(@"固件升级改变状态 %d",updateStatus);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_FIRMWAREDATATRANSMISSIONSTATUSCHANGE object:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeUpdateStausToNormal) object:nil];
    if (updateStatus == FirmwareUpdateStatusUpdateSuccess ||
        updateStatus == FirmwareUpdateStatusUpdateFail ||
        updateStatus == FirmwareUpdateStatusUpdateDeviceInfoFail ||
        updateStatus == FirmwareUpdateStatusConnectLockFail ||
        updateStatus == FirmwareUpdateStatusTransmissionFail) {
        [self performSelector:@selector(changeUpdateStausToNormal) withObject:nil afterDelay:3];
    }
}

- (void)changeUpdateStausToNormal {
    _updateStatus = FirmwareUpdateStatusNormal;
    self.updateDevice = nil;
}

- (void)resetFirmwareUpdateData {
    self.firmwareTransmissionLenth = 0;
    self.everyFirmwareTransmissionLenth = 0;
    self.currentFirmwareTransmissionSerial = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_BLUETOOTH_UPDATEDATA object:nil];
}

- (void)startFirmwareUpdateDevice:(HMDevice *)device filesArrays:(NSArray<HMFirmwareModel *>*)fileArray {
    self.updateDevice = device;
    self.updateFilesArray = [NSMutableArray arrayWithArray:fileArray];
    [self startFirmwareUpdateOneByOne];
}

/**
 获取当前正在升级的设备，没有升级时为nil
 
 @return
 */
- (HMDevice *)getUpdatingDevice {
    return self.updateDevice;
}

- (void)startFirmwareUpdateOneByOne {
    HMFirmwareModel *firmware = nil;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"self.type = %@",@"softwareVersion"];//查找蓝牙
    NSArray * array = [self.updateFilesArray filteredArrayUsingPredicate:predicate];
    if (array.count) {
        firmware = array.firstObject;
    }
    
    predicate = [NSPredicate predicateWithFormat:@"self.type = %@",@"systemVersion"];//查找mcu，这里的逻辑是先升级mcu 再升级蓝牙
    array = [self.updateFilesArray filteredArrayUsingPredicate:predicate];
    if (array.count) {
        firmware = array.firstObject;
    }
    
    predicate = [NSPredicate predicateWithFormat:@"self.type = %@",@"12"];//STM32固件
    array = [self.updateFilesArray filteredArrayUsingPredicate:predicate];
    if (array.count) {
        firmware = array.firstObject;
    }
    
    DLog(@"下载固件成功，开始上传固件%@",firmware.type);
    
    NSString * string = [[NSUserDefaults standardUserDefaults] objectForKey:@"T1LockUpdateVersion"];
    if (string.length) {
        firmware.NewVersion = string;
    }
    
    [self startFirmwareUpdatePath:firmware.filePath type:1 version:firmware.NewVersion callback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
        if (errorCode == HMBluetoothLockStatusSuccess) {
            DLog(@"下载固件成功，开始上传固件%@,传输成功",firmware.type);
            [self.updateFilesArray removeObject:firmware];
            self.updateStatus = FirmwareUpdateStatusSearchBluetooth;
            [self performSelector:@selector(firmwareUpdateSuccess) withObject:nil afterDelay:10];//10秒之后再去搜索
            [self startUpdateTimer];
        }else {
            if(errorCode == HMBluetoothLockStatusUpdateDeviceInfoFail){
                self.updateStatus = FirmwareUpdateStatusUpdateDeviceInfoFail;
            }else if(errorCode ==  HMBluetoothLockStatusGetDeviceInfoFail){
                self.updateStatus = FirmwareUpdateStatusGetDeviceInfoFail;
            }else{
                self.updateStatus = FirmwareUpdateStatusTransmissionFail;
            }
            [self stopUpdateTimer];
            DLog(@"下载固件成功，开始上传固件%@,传输失败",firmware.type);
        }
    }];
}
- (void)startUpdateTimer {
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateLeftSecond) userInfo:nil repeats:YES];
    [self.updateTimer fire];
}

- (void)updateLeftSecond {
    if (self.leftSecond == 0) {
        self.updateStatus = FirmwareUpdateStatusConnectLockFail;
        [self stopUpdateTimer];
        return;
    }
    self.leftSecond --;
    self.updateStatus = FirmwareUpdateStatusSearchBluetooth;
}

- (void)stopUpdateTimer {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    self.leftSecond = reconnectBlutoothSecond;
}

- (void)firmwareUpdateSuccess {
    //这里加一个判断
    if(![HMBluetoothLockAPI  bluetoothOpen]) {
        DLog(@"下载固件成功，开始循环扫描蓝牙失败，因为蓝牙没打开");
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_T1UPLOADBLURTOOTHBREAK object:nil];
        [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusGetDeviceInfoFail payload:nil];
        return;
    }
    if(self.updateStatus == FirmwareUpdateStatusConnectLockFail) {
        DLog(@"下载固件成功，开始循环扫描蓝牙XXXXX");
        return;
    }
    DLog(@"下载固件成功，开始循环扫描蓝牙");
    [HMBluetoothLockAPI scanPeripheralBlueMac:self.updateDevice.blueExtAddr callback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
        if(errorCode == HMBluetoothLockStatusSuccess){//搜到门锁，添加门锁，判断门锁是否有私钥
            DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，看看还有没有要升级的固件");
            if (self.updateFilesArray.count == 0) {
                DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，看看还有没有要升级的固件，没有要升级的固件了，查询设备信息");
                [self performSelector:@selector(checkT1Version) withObject:nil afterDelay:0.5];
            }else {
                DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，看看还有没有要升级的固件，还有要升级的固件了继续传递");
                [self startFirmwareUpdateOneByOne];
            }
            
        }else {
            DLog(@"下载固件成功，开始循环扫描蓝牙，没有扫描到，接着扫描");
            [self performSelector:@selector(checkT1VersionOnceAgain) withObject:nil afterDelay:5];
        }
    }];
}


- (void)updateLockVersionInfo {
    
    NSString * bleVersion = self.lockModel.bleVersion;
    NSString * mcuVerion = self.lockModel.mcuVerion;
    NSString * zigbeeVersion = self.lockModel.zigbeeVersion;
    NSString * hardwareVersion = self.lockModel.hardwareVersion;
    
    NSString * extAddr = @"";
    if (self.updateDevice) {
        extAddr = self.updateDevice.extAddr;
    }else if(self.addSuccessDevice){
        extAddr = self.addSuccessDevice.extAddr;
    }
    
    FirmwareVersionUploadCmd * cmd = [FirmwareVersionUploadCmd object];
    cmd.uid = self.currentHandleLockBleMac;
    cmd.hardwareVersion = zigbeeVersion;
    cmd.softwareVersion = bleVersion;
    cmd.coordinatorVersion = hardwareVersion;
    cmd.systemVersion = mcuVerion;
    NSString * string = [[NSUserDefaults standardUserDefaults] objectForKey:@"T1LockUpdateVersion"];
    if (string.length) {
        cmd.systemVersion = @"1.6.2.190";
    }
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if(returnValue == KReturnValueSuccess) {
            DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，开始获取设备信息，获取设备信息成功，开始上传版本号,上传成功");
            HMGateway * gateWay1 = [HMGateway objectWithUid:extAddr];
            gateWay1.hardwareVersion = cmd.hardwareVersion;
            gateWay1.softwareVersion = cmd.softwareVersion;
            gateWay1.coordinatorVersion = cmd.coordinatorVersion;
            gateWay1.systemVersion = cmd.systemVersion;
            [gateWay1 insertObject];
            
            HMGateway * gateWay2 = [HMGateway objectWithUid:self.currentHandleLockBleMac];
            gateWay2.hardwareVersion = cmd.hardwareVersion;
            gateWay2.softwareVersion = cmd.softwareVersion;
            gateWay2.coordinatorVersion = cmd.coordinatorVersion;
            gateWay2.systemVersion = cmd.systemVersion;
            [gateWay2 insertObject];
            [self stopUpdateTimer];
            self.updateStatus = FirmwareUpdateStatusUpdateSuccess;
            
        }else {
            DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，开始获取设备信息，获取设备信息成功，开始上传版本号,上传失败%d",returnValue);
            [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusUpdateDeviceInfoFail payload:nil];
        }
    });
}

- (void)checkT1Version {
    self.updateStatus = FirmwareUpdateStatusGetDeviceInfo;
    [HMBluetoothLockAPI getEquipmentInformationCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
        if (errorCode == HMBluetoothLockStatusSuccess) {
            int status = [[payload objectForKey:@"status"] intValue];
            if (status == 0) {
                NSArray * allKeys = [payload allKeys];
                if ([allKeys containsObject:@"zigbeeVersion"]) {
                    DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，开始获取设备信息，获取设备信息成功，开始上传版本号");
                    HMBluetoothLockModel * lockModel = [[HMBluetoothLockModel alloc] init];
                    lockModel.ModelID= [payload objectForKey:@"ModelID"];
                    lockModel.hardwareVersion = [payload objectForKey:@"hardwareVersion"];
                    lockModel.bleMAC = [payload objectForKey:@"bleMAC"];
                    lockModel.mcuUniqueID = [payload objectForKey:@"mcuUniqueID"];
                    lockModel.zigbeeMAC = [[payload objectForKey:@"zigbeeMAC"] lowercaseString];
                    lockModel.bleVersion = [payload objectForKey:@"bleVersion"];
                    lockModel.mcuVerion = [payload objectForKey:@"mcuVerion"];
                    lockModel.zigbeeVersion = [payload objectForKey:@"zigbeeVersion"];
                    
                    [self saveLockModel:lockModel];
                    [self updateLockVersionInfo];
                }else {
                    DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，开始获取设备信息，获取设备信息门锁返回数据不对 %@",payload);
                    [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusGetDeviceInfoFail payload:nil];
                }
                
            }else {
                DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，开始获取设备信息，获取设备信息门锁返回状态为%d",status);
                [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusGetDeviceInfoFail payload:nil];
            }
        }else {
            DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，开始获取设备信息，获取设备信息蓝牙出现了问题，这里要重新连接再去获取一下");
            [self performSelector:@selector(checkT1VersionOnceAgain) withObject:nil afterDelay:1];
        }
    }];
}

- (void)checkT1VersionOnceAgain {
    if ([self bluetoothConnectToBlueMac:self.updateDevice.blueExtAddr]) {
        DLog(@"再次获取设备信息时，蓝牙连接，直接发送数据");
        [self getDeviceInfoThenUploadServer];
    }else {
        DLog(@"再次获取设备信息时，蓝牙没有，先扫描");
        [self scanPeripheralBlueMac:self.updateDevice.blueExtAddr callback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
            if (errorCode == HMBluetoothLockStatusSuccess) {
                DLog(@"再次获取设备信息时，蓝牙没有，先扫描成功，上传设备信息");
                [self getDeviceInfoThenUploadServer];
            }else {
                [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusGetDeviceInfoFail payload:nil];
            }
        }];
    }
    
    
}

- (void)getDeviceInfoThenUploadServer {
    [HMBluetoothLockAPI getEquipmentInformationCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
        if (errorCode == HMBluetoothLockStatusSuccess) {
            int status = [[payload objectForKey:@"status"] intValue];
            if (status == 0) {
                NSArray * allKeys = [payload allKeys];
                if ([allKeys containsObject:@"zigbeeVersion"]) {
                    DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，再次获取设备信息，获取设备信息成功，开始上传版本号");
                    HMBluetoothLockModel * lockModel = [[HMBluetoothLockModel alloc] init];
                    lockModel.ModelID= [payload objectForKey:@"ModelID"];
                    lockModel.hardwareVersion = [payload objectForKey:@"hardwareVersion"];
                    lockModel.bleMAC = [payload objectForKey:@"bleMAC"];
                    lockModel.mcuUniqueID = [payload objectForKey:@"mcuUniqueID"];
                    lockModel.zigbeeMAC = [[payload objectForKey:@"zigbeeMAC"] lowercaseString];
                    lockModel.bleVersion = [payload objectForKey:@"bleVersion"];
                    lockModel.mcuVerion = [payload objectForKey:@"mcuVerion"];
                    lockModel.zigbeeVersion = [payload objectForKey:@"zigbeeVersion"];
                    
                    [self saveLockModel:lockModel];
                    [self updateLockVersionInfo];
                }else {
                    DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，再次获取设备信息，获取设备信息门锁返回数据不对 %@",payload);
                    [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusGetDeviceInfoFail payload:nil];
                }
                
            }else {
                DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，再次获取设备信息，获取设备信息门锁返回状态为%d",status);
                [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusGetDeviceInfoFail payload:nil];
            }
        }else {
            DLog(@"下载固件成功，开始循环扫描蓝牙，扫描成功，再次获取设备信息，获取设备信息蓝牙出现了问题");
            [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusGetDeviceInfoFail payload:nil];
        }
    }];
    
}

- (void)startFirmwareUpdatePath:(NSURL *)path type:(int)type version:(NSString *)version callback:(HMBluetoothCmdCallback)callback {
    if(path.absoluteString.length == 0) {
        [self handleAddLockCallback:HMBluetoothLockStatusError payload:nil];
        DLog(@"开始上传固件成功，开始传固件,路径有问题 %@",path);
        return;
    }
    [self resetFirmwareUpdateData];
    [self setFirmwareUpdate:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothUploadData:) name:kNOTIFICATION_BLUETOOTH_UPDATEDATA object:nil];
    self.currentFirmwareTransmissionPath = path;
    self.firmwareTransmissionCallBack = callback;
    self.updateStatus = FirmwareUpdateStatusTransmission;
    [self bluetoothStartFirmwareUpdatePath:path type:type version:version callback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
        if(errorCode == HMBluetoothLockStatusSuccess){
            if (payload) {
                int status = [[payload objectForKey:@"status"] intValue];
                if (status == 0) {
                    DLog(@"开始上传固件成功，开始传固件");
                    int lastReceSize = 0;
                    NSArray * payloadAllKey = [payload allKeys];
                    NSString * tempVersion = [payload objectForKey:@"version"];
                    if ([tempVersion isEqualToString: version]) {//版本号一致
                        if ([payloadAllKey containsObject:@"lastReceSize"]) {//说明是断点续传
                            lastReceSize = [[payload objectForKey:@"lastReceSize"] intValue];
                            NSData * firmwareData = [NSData dataWithContentsOfURL:path];
                            NSData * subData = [firmwareData subdataWithRange:NSMakeRange(0, lastReceSize)];
                            int crc = [subData hm_crc32];
                            int localCrc = [[payload objectForKey:@"localCrc"] intValue];
                            if (localCrc == crc) {//校验码一致
                                DLog(@"开始上传固件成功，开始传固件,是断点续传，并且校验码一致");
                                self.firmwareTransmissionLenth = lastReceSize;//记录已经上传的长度
                                if (firmwareData.length > 0) {
                                   float percent = (lastReceSize*1.0)/firmwareData.length;
                                    self.transmissionPercent = percent * 100;
                                }
                                [self firmwareDataTransmissionPath:self.currentFirmwareTransmissionPath lastReceSize:self.firmwareTransmissionLenth callback:self.firmwareTransmissionCallBack];
                            }else {//校验码不一致，先发一个终止命令，再启动
                                DLog(@"开始上传固件成功，开始传固件,是断点续传，并且校验码不一致，要先发终止命令在 开始上传");
                                [self cancelUpdate];
                            }
                        }else {//上次升级成功，但是更新设备信息失败，这次就直接更新设备信息
                            DLog(@"开始上传固件成功，开始传固件,不是断点续传，但是版本号一致，要延时6s重新更新设备信息");
                            [self performSelector:@selector(checkT1Version) withObject:nil afterDelay:6];
                        }
                    }else {//版本号不一致，直接升级
                        DLog(@"开始上传固件成功，开始传固件,版本号不一致，直接上传");
                        self.firmwareTransmissionLenth = lastReceSize;//记录已经上传的长度
                        [self firmwareDataTransmissionPath:self.currentFirmwareTransmissionPath lastReceSize:self.firmwareTransmissionLenth callback:self.firmwareTransmissionCallBack];
                    }
                    
                }else if(status == 0x01) {
                    DLog(@"开始上传固件失败，异常");
                    [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
                    
                }else if(status == 0xe3) {
                    DLog(@"开始上传固件失败，升级文件参数异常");
                    [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
                }else {
                    DLog(@"开始上传固件失败，门锁返回错误");
                    [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
                }
            }else {
                DLog(@"开始上传固件失败，paload错误");
                [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
            }
        }else {
            DLog(@"开始上传固件失败，未知错误");
            [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
        }
    }];
}

- (void)cancelUpdate {

    [self terminateFirmwareUpgradeCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
        if (errorCode == HMBluetoothLockStatusSuccess) {
            if (payload) {
                int status = [[payload objectForKey:@"status"] intValue];
                if (status == 0) {
                    DLog(@"传送固件总数据 < 上次已传长度，要终止升级,成功");
                    [self startFirmwareUpdateDevice:self.updateDevice filesArrays:self.updateFilesArray];
                }else if(status == 0x01) {
                    DLog(@"传送固件总数据 < 上次已传长度，要终止升级,失败");
                    [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];

                }else if(status == 0xe0) {
                    DLog(@"传送固件总数据 < 上次已传长度，要终止升级,写EEPROM失败");
                    [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
                }else if(status == 0xe2){
                    DLog(@"传送固件总数据 < 上次已传长度，要终止升级,写FLASH失败");
                    [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
                }else {
                    DLog(@"传送固件总数据 < 上次已传长度，要终止升级,错误码无法识别");
                    [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
                }
            }else {
                DLog(@"传送固件总数据 < 上次已传长度，要终止升级,payLoad错误");
                [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];

            }
        }else {
            DLog(@"传送固件总数据 < 上次已传长度，要终止升级,蓝牙错误");
            [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];

        }
    }];    
}


/**
 启动固件升级

 @param path 路径
 @param type type
 @param version 版本号
 @param callback callback
 */
- (void)bluetoothStartFirmwareUpdatePath:(NSURL *)path type:(int)type version:(NSString *)version callback:(HMBluetoothCmdCallback)callback {
    NSData * firmwareData = [NSData dataWithContentsOfURL:path];
    if (firmwareData.length == 0) {
        DLog(@"开始上传固件成功，开始传固件,firmwareData 数据有问题");
        [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
        return;
    }
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@(HMBluetoothLockCmdType_StartFirmwareUpgrade) forKey:@"cmd"];
    [dict setObject:version forKey:@"version"];
    [dict setObject:@(firmwareData.length) forKey:@"fileSize"];
    int crc = [firmwareData hm_crc32];
    [dict setObject:@(crc) forKey:@"fileCRC"];
    [dict setObject:@(type) forKey:@"type"];
    [dict setObject:@(pktHexSize) forKey:@"pktHexSize"];
    cmd.EncryptKey = [self getEncodeType];
    cmd.callback = callback;
    cmd.payload = dict;
    cmd.timeoutSeconds = 7;
    [self.dataCenter sendCmd:cmd];
}

- (void)firmwareDataTransmissionPath:(NSURL *)path lastReceSize:(int)lastReceSize callback:(HMBluetoothCmdCallback)callback {
    
    [self bluetoothFirmwareDataTransmissionPath:path lastReceSize:lastReceSize callback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
        if (errorCode == HMBluetoothLockStatusSuccess) {
            int status = [[payload objectForKey:@"status"] intValue];
            if(status == 0) {//操作成功，监听写入成功的回调
                self.firmwareTransmissionLenth += self.everyFirmwareTransmissionLenth;
                self.currentFirmwareTransmissionSerial = [[payload objectForKey:@"serial"] shortValue];
                DLog(@"上传一包固件成功，记录当前已发送的长度%d，当前发送包的长度%d，当前发送成功的流水号%d",self.firmwareTransmissionLenth,self.everyFirmwareTransmissionLenth,self.currentFirmwareTransmissionSerial);
                //这里要等蓝牙上报写入成功的通知,等待时间5s
                [self performSelector:@selector(lockReportWriteFirmwareUpdateDataTimeOut) withObject:nil afterDelay:5];
            }else {
                DLog(@"上传一包固件失败，门锁返回的状态不为0,为%d，取消升级",status);
                [self resetFirmwareUpdateData];
                [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
            }
        }else {
            DLog(@"上传一包固件失败，未知错误,取消升级");
            [self resetFirmwareUpdateData];
            [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
        }
    }];
}
- (void)lockReportWriteFirmwareUpdateDataTimeOut {
    self.updateStatus = FirmwareUpdateStatusTransmissionFail;
    [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
}

- (void)bluetoothUploadData:(NSNotification *)noti {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(lockReportWriteFirmwareUpdateDataTimeOut) object:nil] ;
    NSDictionary * dict = noti.object;
    if ([dict isKindOfClass:[NSDictionary class]]) {
        int cmd = [[dict objectForKey:@"cmd"] intValue];
        if (cmd == HMBluetoothLockCmdType_FirmwareDataTransmissionUpdata) {
            int status = [[dict objectForKey:@"status"] intValue];
            if (status == 0) {
                short serial = [[dict objectForKey:@"serial"] shortValue];
                DLog(@"接收到门锁上报一包固件写入成功，流水号%d，当前保存的流水号%d",serial,self.currentFirmwareTransmissionSerial);
                if (1) {//这里先不校验
                    DLog(@"接收到门锁上报一包固件写入成功，流水号跟当前当前保存的流水号相同");
                    //判断是不是上传完成
                    NSData * allData = [NSData dataWithContentsOfURL:self.currentFirmwareTransmissionPath];
                    DLog(@"接收到门锁上报一包固件写入成功，当前以保存的长度%d,文件总长度%d",self.firmwareTransmissionLenth,allData.length);
                    if(self.firmwareTransmissionLenth < allData.length) {//还没有上传成功，接着上传
                        DLog(@"接收到门锁上报一包固件写入成功，当前以保存的长度<文件总长度,要继续发送下一包");
                        if (allData.length > 0) {
                            float percent = (self.firmwareTransmissionLenth*1.0)/allData.length;
                            self.transmissionPercent = percent * 100;
                        }
                        [self firmwareDataTransmissionPath:self.currentFirmwareTransmissionPath lastReceSize:self.firmwareTransmissionLenth callback:self.firmwareTransmissionCallBack];
                    }else if (self.firmwareTransmissionLenth == allData.length) {//说明上传成功
                        DLog(@"接收到门锁上报一包固件写入成功，当前以保存的长度=文件总长度,发送成功");
                        if (allData.length > 0) {
                            float percent = (self.firmwareTransmissionLenth*1.0)/allData.length;
                            self.transmissionPercent = percent * 100;
                        }
                        _transmissionPercent = 1;
                        [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusSuccess payload:nil];
                    }else {
                        DLog(@"接收到门锁上报一包固件写入成功，当前以保存的长度>文件总长度,发送成功");
                        [self resetFirmwareUpdateData];
                        [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
                    }
                }else {
                    DLog(@"接收到门锁上报一包固件写入成功，流水号跟当前当前保存的流水号不相同");
                    [self resetFirmwareUpdateData];
                    [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];
                }
            }else if(status == 0xe0) {
                DLog(@"接收到门锁上报一包固件写入失败，要终止升级,写EEPROM失败");
                [self resetFirmwareUpdateData];
                [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];

            }else if(status == 0xe2){
                DLog(@"接收到门锁上报一包固件写入失败，要终止升级,写FLASH失败");
                [self resetFirmwareUpdateData];
                [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];

            }else if(status == 0xe3){
                DLog(@"接收到门锁上报一包固件写入失败，要终止升级,升级操作参数错误");
                [self resetFirmwareUpdateData];
                [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];

            }else if(status == 0xe4){
                DLog(@"接收到门锁上报一包固件写入失败，要终止升级,权限错误，请先启动固件升级流程");
                [self resetFirmwareUpdateData];
                [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];

            }else{
                DLog(@"接收到门锁上报一包固件写入失败，要终止升级,错误码无法识别");
                [self resetFirmwareUpdateData];
                [self handleFirmwareTransmissionCallBack:HMBluetoothLockStatusError payload:nil];

            }
        }
    }
}

- (int)firmwareTransmissionPercent {
    return _transmissionPercent;
}

- (void)setTransmissionPercent:(int)transmissionPercent {
    if (transmissionPercent != _transmissionPercent) {
        _transmissionPercent = transmissionPercent;
        DLog(@"❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️当前传输进度%d",transmissionPercent);
        if (transmissionPercent >= 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_FIRMWAREDATATRANSMISSIONSPERCENT object:nil];
        }
    }
   
}

/**
传输固件传输

 @param path 路径
 @param lastReceSize 上次以保存的数据长度
 @param callback callback
 */
- (void)bluetoothFirmwareDataTransmissionPath:(NSURL *)path lastReceSize:(int)lastReceSize callback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@(HMBluetoothLockCmdType_FirmwareDataTransmission) forKey:@"cmd"];
    NSData * firmwareData = [NSData dataWithContentsOfURL:path];
    int leftLenth = (int)firmwareData.length - lastReceSize;
    DLog(@"传送固件总数据长度%d,上次已传长度%d,未传长度%d",firmwareData.length,lastReceSize,leftLenth);

    if (leftLenth == 0) {
        DLog(@"传送固件总数据与上次已传长度相等，不处理");
        self.updateStatus = FirmwareUpdateStatusUpdateSuccess;
        return;
    }else if(leftLenth < 0){
        DLog(@"传送固件总数据 < 上次已传长度，要终止升级");
        [self cancelUpdate];
        return;
    }
    NSData * firmwareDataSubData = [firmwareData subdataWithRange:NSMakeRange(lastReceSize, firmwareData.length - lastReceSize)];
    DLog(@"剩余未上传长度 %d",firmwareDataSubData.length);
    NSData * firmwareSendData = nil;
    if (firmwareDataSubData.length > pktHexSize) {
        firmwareSendData = [firmwareData subdataWithRange:NSMakeRange(lastReceSize, pktHexSize)];
    }else {
        firmwareSendData = firmwareDataSubData;
    }
    DLog(@"传送固件升级文件长度%d,数据%@",firmwareSendData.length,firmwareSendData);
    self.everyFirmwareTransmissionLenth = (int)firmwareSendData.length;
    [dict setObject:firmwareSendData forKey:@"firmwareSendData"];
    cmd.callback = callback;
    cmd.payload = dict;
    cmd.EncryptKey = [self getEncodeType];
    cmd.timeoutSeconds = 7;
    cmd.retransmissionTimes = 0;
    [self.dataCenter sendCmd:cmd];
}

- (void)terminateFirmwareUpgradeCallback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@(HMBluetoothLockCmdType_TerminateFirmwareUpgrade) forKey:@"cmd"];
    cmd.callback = callback;
    cmd.payload = dict;
    cmd.EncryptKey = [self getEncodeType];
    [self.dataCenter sendCmd:cmd];
}



/**
 用户信息同步
 
 @param callback
 */
- (void)userInformationSynchronizationCallback:(HMBluetoothCmdCallback)callback {
    HMBluetoothCmd * cmd = [[HMBluetoothCmd alloc] init];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@(HMBluetoothLockCmdType_UserInformationSynchronization) forKey:@"cmd"];
    HMDevice * device = [HMDevice lockWithBlueMacId:self.currentHandleLockBleMac];
    int time = [HMDeviceSettingModel T1timeWithDeviceId:device.deviceId];
    [dict setObject:@(time) forKey:@"timestamp"];
    cmd.callback = callback;
    cmd.payload = dict;
    cmd.EncryptKey = [self getEncodeType];
    [self.dataCenter sendCmd:cmd];
}


/**
 将门锁用户信息同步到服务器
 
 @param callback
 */
- (void)serverUserInformationSynchronizationUserList:(NSDictionary *)paload {
    
    int updateTime = 0;
    NSNumber * number = [paload objectForKey:@"timestamp"];
    if ([number isKindOfClass:[NSNumber class]]) {
        updateTime = [number intValue];
    }
    
    NSArray * userList = [paload objectForKey:@"userInfor"];
    NSMutableArray * tempUserlist = [NSMutableArray array];
    for (NSDictionary * dic in userList) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        [dict setObject:[dic objectForKey:@"id"] forKey:@"authorizedId"];
        [dict setObject:[dic objectForKey:@"identify"] forKey:@"identify"];
        [tempUserlist addObject:dict];
    }
    
    HMDevice * device = [HMDevice lockWithBlueMacId:self.currentHandleLockBleMac];
    UploadDeviceStatusRecordCmd * cmd = [UploadDeviceStatusRecordCmd object];
    cmd.uploadDeviceId = device.deviceId;
    cmd.uploadDeviceType = device.deviceType;
    cmd.uploadTPage = 1;
    cmd.uploadPageIndex = 1;
    cmd.uploadCount = (int)tempUserlist.count;
    cmd.allList = tempUserlist;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            DLog(@"同步门锁用户到服务器，成功，要同步更新时间");
            [self updateUserUpdateTime:device updateTime:updateTime];
        }else {
           DLog(@"同步门锁用户到服务器，失败 %d",returnValue);
        }
    });

}

/**
 保存门锁的最新更新时间到服务器
 
 @param device
 @param updateTime 门锁的最新更新时间
 */
- (void)updateUserUpdateTime:(HMDevice *)device updateTime:(int)updateTime {

    if (updateTime == 0) {
        DLog(@"当前updateTime 为0，不发送");
        return;
    }
    SetDeviceParamCmd * paramCmd = [SetDeviceParamCmd object];
    paramCmd.deviceId = device.deviceId;
    paramCmd.uid = device.uid;
    paramCmd.paramType = 2;
    paramCmd.paramId = @"userUpdateTime";
    paramCmd.paramValue = [NSString stringWithFormat:@"%d",updateTime];
    paramCmd.userName = userAccout().userName;
    sendCmd(paramCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            HMDeviceSettingModel *dsModel = [[HMDeviceSettingModel alloc] init];
            dsModel.deviceId = device.deviceId;
            dsModel.paramId = paramCmd.paramId;
            dsModel.paramType = paramCmd.paramType;
            dsModel.paramValue = paramCmd.paramValue;
            [dsModel insertObject];
            DLog(@"同步门锁用户更新时间到服务器，成功");

        }else {
            DLog(@"同步门锁用户更新时间到服务器，失败 %d",returnValue);
 
        }
    });
    
}


/**
 销毁蓝牙门锁模块，释放资源
 */
- (void)destroyBluetoothManager {
    [self.dataCenter disconnectBluetooth];
    self.dataCenter = nil;
    self.device = nil;
    bluetoothManager = nil;
}


/**
 扫描门锁，包括扫描门锁、与门锁握手两个环节，只有扫描到设备握手成功才返回正确
 
 
 @param bleMac 扫描指定bleMac 如果为nil 随机搜索一个
 @param callback
 */
- (void)scanPeripheralBlueMac:(NSString *)bleMac callback:(HMBluetoothCmdCallback)callback {
    [self.dataCenter scanPeripheralBlueMac:bleMac callback:callback];
}


/**
 获取当前蓝牙的状态
 
 @return
 */
- (HMCBManagerState)bluetoothState {
    return [self.dataCenter bluetoothState];
}


/**
 判断蓝牙是否打开
 
 @return YES 打开 NO 没打开
 */
- (BOOL)bluetoothOpen {
    return [self.dataCenter bluetoothOpen];
}


/**
 判断是否连接的是bleMac
 
 @return YES 是的 NO 不是
 */
- (BOOL)bluetoothConnectToBlueMac:(NSString *)bleMac {
    return [self.dataCenter bluetoothConnectToBlueMac:bleMac];
}


#pragma mark - 蓝牙相关API内部方法

/**
 获取门锁的私钥
 */
- (NSString *)getLockPrivateKey {
   
    HMGateway * gateWay = [HMGateway bluetoothLockGateWayWithbleMac:self.currentHandleLockBleMac];
    if (gateWay && gateWay.password.length) {
        self.privateKey = gateWay.password;
    }else {
        self.privateKey = @"";
    }
    return self.privateKey;
}

/**
 获取加密方式 有私钥就用私钥，没有私钥就用公钥

 @return 0 公钥 1 私钥
 */
- (int)getEncodeType {
    HMGateway * gateWay = [HMGateway bluetoothLockGateWayWithbleMac:self.currentHandleLockBleMac];
    if (gateWay && gateWay.password.length) {
        return 1;
    }
    return 0;
}

@end
@implementation HMBluetoothLockModel

@end
