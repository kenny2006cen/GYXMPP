//
//  HMBluetoothDataCenter.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/10/25.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBluetoothDataCenter.h"
#import "HMBluetoothManager.h"
#import "HMBluetoothEnDecoder.h"
#import "HMBluetoothLockManager.h"
//每次发送的大小
static int bluetoothEachPackageLenth = 20;

//需要休息的大小
static int bluetoothSupportLenth = 40;

//每包重试发送次数
static int maxSendTimes = 3;

@interface HMBluetoothDataCenter()<HMBluetoothManagerCallback>
@property (nonatomic, strong)HMBluetoothManager * bluetoothManager;
@property (nonatomic, assign)int  hasSendTimes;
@property (nonatomic, strong) HMBluetoothCmdCallback  scanLockCallback;//扫描门锁的回调，根据这个来判断是主动扫描还是蓝牙断开再次重连

@property (nonatomic, strong) NSCondition* signal;//timeoutDataArray 的信号锁，防止一边添加一遍移除报错。
@property (nonatomic, strong)NSMutableArray * timeoutDataArray;//加入超时队列

@property (nonatomic, strong)NSMutableArray * sendingDataArray;//正在发送的数据

@property (nonatomic, strong)NSMutableData * sendedData;//记录已经发送的数据，因为发送到一定大小时要休息一会，给硬件时间处理
@property (nonatomic, strong)NSMutableArray * cmdBuffArray;//如果当前正在发送命令，需要把新的命令暂存起来
@property (nonatomic, strong)NSMutableData * receivedData;//就收到的数据，要暂时保存着，因为蓝牙是20字节一包发过来，等接收到一包的数据
@property (nonatomic, strong)NSMutableData * sendedTransmissionFirmwareData;//记录已经发送传输固件数据，因为发送到一定大小时要休息一会，要等硬件反馈
@property (nonatomic, strong)HMBluetoothCmdCallback  sendedTransmissionFirmwareCallBack;//发送传输固件数据回调
@property (nonatomic, strong)NSMutableData * firmwareData;//固件总的数据
@end

