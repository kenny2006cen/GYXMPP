//
//  HMBluetoothLockAPI.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/10/23.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <HomeMateSDK.h>

typedef NS_ENUM(NSInteger,FirmwareUpdateStatus) {
    FirmwareUpdateStatusNormal,//正常状态
    FirmwareUpdateStatusTransmission,//正在传输文件
    FirmwareUpdateStatusTransmissionFail,//传输文件失败
    FirmwareUpdateStatusSearchBluetooth,//传输文件成功，正在搜索门锁
    FirmwareUpdateStatusUpdateSuccess,//升级成功
    FirmwareUpdateStatusGetDeviceInfo,//正在获取版本信息
    FirmwareUpdateStatusGetDeviceInfoFail,//获取版本信息失败
    FirmwareUpdateStatusUpdateDeviceInfoFail,//上传版本信息失败
    FirmwareUpdateStatusConnectLockFail,//连接门锁失败
    FirmwareUpdateStatusUpdateFail,//升级失败
};

typedef void(^HMBluetoothCmdCallback)(HMBluetoothLockStatusCode errorCode,NSDictionary * payload);


@interface HMBluetoothLockAPI : HMBaseAPI


/**
 调用其他方法之前要先初始化一下蓝牙管理类，因为要首先确定蓝牙是否打开
 */
+ (void)initBluetoothManager;

#pragma mark - 业务逻辑相关

/**
 当前配置成功的device，只有添加成功才有值
 
 */
+ (HMDevice *)addSuccessDevice;

/**
 查询是否有在线的主机
 */
+ (void)checkOnlineEmbHubCallback:(HMBluetoothCmdCallback)callback;

/**
 获取当前操作门锁的蓝牙mac地址，没有搜索到门锁为nil
 
 @return NSString mac地址
 */
+ (NSString *)getCurrentLockBleMac;

/**
 1、向服务器绑定门锁，这个过程请保证蓝牙不会断开，因为这个过程还会通过蓝牙跟门锁通信
 2、调用这个方法之前，务必调用握手命令，根据握手命令返回的状态做不同的处理
 
 @param errorCode  deviceHandshakeCallback: 返回的errorCode
 @param callback 回调
 */
+ (void)addLockToServerBluetoothLockErrorCode:(HMBluetoothLockStatusCode)errorCode callback:(HMBluetoothCmdCallback)callback;



#pragma mark - 蓝牙相关的API


/**
 获取当前蓝牙的状态

 */
+ (HMCBManagerState)bluetoothState;


/**
 判断蓝牙是否打开

 @return YES 打开 NO 没打开
 */
+ (BOOL)bluetoothOpen;

/**
 判断是否连接的是bleMac
 
 @return YES 是的 NO 不是
 */
+ (BOOL)bluetoothConnectToBlueMac:(NSString *)bleMac;

/**
 扫描门锁，包括扫描门锁、与门锁握手两个环节，只有扫描到设备握手成功才返回正确
 
 
 @param bleMac 扫描指定bleMac 如果为nil 随机搜索一个
 */
+ (void)scanPeripheralBlueMac:(NSString *)bleMac callback:(HMBluetoothCmdCallback)callback;

/**
 清除私钥
 
 */
+ (void)cleanPrSivateKeyCallback:(HMBluetoothCmdCallback)callback;

/**
 设备握手命令，主要判断密钥是否正确
 
 @param callback 回调
 */
+ (void)deviceHandshakeCallback:(HMBluetoothCmdCallback)callback;


/**
 获取私钥
 
 @param callback 回调
 */
+ (void)getPrivatekeyCallback:(HMBluetoothCmdCallback)callback;


/**
 用户身份验证
 
 */
+ (void)userAuthenticationCallback:(HMBluetoothCmdCallback)callback;


/**
 时间同步命令
 
 */
+ (void)timeSynchronizationCallback:(HMBluetoothCmdCallback)callback;


/**
 获取设备信息
 
 */
+ (void)getEquipmentInformationCallback:(HMBluetoothCmdCallback)callback;


/**
 Zigbee组网控制命令(组网 or 清网)
 
 
 @param nwkcmd 0 : 操作成功，开启组网  1 : 结束组网  2 : 清除组网
 @param callback 回调
 */
+ (void)zigbeeNetworkControlNWKCmd:(int)nwkcmd callback:(HMBluetoothCmdCallback)callback;


