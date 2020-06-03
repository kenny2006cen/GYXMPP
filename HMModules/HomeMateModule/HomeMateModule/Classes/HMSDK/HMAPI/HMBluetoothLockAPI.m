//
//  HMBluetoothLockAPI.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/10/23.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBluetoothLockAPI.h"
#import "HMBluetoothLockManager.h"
@implementation HMBluetoothLockAPI

/**
 调用其他方法之前要先初始化一下蓝牙管理类，因为要首先确定蓝牙是否打开
 */
+ (void)initBluetoothManager {
    [HMBluetoothLockManager defaultManager];
}

/**
 当前配置成功的device，只有添加成功才有值
 
 @return
 */
+ (HMDevice *)addSuccessDevice {
    return [[HMBluetoothLockManager defaultManager] addSuccessDevice];
}

/**
 查询是否有在线的主机
 */
+ (void)checkOnlineEmbHubCallback:(HMBluetoothCmdCallback)callback {
   [[HMBluetoothLockManager defaultManager] checkOnlineEmbHubCallback:callback];
}

/**
 获取当前操作门锁的蓝牙mac地址，没有搜索到门锁为nil
 
 @return
 */
+ (NSString *)getCurrentLockBleMac {
    return [[HMBluetoothLockManager defaultManager] getCurrentLockBleMac];
}

/**
 1、向服务器绑定门锁，这个过程请保证蓝牙不会断开，因为这个过程还会通过蓝牙跟门锁通信
 2、调用这个方法之前，务必调用握手命令，根据握手命令返回的状态做不同的处理
 
 @param errorCode  deviceHandshakeCallback: 返回的errorCode
 @param callback
 */
+ (void)addLockToServerBluetoothLockErrorCode:(HMBluetoothLockStatusCode)errorCode callback:(HMBluetoothCmdCallback)callback {
     [[HMBluetoothLockManager defaultManager] addLockToServerBluetoothLockErrorCode:errorCode callback:callback];
}


#pragma mark - 蓝牙相关的API

/**
 获取当前蓝牙的状态
 
 @return
 */
+ (HMCBManagerState)bluetoothState {
    return  [[HMBluetoothLockManager defaultManager] bluetoothState];
}

/**
 判断蓝牙是否打开
 
 @return YES 打开 NO 没打开
 */
+ (BOOL)bluetoothOpen {
   return  [[HMBluetoothLockManager defaultManager] bluetoothOpen];
}

/**
 判断是否连接的是bleMac
 
 @return YES 是的 NO 不是
 */
+ (BOOL)bluetoothConnectToBlueMac:(NSString *)bleMac {
    return [[HMBluetoothLockManager defaultManager] bluetoothConnectToBlueMac:bleMac];
}

/**
 扫描门锁，包括扫描门锁、与门锁握手两个环节，只有扫描到设备握手成功才返回正确
 
 
 @param bleMac 扫描指定bleMac 如果为nil 随机搜索一个
 @param callback
 */
+ (void)scanPeripheralBlueMac:(NSString *)bleMac callback:(HMBluetoothCmdCallback)callback; {
    [[HMBluetoothLockManager defaultManager] scanPeripheralBlueMac:bleMac callback:callback];
}

/**
 清除私钥
 
 @param callback
 */
+ (void)cleanPrSivateKeyCallback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] cleanPrSivateKeyCallback:callback];
}

/**
 设备握手命令，主要判断密钥是否正确
 
 @param callback
 */
+ (void)deviceHandshakeCallback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] deviceHandshakeCallback:callback];
}


/**
 获取私钥
 
 @param callback
 */
+ (void)getPrivatekeyCallback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] getPrivatekeyCallback:callback];

}


/**
 用户身份验证
 
 @param callback
 */
+ (void)userAuthenticationCallback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] userAuthenticationCallback:callback];
}


/**
 时间同步命令
 
 @param callback
 */
+ (void)timeSynchronizationCallback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] timeSynchronizationCallback:callback];
}


/**
 获取设备信息
 
 @param callback
 */
+ (void)getEquipmentInformationCallback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] getEquipmentInformationCallback:callback];
}


/**
 Zigbee组网控制命令(组网 or 清网)
 
 
 @param nwkcmd 0 : 操作成功，开启组网  1 : 结束组网  2 : 清除组网
 @param callback
 */
+ (void)zigbeeNetworkControlNWKCmd:(int)nwkcmd callback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] zigbeeNetworkControlNWKCmd:nwkcmd callback:callback];
}


/**
 获取Zigbee组网状态命令
 
 
 @param callback
 */
+ (void)gettingTheStateOfZigbeeNetworkingCallback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] gettingTheStateOfZigbeeNetworkingCallback:callback];
}



/**
 获取成员信息
 
 @param userId 仅在希望查询某个特定成员时传入 0为查询全部
 @param callback
 */