@implementation HMBluetoothDataCenter
- (instancetype)init{
    if (self = [super init]) {
        self.bluetoothManager = [[HMBluetoothManager alloc] init];
        self.bluetoothManager.delegate = self;
        self.cmdBuffArray = [NSMutableArray array];
        self.timeoutDataArray = [NSMutableArray array];
        self.signal = [[NSCondition alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark 发送数据相关方法
- (void)sendCmd:(HMBluetoothCmd *)cmd {
    if (self.bluetoothManager.bluetoothOpen == NO) {
        DLog(@"蓝牙写数据，当前蓝牙没有打开，暂存要发送的cmd %@",cmd.payload);
        cmd.callback(HMBluetoothLockStatusBluetoothClose, nil);
        return;
    }
    //判断当前是不是有正在发送的数据
    if(self.sendingDataArray.count) {// 如果有不处理
        DLog(@"蓝牙写数据，当前正在写，不处理要发送的cmd %@",cmd.payload);
        //        [self.cmdBuffArray addObject:cmd];
    }else {// 如果没有直接发送
        DLog(@"蓝牙写数据，当前没有在写，发送的cmd %d 发送的cmd %@",cmd.serial,cmd.payload);
        [self encodeCmdToDataThenWrite:cmd];
    }
}

- (void)addCmdToTimeOutArray:(HMBluetoothCmd *)cmd {
    DLog(@"蓝牙超时队列,添加到超时队列serial = %d",cmd.serial);
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"self.serial = %d",cmd.serial];
    NSArray * cmdArray = [self.timeoutDataArray filteredArrayUsingPredicate:predicate];
    if (cmdArray.count) {
        DLog(@"蓝牙超时队列,当前已经有了，不要加到超时队列，serial = %d",cmd.retransmissionTimes);
        [self performSelector:@selector(performTimeOutCmd:) withObject:cmd afterDelay:cmd.timeoutSeconds inModes:@[NSRunLoopCommonModes]];
        return;
        
    }else {
        DLog(@"蓝牙超时队列,当前队列没有，添加到超时队列， serial = %d",cmd.serial);
    }
    
    [self.signal lock];
    [self.timeoutDataArray addObject:cmd];
    [self.signal signal];
    [self.signal unlock];
    [self performSelector:@selector(performTimeOutCmd:) withObject:cmd afterDelay:cmd.timeoutSeconds inModes:@[NSRunLoopCommonModes]];

}

- (void)performTimeOutCmd:(HMBluetoothCmd *)cmd {
    DLog(@"蓝牙超时队列,执行超时serial = %d",cmd.serial);
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"self.serial = %d",cmd.serial];
    NSArray * cmdArray = [self.timeoutDataArray filteredArrayUsingPredicate:predicate];
    if (cmdArray.count) {
        HMBluetoothCmd * cmd = cmdArray.firstObject;
        
        if (cmd.retransmissionTimes == 0) {
            DLog(@"蓝牙超时队列,执行超时当前命令已经尝试发了%d次，返回超时 serial = %d",MaxRetransmissionTimes,cmd.serial);
            [self.signal lock];
            [self.timeoutDataArray removeObject:cmd];
            [self.signal signal];
            [self.signal unlock];
            DLog(@"蓝牙超时队列,找到超时serial = %d，返回超时",cmd.serial);
            self.receivedData = nil;
            [self.sendingDataArray removeAllObjects];
            [self sendCmdBufferCmd];
            if (cmd.callback) {
                cmd.callback(HMBluetoothLockStatusTimeOut, nil);
            }
        }else {
            DLog(@"蓝牙超时队列,执行超时当前命令已经尝试发了%d次，再次尝试发送一次 serial = %d",MaxRetransmissionTimes - cmd.retransmissionTimes,cmd.serial);
            self.receivedData = nil;
            [self.sendingDataArray removeAllObjects];
            [self sendCmd:cmd];
            cmd.retransmissionTimes -- ;
        }
    }else {
        DLog(@"蓝牙超时队列,没有找到超时cmd = %d，可能返回正确",cmd.serial);

    }
}



/**
 将cmd编码成NSData，然后写数据

 @param cmd 需要编码的cmd
 */
- (void)encodeCmdToDataThenWrite:(HMBluetoothCmd *)cmd {
    [self addCmdToTimeOutArray:cmd];//添加到超时队列
    NSData * sendData = [HMBluetoothEnDecoder enCoderCmd:cmd];
    if (sendData.length <= 13) {
        DLog(@"蓝牙写数据，发送数据转Data错误 %@",sendData);
        return;
    }
    
    int cmdInt = [[cmd.payload objectForKey:@"cmd"] intValue];
    
    if (cmdInt == HMBluetoothLockCmdType_FirmwareDataTransmission) {
        
        NSData * tempFirmwareData = [cmd.payload objectForKey:@"firmwareData"];
        self.firmwareData = [NSMutableData dataWithData:tempFirmwareData];
        int lastReceSize = [[cmd.payload objectForKey:@"lastReceSize"] intValue];
        if (lastReceSize == 0) {
            self.sendedTransmissionFirmwareData = [NSMutableData data];
        }else {
            NSData * sendData = [tempFirmwareData subdataWithRange:NSMakeRange(0, lastReceSize)];
            self.sendedTransmissionFirmwareData = [NSMutableData dataWithData:sendData];
        }
        
        [self callBackSendedTransmissionFirmwareData];
        
    }
    
    self.sendingDataArray = [self breakupOriginData:sendData];
    
    [self bluetoothManagerSendData];
}

- (void)callBackSendedTransmissionFirmwareData{
    if (self.sendedTransmissionFirmwareCallBack) {
        NSMutableDictionary * payload = [NSMutableDictionary dictionary];
        float percent = self.sendedTransmissionFirmwareData.length/self.firmwareData.length;
        [payload setObject:@(percent) forKey:@"percent"];
        self.sendedTransmissionFirmwareCallBack(HMBluetoothLockStatusTerminateFirmwareUpgradeProcess,payload);
    }
}


/**
 向蓝牙写数据
 */
- (void)bluetoothManagerSendData {
    if(self.sendingDataArray.count == 0) {
        DLog(@"蓝牙写数据，当前没有数据，不发送");
        return;
    }
    
    NSData * sendData = [self.sendingDataArray firstObject];
    DLog(@"蓝牙写数据，写数据data = %@ 长度 = %d",sendData,sendData.length);

    if(sendData.length == 0) {
        DLog(@"蓝牙写数据，写数据data = %@ 长度 = %d 出错不发送",sendData,sendData.length);

        return;
    }
    
    if (WriteBlueToothWithResponce) {
        DLog(@"当前是有响应发送，直接发送数据");
        [self.bluetoothManager writeData:sendData];//写数据
    }else {
        if(self.sendedData == nil) {
            self.sendedData = [NSMutableData data];
            [self.sendedData appendData:sendData];//暂存发送的数据，用来判断是否需要休息一下
            DLog(@"蓝牙写数据，没有已经发送数据，首次保存data = %@",sendData);
            
        }else {
            DLog(@"蓝牙写数据，有已经发送数据，拼接之前data = %@",self.sendedData);
            [self.sendedData appendData:sendData];
            DLog(@"蓝牙写数据，有已经发送数据，拼接之后data = %@",self.sendedData);
        }
        
        if(self.sendedTransmissionFirmwareData) {
            [self.sendedTransmissionFirmwareData appendData:sendData];
            [self callBackSendedTransmissionFirmwareData];
        }
        [self.bluetoothManager writeData:sendData];//写数据
        [self.sendingDataArray removeObjectAtIndex:0];//写完之后移除
        [self sendData];
    }
}

- (void)sendData {
    DLog(@"蓝牙写数据，回调成功");
    //判断上一个命令是否发送完成
    if(self.sendingDataArray.count) {//当前命令没有发送完
        DLog(@"蓝牙写数据，当前数据没写完，接着写数据");
        //判断是否要休息一下
        if(self.sendedData.length >= bluetoothSupportLenth) {//休息一下
            DLog(@"蓝牙写数据，当前数据已超过蓝牙最大承载量，需要休息一下接着写数据");
            self.sendedData = nil;
            if(bluetoothSupportLenth == 120){
                [self performSelector:@selector(bluetoothManagerSendData) withObject:nil afterDelay:0.01 inModes:@[NSRunLoopCommonModes]];
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self bluetoothManagerSendData];
                });
                
            }
            
        }else {//不需要休息
            DLog(@"蓝牙写数据，当前数据没超过蓝牙最大承载量，直接写数据");
            [self bluetoothManagerSendData];
        }
        
    }else {//当前命令已发送完成
        DLog(@"蓝牙写数据，当前数据写完成，接着写缓存的数据");
        self.sendedData = nil;
        [self sendCmdBufferCmd];//发送缓存的cmd
    }
};