/**
 获取Zigbee组网状态命令
 
 
 @param callback 回调
 */
+ (void)gettingTheStateOfZigbeeNetworkingCallback:(HMBluetoothCmdCallback)callback;



/**
 获取成员信息
 
 @param userId 仅在希望查询某个特定成员时传入 0为查询全部
 @param callback 回调
 */
+ (void)getMemberInformationUserId:(int)userId callback:(HMBluetoothCmdCallback)callback;


/**
 增加成员
 
 */
+ (void)addMembersCallback:(HMBluetoothCmdCallback)callback;


/**
删除成员
 */
+ (void)deleteMembersUserId:(int)userId callback:(HMBluetoothCmdCallback)callback;


/**
 用户信息同步
 */
+ (void)userInformationSynchronizationCallback:(HMBluetoothCmdCallback)callback;


/**
 将门锁用户信息同步到服务器
 
 */
+ (void)serverUserInformationSynchronizationUserList:(NSDictionary *)paload;


/**
 保存门锁的最新更新时间到服务器
 
 @param device 门锁对象
 @param updateTime 门锁的最新更新时间
 */
+ (void)updateUserUpdateTime:(HMDevice *)device updateTime:(int)updateTime;

/**
 添加用户验证信息
 
 @param userId 添加用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 @param value 表示密码，如果 item 是“pwdx” 格式时起作用，是“fpx”格式 传nil
 @param callback 回调
 */
+ (void)addingUserAuthenticationUserId:(int)userId
                                  item:(NSString *)item
                                 value:(NSString *)value
                              callback:(HMBluetoothCmdCallback)callback;


/**
 删除用户验证信息
 
 @param userId 删除用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 */
+ (void)deleteUserAuthenticationUserId:(int)userId
                                  item:(NSString *)item
                              callback:(HMBluetoothCmdCallback)callback;

/**
 取消指纹录入
 
 @param userId 取消指纹录入用户id
 */
+ (void)cancellationOfFingerprintEntryUserId:(int)userId callback:(HMBluetoothCmdCallback)callback;


/**
 启动热点扫描
 
 */
+ (void)hotSpotScanCallback:(HMBluetoothCmdCallback)callback;


/**
 热点信息传输
 
 @param seq wifi的序列号
 @param pwd wifi的密码
 */
+ (void)hotInformationTransmissionSeq:(NSInteger)seq pwd:(NSString *)pwd callback:(HMBluetoothCmdCallback)callback;

/**
 读门锁里面的开锁记录
 
 @param time 读该时间之后的记录
 @param callback 回调
 */
+ (void)readOpenDoorRecord:(int)time callback:(HMBluetoothCmdCallback)callback;


/**
 上传门锁里面的状态到服务器，这个方法会调用 readOpenDoorRecord，然后直接上传到服务器
 
 @param device 当前设备
 */
+ (void)uploadDoorRecordToServerDevice:(HMDevice *)device callback:(HMBluetoothCmdCallback)callback;


/**
 开始升级门锁

 @param device 升级对象
 @param fileArray 固件数组
 */
+ (void)startFirmwareUpdateDevice:(HMDevice *)device filesArrays:(NSArray<HMFirmwareModel *>*)fileArray;


/**
 获取升级状态，当状态有改变时发送 kNOTIFICATION_FIRMWAREDATATRANSMISSIONSTATUSCHANGE 的通知，接到通知之后，调用该方法获取响应的状态

 */
+ (FirmwareUpdateStatus)firmwareUpdateStatus;


/**
 获取升级过程中重新连接蓝牙倒计时剩余的秒数

 */
+ (int)firmwareUpdateReconnectBluetoothLeftSecond;



/**
 文件传输进度：当FirmwareUpdateStatus的状态是FirmwareUpdateStatusTransmission时，可获取当前传输进度；文件每写成功一次会发送kNOTIFICATION_FIRMWAREDATATRANSMISSIONSPERCENT的通知，然后再来获取进度；取值为1-100；

 */
+ (int)firmwareTransmissionPercent;

/**
 获取当前正在升级的设备，没有升级时为nil
 
 */
+ (HMDevice *)getUpdatingDevice;



+ (void)resetLockPaired:(HMDevice *)device paired:(int)paried;


/**
 销毁蓝牙门锁模块，释放资源
 */
+ (void)destroyBluetoothManager;
@end