+ (void)getMemberInformationUserId:(int)userId callback:(HMBluetoothCmdCallback)callback; {
    [[HMBluetoothLockManager defaultManager] getMemberInformationUserId:userId callback:callback];
}


/**
 增加成员
 
 @param callback
 */
+ (void)addMembersCallback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] addMembersCallback:callback];
}


/**
 删除成员
 
 @param callback
 */
+ (void)deleteMembersUserId:(int)userId callback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] deleteMembersUserId:userId callback:(HMBluetoothCmdCallback)callback];

}


/**
 添加用户验证信息
 
 @param userId 添加用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 @param value 表示密码，如果 item 是“pwdx” 格式时起作用，是“fpx”格式 传nil
 @param callback
 */
+ (void)addingUserAuthenticationUserId:(int)userId item:(NSString *)item value:(NSString *)value callback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] addingUserAuthenticationUserId:userId item:item value:value callback:callback];
}


/**
 删除用户验证信息
 
 @param userId 删除用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 */
+ (void)deleteUserAuthenticationUserId:(int)userId item:(NSString *)item callback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] deleteUserAuthenticationUserId:userId item:item callback:callback];
}

/**
 用户信息同步
 
 @param callback
 */
+ (void)userInformationSynchronizationCallback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager  defaultManager] userInformationSynchronizationCallback:callback];
}

/**
 将门锁用户信息同步到服务器
 
 @param callback
 */
+ (void)serverUserInformationSynchronizationUserList:(NSDictionary *)paload {
    [[HMBluetoothLockManager defaultManager] serverUserInformationSynchronizationUserList:paload];
}


/**
 保存门锁的最新更新时间到服务器
 
 @param device
 @param updateTime 门锁的最新更新时间
 */
+ (void)updateUserUpdateTime:(HMDevice *)device updateTime:(int)updateTime {
    [[HMBluetoothLockManager defaultManager] updateUserUpdateTime:device updateTime:updateTime];
}

/**
 取消指纹录入
 
 @param userId 取消指纹录入用户id
 @param callback
 */
+ (void)cancellationOfFingerprintEntryUserId:(int)userId callback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] cancellationOfFingerprintEntryUserId:userId callback:callback];
}


/**
 启动热点扫描
 
 @param callback
 */
+ (void)hotSpotScanCallback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] hotSpotScanCallback:callback];
}


/**
 热点信息传输
 
 @param seq wifi的序列号
 @param pwd wifi的密码
 @param callback
 */
+ (void)hotInformationTransmissionSeq:(NSInteger)seq pwd:(NSString *)pwd callback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] hotInformationTransmissionSeq:seq pwd:pwd callback:callback];
}

/**
 读门锁里面的开锁记录
 
 @param time 读该时间之后的记录
 @param callback
 */
+ (void)readOpenDoorRecord:(int)time callback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] readOpenDoorRecord:time callback:callback];
}

/**
 上传门锁里面的状态到服务器，这个方法会调用 readOpenDoorRecord，然后直接上传到服务器
 
 @param device 当前设备
 @param callback
 */
+ (void)uploadDoorRecordToServerDevice:(HMDevice *)device callback:(HMBluetoothCmdCallback)callback {
    [[HMBluetoothLockManager defaultManager] uploadDoorRecordToServerDevice:device callback:callback];
}

+ (void)resetLockPaired:(HMDevice *)device paired:(int)paried {
    [[HMBluetoothLockManager defaultManager] resetLockPaired:device paired:paried];
}


+ (void)startFirmwareUpdateDevice:(HMDevice *)device filesArrays:(NSArray<HMFirmwareModel *>*)fileArray {
    [[HMBluetoothLockManager defaultManager] startFirmwareUpdateDevice:device filesArrays:fileArray];
}

+ (FirmwareUpdateStatus)firmwareUpdateStatus {
    return [[HMBluetoothLockManager defaultManager] firmwareUpdateStatus];
}

+ (int)firmwareUpdateReconnectBluetoothLeftSecond {
    return [[HMBluetoothLockManager defaultManager] firmwareUpdateReconnectBluetoothLeftSecond];
}

/**
 文件传输进度
 
 @return
 */
+ (int)firmwareTransmissionPercent {
    return [[HMBluetoothLockManager defaultManager] firmwareTransmissionPercent];
}


/**
 获取当前正在升级的设备，没有升级时为nil
 
 @return
 */
+ (HMDevice *)getUpdatingDevice {
    return [[HMBluetoothLockManager defaultManager] getUpdatingDevice];
}


/**
 销毁蓝牙门锁模块，释放资源
 */
+ (void)destroyBluetoothManager {
    [[HMBluetoothLockManager defaultManager] destroyBluetoothManager];
}
@end