/**
 将要发送的数据按 bluetoothEachPackageLenth 的长度分割然后保存在数组中

 @param originData 发送的数据
 @return NSData对象，每个长度不超过 bluetoothEachPackageLenth
 */
- (NSMutableArray *)breakupOriginData:(NSData *)originData {
    DLog(@"蓝牙写数据，当前写数据总长度为 %d",originData.length);
    NSMutableArray * array = [NSMutableArray array];
    if (originData.length <= bluetoothEachPackageLenth) {
        [array addObject:originData];
    }else {
        NSUInteger i = originData.length/bluetoothEachPackageLenth; //整数倍;
        NSUInteger j = originData.length%bluetoothEachPackageLenth;//余数
        for (int times = 0; times < i; times ++) {
            NSData * subData = [originData subdataWithRange:NSMakeRange(times * bluetoothEachPackageLenth, bluetoothEachPackageLenth)];
            [array addObject:subData];
        }
        if (j!=0) {
            NSData * subData = [originData subdataWithRange:NSMakeRange(i * bluetoothEachPackageLenth, j)];
            [array addObject:subData];
        }
    }
    DLog(@"蓝牙写数据，写数据的分割数据为 %@",array);
    return array;
}

/**
 发送缓存数据
 */
- (void)sendCmdBufferCmd {
    self.sendedData = nil;//先把上次已发送的命令置为nil
    //判断缓存的是否有命令
    if(self.cmdBuffArray.count) {//有
        DLog(@"蓝牙写数据，当前缓存的有数据，发送缓存数据");
        HMBluetoothCmd * sendCmd = self.cmdBuffArray.lastObject;
        [self encodeCmdToDataThenWrite:sendCmd];// 取出来第一个发送
        [self.cmdBuffArray removeLastObject];//发送完成之后，从buffer中移除
    }else {//没有  写数据结束
        DLog(@"蓝牙写数据，当前缓存的没有数据，写数据全部完成");
        
    }
}

#pragma mark -
#pragma mark 读数据相关方法

/**
 处理拼接之后的数据，主要是判断是否接收完
 */
- (void)handleReceiveData {
    //拼接之后在判断一下包的长度跟拼接之后的长度
    NSData * headLenthData = [self.receivedData subdataWithRange:NSMakeRange(2, 4)];
    int headLength = [HMBluetoothEnDecoder headLenth:headLenthData];
    DLog(@"蓝牙读数据，读到数据长度 = %d,当前接收数据 = %@ 长度 = %d",headLength,self.receivedData,self.receivedData.length);
    
    if (self.receivedData.length > headLength){// 这里是因为硬件处理每一包的数据都是20字节，不满20字节的也要拼凑成20字节,所以接到的数据有可能大于协议长度
        NSData * protoclData = [self.receivedData subdataWithRange:NSMakeRange(0, headLength)];
        [self receiveAllData:protoclData];
    }else if (self.receivedData.length == headLength) {
        [self receiveAllData:self.receivedData];
    }
}


/**
 将拼接好的数据转成cmd
 
 @param allData 拼接好的数据包
 */
- (void)receiveAllData:(NSData *)allData {
    HMBluetoothCmd * cmd = [HMBluetoothEnDecoder deCoderData:allData];
    if (cmd) {
        DLog(@"蓝牙读数据，读到数据%@",cmd.payload);
        HMBluetoothLockCmdType cmdType = [[cmd.payload objectForKey:@"cmd"] integerValue];
        if(cmdType == HMBluetoothLockCmdType_InputNewFingerprintInitiativelyReport ||
           cmdType == HMBluetoothLockCmdType_SSIDReport ||
           cmdType == HMBluetoothLockCmdType_HotConnectionState ||
           cmdType == HMBluetoothLockCmdType_DeleteFingerprint ||
           cmdType == HMBluetoothLockCmdType_FirmwareDataTransmissionUpdata){//主动上报命令，发通知
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_BLUETOOTH_UPDATEDATA object:cmd.payload];

        }else {//应答消息
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"self.serial = %d",cmd.serial];
            NSArray * cmdArray = [self.timeoutDataArray filteredArrayUsingPredicate:predicate];
            if (cmdArray.count) {
                DLog(@"蓝牙读数据，取到超时队列里的cmd %d ，返回结果",cmd.serial);
                HMBluetoothCmd * oldCmd = cmdArray.firstObject;
                [self.signal lock];
                [self.timeoutDataArray removeObject:oldCmd];
                [self.signal signal];
                [self.signal unlock];
                if (oldCmd.callback) {
                    NSDictionary * payload = oldCmd.payload;
                    int cmdInt = [[payload objectForKey:@"cmd"] intValue];
                    int status = [[cmd.payload objectForKey:@"status"] intValue];
                     if (cmdInt == HMBluetoothLockCmdType_Handshake) {// 这里握手命令要单独处理一下
                        if (status == 0) {//握手成功
                            self.bluetoothManager.reconnectTimes = MAXRECONNECTTIMES;
                            if (oldCmd.EncryptKey == 0) {//如果是公钥握手成功，需要获取设备信息，获取设备信息之后再返回握手命令
                                DLog(@"蓝牙读数据，当前是公钥握手 ，要获取设备信息之后在返回握手命令，再返回握手命令");
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [HMBluetoothLockAPI getEquipmentInformationCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
                                        if(errorCode == HMBluetoothLockStatusSuccess){
                                            if (payload) {
                                                int status = [[payload objectForKey:@"status"] intValue];
                                                if (status == 0) {
                                                    HMBluetoothLockModel * lockModel = [[HMBluetoothLockModel alloc] init];
                                                    lockModel.ModelID= [payload objectForKey:@"ModelID"];
                                                    lockModel.hardwareVersion = [payload objectForKey:@"hardwareVersion"];
                                                    lockModel.bleMAC = [payload objectForKey:@"bleMAC"];
                                                    lockModel.mcuUniqueID = [payload objectForKey:@"mcuUniqueID"];
                                                    lockModel.zigbeeMAC = [[payload objectForKey:@"zigbeeMAC"] lowercaseString];
                                                    lockModel.bleVersion = [payload objectForKey:@"bleVersion"];
                                                    lockModel.mcuVerion = [payload objectForKey:@"mcuVerion"];
                                                    lockModel.zigbeeVersion = [payload objectForKey:@"zigbeeVersion"];
                                                    DLog(@"蓝牙读数据，当前是公钥 ，要获取设备信息成功");
                                                    [HMBluetoothLockAPI gettingTheStateOfZigbeeNetworkingCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
                                                        if (payload) {//查询到配对网关信息成功
                                                            int status = [[payload objectForKey:@"status"] intValue];
                                                            if (status == 0) {
                                                                int nwkStatus = [[payload objectForKey:@"nwkStatus"] intValue];
                                                                lockModel.nwkStatus = nwkStatus;
                                                                lockModel.paried = [[payload objectForKey:@"paried"] intValue];
                                                                [[HMBluetoothLockManager defaultManager] saveLockModel:lockModel];
                                                                oldCmd.callback(HMBluetoothLockStatusSuccess, cmd.payload);
                                                            }else {
                                                                DLog(@"蓝牙读数据，当前是公钥握手 ，要获取设备信息之后在返回握手命令，再返回握手命令，查询返回值不为0");
                                                                lockModel.nwkStatus = 0x17;
                                                                lockModel.paried = 0;
                                                                [[HMBluetoothLockManager defaultManager] saveLockModel:lockModel];
                                                                oldCmd.callback(HMBluetoothLockStatusSuccess, cmd.payload);
                                                            }
                                                            
                                                        }else {//查询到配对网关信息失败
                                                            DLog(@"蓝牙读数据，当前是公钥握手 ，要获取设备信息之后在返回握手命令，再返回握手命令，查询失败");
                                                            lockModel.nwkStatus = 0x17;
                                                            lockModel.paried = 0;
                                                            [[HMBluetoothLockManager defaultManager] saveLockModel:lockModel];
                                                            oldCmd.callback(HMBluetoothLockStatusSuccess, cmd.payload);
                                                            
                                                        }
                                                    }];
                                                }else {
                                                    DLog(@"蓝牙读数据，当前是公钥 ，要获取设备信息失败,状态不为0");
                                                    oldCmd.callback(HMBluetoothLockStatusError, cmd.payload);
                                                }
                                            }else {
                                                DLog(@"蓝牙读数据，当前是公钥 ，要获取设备信息失败 payload 格式不对");
                                                oldCmd.callback(HMBluetoothLockStatusError, cmd.payload);
                                            }
                                        }else {
                                            DLog(@"蓝牙读数据，当前是公钥 ，要获取设备信息失败");
                                            oldCmd.callback(HMBluetoothLockStatusError, cmd.payload);
                                        }
                                    }];
                                });
                            }else {
                                DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功");
                                NSString * bleMac = [[HMBluetoothLockManager defaultManager] getCurrentLockBleMac];
                                HMGateway * gateWay = [HMGateway objectWithUid:bleMac];
                                NSComparisonResult compareResult =[gateWay.systemVersion compare:@"1.6.298"];
                                if (compareResult == NSOrderedAscending && [gateWay.model isEqualToString:kT1Model]) {//只有T1门锁才需要判断版本号
                                   DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，当前门锁版本号%@比支持同步版本号低，不发同步用户命令，发同步时间命令",gateWay.systemVersion);
                                    [HMBluetoothLockAPI timeSynchronizationCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
                                        oldCmd.callback(HMBluetoothLockStatusSuccess, cmd.payload);//返回握手成功命令
                                        if (payload) {
                                            int status = [[payload objectForKey:@"status"] intValue];
                                            if (status == 0) {
                                                DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送时间同步命令,同步时间成功");
                                            }else {
                                                DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送时间同步命令,同步时间门锁返回不为0");
                                            }
                                            
                                        }else {
                                            DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送时间同步命令,同步时间门锁时间失败");
                                        }
                                    }];
                                }else {
                                    DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，当前门锁版本号%@支持同步，发同步用户命令",gateWay.systemVersion);

                                    [HMBluetoothLockAPI userInformationSynchronizationCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
                                        if (errorCode == HMBluetoothLockStatusSuccess) {
                                            DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送用户同步命令 成功");
                                            if (payload) {
                                                int status = [[payload objectForKey:@"status"] intValue];
                                                if (status == 0) {
                                                    DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送用户同步命令,同步用户成功");
                                                    NSArray * userInfor = [payload objectForKey:@"userInfor"];
                                                    if (userInfor.count) {
                                                        DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送用户同步命令,同步用户成功,有数据返回，要更新服务器");
                                                        [HMBluetoothLockAPI serverUserInformationSynchronizationUserList:payload];
                                                        
                                                    }else {
                                                        DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送用户同步命令,同步用户成功,没有数据返回，不更新服务器");
                                                        
                                                    }
                                                }else {
                                                    DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送用户同步命令,同步用户门锁返回不为0");
                                                }
                                                
                                            }else {
                                                DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送用户同步命令,同步用户 失败");
                                            }
                                            
                                        }
                                        
                                        DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送用户同步命令返回，开始发送同步时间命令");
                                        
                                        [HMBluetoothLockAPI timeSynchronizationCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
                                            oldCmd.callback(HMBluetoothLockStatusSuccess, cmd.payload);//返回握手成功命令
                                            if (payload) {
                                                int status = [[payload objectForKey:@"status"] intValue];
                                                if (status == 0) {
                                                    DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送时间同步命令,同步时间成功");
                                                }else {
                                                    DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送时间同步命令,同步时间门锁返回不为0");
                                                }
                                                
                                            }else {
                                                DLog(@"蓝牙读数据，当前是私钥握手 ，握手成功，发送时间同步命令,同步时间门锁时间失败");
                                            }
                                        }];
                                        
                                    }];
                                }
                            }
                        }else if(status == 1){//握手失败，不知道什么原因
                            oldCmd.callback(HMBluetoothLockStatusError, cmd.payload);
                        }else if(status == 2) {//握手失败，密钥类型错误
                            if(oldCmd.EncryptKey == 0) {//app用的是公钥，门锁里面是私钥
                                oldCmd.callback(HMBluetoothLockStatusAppPublicKeyLockPrivateKey, cmd.payload);
                            }else {//app用的是私钥，门锁里面是公钥
                                oldCmd.callback(HMBluetoothLockStatusAppPrivateKeyLockPublicKey, cmd.payload);
                            }
                        }else if(status == 3) {//握手失败，密钥类型错误
                            oldCmd.callback(HMBluetoothLockStatusAppPublicDifferentKey, cmd.payload);
                        }
                    }else {//其他命令
                        if(status == 2) {//密钥类型错误
                            if(oldCmd.EncryptKey == 0) {//app用的是公钥，门锁里面是私钥
                                oldCmd.callback(HMBluetoothLockStatusAppPublicKeyLockPrivateKey, nil);
                            }else {//app用的是私钥，门锁里面是公钥
                                oldCmd.callback(HMBluetoothLockStatusAppPrivateKeyLockPublicKey, nil);
                            }
                        }else if(status == 3) {//密钥类型错误
                            oldCmd.callback(HMBluetoothLockStatusAppPublicDifferentKey, nil);
                        }else {
                            if(cmdInt == HMBluetoothLockCmdType_GetZigbeeNetworkingStatus){
                                if(status == 0){
                                    int nwkStatus = [[cmd.payload objectForKey:@"nwkStatus"] intValue];
                                    if (nwkStatus == 0x17) {
                                        NSMutableDictionary * tempPayload = [NSMutableDictionary dictionaryWithDictionary:cmd.payload];
                                        [tempPayload setObject:@(0) forKey:@"paried"];
                                        cmd.payload = tempPayload;
                                        DLog(@"蓝牙读数据，当前是获取设备组网状态是无网络 ，把paried字段置为0");
                                    }
                                }
                                oldCmd.callback(HMBluetoothLockStatusSuccess, cmd.payload);
                            }else {
                                oldCmd.callback(HMBluetoothLockStatusSuccess, cmd.payload);
                            }
                        }
                    }
                }
            }else {
                DLog(@"蓝牙读数据，没有取到超时队列里的cmd ，可能已经超时");
            }
        }
    }else {
        DLog(@"蓝牙读数据，读到数据解析失败☺,等待走超时");
    }
    self.receivedData = nil;//将暂存的数据置为nil
    
}


#pragma mark -
#pragma mark HMBluetoothManager 回调

/**
 写数据回调
 
 @param error 成功为nil
 */
- (void)didWriteValueError:(NSError *)error {
    if(!WriteBlueToothWithResponce) {
        DLog(@"当前是非响应发送，这里不处理");
        return;
    }
    if (error) {// 写数据出错
        DLog(@"蓝牙写数据，回调出错 %@",[error localizedDescription]);
        if (self.hasSendTimes < maxSendTimes) {
            DLog(@"当前重发次数为%zi，要重新发送试试",self.hasSendTimes);
            self.hasSendTimes ++;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self bluetoothManagerSendData];
            });
            
        }else {
            DLog(@"当前重发次数为%zi，已经超过最大次数不要发送",self.hasSendTimes);
            self.hasSendTimes = 0;
            //判断上一个命令是否发送完成
            if(self.sendingDataArray.count) {//当前命令没有发送完
                DLog(@"蓝牙写数据，当前的命令还没有发送完,先清除没发完的数据，再发送暂存的命令");
                [self.sendingDataArray removeAllObjects];//将正在发送的数据移丢弃
                self.sendedData = nil;
                [self sendCmdBufferCmd];//发送缓存的cmd
                
            }else {//当前命令已发送完成
                DLog(@"蓝牙写数据，当前的命令已发送完,发送暂存的命令");
                self.sendedData = nil;
                [self sendCmdBufferCmd];//发送缓存的cmd
            }
        }
        
        
    }else {// 写数据成功
        self.hasSendTimes = 0;
        if (self.sendingDataArray.count) {
            
            NSData * sendData = self.sendingDataArray.firstObject;
            if(self.sendedData == nil) {
                self.sendedData = [NSMutableData data];
                [self.sendedData appendData:sendData];//暂存发送的数据，用来判断是否需要休息一下
                DLog(@"蓝牙写数据，没有已经发送数据，首次保存data = %@",sendData);
                
            }else {
                DLog(@"蓝牙写数据，有已经发送数据，拼接之前data = %@",self.sendedData);
                [self.sendedData appendData:sendData];
                DLog(@"蓝牙写数据，有已经发送数据，拼接之后data = %@",self.sendedData);
            }
            [self.sendingDataArray removeObjectAtIndex:0];//写完之后移除
            
            //判断是否要休息一下
            if(self.sendedData.length >= bluetoothSupportLenth) {//休息一下
                DLog(@"蓝牙写数据，当前数据已超过蓝牙最大承载量，需要休息一下接着写数据");
                self.sendedData = nil;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self bluetoothManagerSendData];
                });
            }else {//不需要休息
                DLog(@"蓝牙写数据，当前数据没超过蓝牙最大承载量，直接写数据");
                [self bluetoothManagerSendData];
            }
           
        }else{//当前命令已发送完成
            DLog(@"蓝牙写数据，当前数据写完成，接着写缓存的数据");
            self.sendedData = nil;
            [self sendCmdBufferCmd];//发送缓存的cmd
        }
        
    
//            [self sendData];

        /*
        DLog(@"蓝牙写数据，回调成功");
        //判断上一个命令是否发送完成
        if(self.sendingDataArray.count) {//当前命令没有发送完
            DLog(@"蓝牙写数据，当前数据没写完，接着写数据");

            //判断是否要休息一下
            if(self.sendedData.length >= bluetoothSupportLenth) {//休息一下
                DLog(@"蓝牙写数据，当前数据已超过蓝牙最大承载量，需要休息一下接着写数据");
                self.sendedData = nil;
                [self performSelector:@selector(bluetoothManagerSendData) withObject:nil afterDelay:0.02];
                
            }else {//不需要休息
                DLog(@"蓝牙写数据，当前数据没超过蓝牙最大承载量，直接写数据");
                [self bluetoothManagerSendData];
            }
            
        }else {//当前命令已发送完成
            DLog(@"蓝牙写数据，当前数据写完成，接着写缓存的数据");
            self.sendedData = nil;
            [self sendCmdBufferCmd];//发送缓存的cmd
        }*/
        
    }
}



/**
 读数据回调
 
 @param error 成功为nil
 */
- (void)didUpdateValue:(NSData *)data error:(NSError *)error {
    if(error == nil) {
        DLog(@"蓝牙读数据，读到数据 %@",data);
        if (data.length > 2) {//检验长度是否正确
            NSData * headData = [data subdataWithRange:NSMakeRange(0, 2)];
            if (![HMBluetoothEnDecoder headError:headData]) {//包头正确，这是一个新包
                if(self.receivedData == nil) {
                    DLog(@"蓝牙读数据，包头正确暂存的数据为空，为新包");
                    self.receivedData = [NSMutableData data];
                    [self.receivedData appendData:data];
                    [self handleReceiveData];
                }else {
                    DLog(@"蓝牙读数据，包头正确但是暂存的数据不为空 %@ 长度 %d,也暂存数据，因为有可能这包数据就是55aa开始",self.receivedData,self.receivedData.length);
                    [self.receivedData appendData:data];
                    [self handleReceiveData];
                }
            }else {// 包头不正确，有可能是需要拼接的包
                //先判断这包数据里面是否包含包头，因为有可能上报的包头前面多了00 或者 00000
                if([self dataContainHeadData:data]) {//如果包含包头数据
                    int headDataLocation = 0;
                    for (int i = 0; i < data.length - 2; i ++) {//找到包头所在的位置
                        NSData * headData = [data subdataWithRange:NSMakeRange(i, 2)];
                        if (![HMBluetoothEnDecoder headError:headData]) {
                            headDataLocation = i;
                            break;
                        }
                    }
                    NSData * normalData = [data subdataWithRange:NSMakeRange(headDataLocation, data.length - headDataLocation)];
                    if(self.receivedData == nil) {
                        DLog(@"蓝牙读数据，包头不正确，这包数据里面有包头,暂存的数据为空，为新包");
                        self.receivedData = [NSMutableData data];
                        [self.receivedData appendData:normalData];
                        [self handleReceiveData];
                    }else {
                        DLog(@"蓝牙读数据，包头不正确，这包数据里面有包头,暂存的数据不为空 %@ 长度 %d,认为是正常数据包含包头，暂存数据",self.receivedData,self.receivedData.length);
                        [self.receivedData appendData:data];
                        [self handleReceiveData];
                    }
                }else {//如果不包含包头
                    
                    if(self.receivedData.length) { //之前有接收到数据，把数据拼接起来
                        DLog(@"蓝牙读数据，包头不正确，这包数据里面没有包头");
                        if (self.receivedData.length == 1) {//如果长度是1
                            DLog(@"蓝牙读数据，包头不正确，这包数据里面没有包头，暂存数据长度为1");
                            //判断是不是55
                            Byte *head55Byte = (Byte *)malloc([self.receivedData length]);
                            memcpy(head55Byte, [self.receivedData bytes], [self.receivedData length]);
                            int byte0 = head55Byte[0];
                            if(byte0 == 0x55) {//长度是1并且是55
                                DLog(@"蓝牙读数据，包头不正确，这包数据里面没有包头，暂存数据长度为1，并且是55");
                                //判断这包数据的包头是不是aa
                                NSData * preData = [data subdataWithRange:NSMakeRange(0, 1)];
                                Byte *headaaByte = (Byte *)malloc([preData length]);
                                memcpy(headaaByte, [preData bytes], [preData length]);
                                int byteaa = headaaByte[0];
                                if(byteaa == 0xaa) {//上一包结尾是55这一包开头是aa，要组包
                                    DLog(@"蓝牙读数据，包头不正确，这包数据里面没有包头，暂存数据长度为1，并且是55，这包数据开头是aa，要组包");
                                    [self.receivedData appendData:data];
                                    [self handleReceiveData];
                                }else {//上一包只是55，这一包数据又不是aa，认为这一包数据有问题
                                    DLog(@"蓝牙读数据，包头不正确，这包数据里面没有包头，暂存数据长度为1，并且是55，这包数据开头不是aa，丢弃");
                                }
                            }else {//长度是1但不是55，也拼在一起解析一下
                                DLog(@"蓝牙读数据，包头不正确，这包数据里面没有包头，暂存数据长度为1，但是不是55，也组包");
                                [self.receivedData appendData:data];
                                [self handleReceiveData];
                            }
                        }else {//如果长度不是1，直接拼包处理
                            DLog(@"蓝牙读数据，包头不正确，这包数据里面没有包头，暂存数据长度不为1，直接组包");
                            [self.receivedData appendData:data];
                            [self handleReceiveData];
                        }
                    }else {//之前没有接收到数据，包头又不正确
                        //先判断包尾一个字节是不是55
                        NSData * suffData = [data subdataWithRange:NSMakeRange(data.length - 1, 1)];
                        Byte *headByte = (Byte *)malloc([suffData length]);
                        memcpy(headByte, [suffData bytes], [suffData length]);
                        int byte0 = headByte[0];
                        if (byte0 == 0x55) {//之前没有接收到数据，包头又不正确，结尾是55,先把55存起来
                            DLog(@"蓝牙读数据，包头不正确，这包数据里面没有包头但是结尾是55，暂存的为空，暂存55");
                            self.receivedData = [NSMutableData data];
                            [self.receivedData appendData:suffData];
                        }else {//如果不是55
                            DLog(@"蓝牙读数据，包头不正确，这包数据里面没有包头并且结尾不是55，暂存的为空，接到的数据直接丢弃");
                        }
                    }
                }
            }
        }else {
            DLog(@"蓝牙读数据，读数据的长度不足2字节 %@",data);
        }
    }else {
        DLog(@"蓝牙读数据，读数据出错 %@",[error localizedDescription]);
    }
}

- (BOOL)dataContainHeadData:(NSData *)data {
    if (data.length < 2) {
        return NO;
    }
    for (int i = 0; i < data.length - 2; i ++) {
        NSData * headData = [data subdataWithRange:NSMakeRange(i, 2)];
        if (![HMBluetoothEnDecoder headError:headData]) {
            return YES;
            break;
        }
    }

    return NO;
}

- (void)connectBluetoothStatus:(HMBluetoothStatus)status {
    switch (status) {
        case HMBluetoothStatusPowerOn: {// 蓝牙打开,蓝牙管理类开始搜设备
//            [self.bluetoothManager scanPeripheralBlueMac:self.bluetoothManager.bleMac];
            break;
        }
        case HMBluetoothStatusGetwriteCharacteristic: {
            //先判断是否有扫描门锁的回调
            if(self.scanLockCallback) {//如果有，说明是主动扫描，主动扫描之后是要先发握手命令看看是否能正常与蓝牙通信
                DLog(@"蓝牙写数据，有扫描门锁的回调，说明是主动扫描，主动扫描之后是要先发握手命令看看是否能正常与蓝牙通信");
                [HMBluetoothLockAPI deviceHandshakeCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
                    if(self.scanLockCallback) {
                        self.scanLockCallback(errorCode, payload);
                        self.scanLockCallback = nil;
                    }
                }];
            }else {//如果没有，说明是自动扫描，自动动扫描之后是要看看之前有没有要发的数据
                DLog(@"蓝牙写数据，没有扫描门锁的回调，说明是自动扫描");
                if(self.sendingDataArray.count) {
                    DLog(@"蓝牙写数据，获取写特征值成功，有正在发送的命令，先发送正在发送的命令");
                    [self bluetoothManagerSendData];
                }else {
                    DLog(@"蓝牙写数据，获取写特征值成功，没有正在发送的命令， 检查有没有缓存要发送的命令%@",self.cmdBuffArray);
                    if (self.cmdBuffArray.count) {
                        DLog(@"蓝牙写数据，获取写特征值成功，有要发送的命令");
                        [self sendCmdBufferCmd];
                    }else {
                        DLog(@"蓝牙写数据，获取写特征值成功，没有要发送的命令，发送握手命令");
                        [HMBluetoothLockAPI deviceHandshakeCallback:^(HMBluetoothLockStatusCode errorCode, NSDictionary *payload) {
                            //先判断是否有正在发送的命令
                            DLog(@"蓝牙写数据，没有扫描门锁的回调，握手成功");
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_BLUETOOTH_BREAKCONNECT object:nil];
                            
                        }];
                    }
                }
            }
            
        }
            break;
            
        case HMBluetoothStatusNotFoundDevice:{
            if (self.scanLockCallback) {
                self.scanLockCallback(HMBluetoothLockStatusTimeOut, nil);
            }
        }
            
        default:
            break;
    }
}
/**
 扫描门锁，包括扫描门锁、与门锁握手两个环节，只有扫描到设备握手成功才返回正确
 
 
 @param bleMac 扫描指定bleMac
 @param callback
 */
- (void)scanPeripheralBlueMac:(NSString *)bleMac callback:(HMBluetoothCmdCallback)callback {
   
    if(!self.bluetoothManager.bluetoothOpen) {
        DLog(@"蓝牙扫描门锁，当前蓝牙没有打开");
        if (callback) {
            callback(HMBluetoothLockStatusBluetoothClose,nil);
        }
    }else {
        DLog(@"蓝牙扫描门锁，当前蓝牙打开,开始扫门锁");
        //先断开之前的连接
        self.scanLockCallback = [callback copy];
        [self.bluetoothManager scanPeripheralBlueMac:bleMac];
    }
}


- (HMCBManagerState)bluetoothState {
    return self.bluetoothManager.bluetoothState;

}

/**
 判断蓝牙是否打开
 
 @return YES 打开 NO 没打开
 */
- (BOOL)bluetoothOpen {
    return self.bluetoothManager.bluetoothOpen;
}

/**
 判断是否连接的是bleMac
 
 @return YES 是的 NO 不是
 */
- (BOOL)bluetoothConnectToBlueMac:(NSString *)bleMac {
    return [self.bluetoothManager bluetoothConnectToBlueMac:bleMac];
}

- (void)disconnectBluetooth {
    [self.bluetoothManager disconnectBluetooth];
}

@end
