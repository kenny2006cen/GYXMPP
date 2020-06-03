//
//  HMBlurtoothLockManager.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/10/23.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HMConstant.h"

@class HMDevice;

@interface HMBluetoothLockModel : NSObject
@property (nonatomic, strong)NSString * ModelID;
@property (nonatomic, strong)NSString * hardwareVersion;
@property (nonatomic, strong)NSString * bleMAC;
@property (nonatomic, strong)NSString * mcuUniqueID;
@property (nonatomic, strong)NSString * zigbeeMAC;
@property (nonatomic, strong)NSString * bleVersion;
@property (nonatomic, strong)NSString * mcuVerion;
@property (nonatomic, strong)NSString * zigbeeVersion;
@property (nonatomic, assign)int nwkStatus;
@property (nonatomic, assign)int paried;
@end


@interface HMBluetoothLockManager : NSObject
+ (HMBluetoothLockManager *)defaultManager;


/**
 当前配置成功的device

 @return HMDevice
 */
- (HMDevice *)addSuccessDevice;

/**
获取门锁的私钥
 */
- (NSString *)getLockPrivateKey;

/**
 保存蓝牙获取的门锁信息

 @param lockModel  lockModel
 */
- (void)saveLockModel:(HMBluetoothLockModel *)lockModel;


/**
 获取当前操作门锁的蓝牙mac地址，没有搜索到门锁为nil

 @return mac地址
 */
- (NSString *)getCurrentLockBleMac;



/**
 扫描到门锁之后要保存

 @param bleMac bleMac
 */
- (void)setCurrentLockBleMac:(NSString *)bleMac;

/**
 获取门锁的zigbee门锁状态

 @param callback 回调
 */
- (void)getNetworkInformationOfDoorLockCallback:(HMBluetoothCmdCallback)callback;


/**
 查询是否有在线的主机
 */
- (void)checkOnlineEmbHubCallback:(HMBluetoothCmdCallback)callback;

/**
 1、向服务器绑定门锁，这个过程请保证蓝牙不会断开，因为这个过程还会通过蓝牙跟门锁通信
 2、调用这个方法之前，务必调用握手命令，根据握手命令返回的状态做不同的处理
 
 @param errorCode  deviceHandshakeCallback: 返回的errorCode
 @param callback  回调
 */
- (void)addLockToServerBluetoothLockErrorCode:(HMBluetoothLockStatusCode)errorCode callback:(HMBluetoothCmdCallback)callback;

/**
 获取当前蓝牙的状态
 
 @return 蓝牙的状态
 */
- (HMCBManagerState)bluetoothState;

/**
 判断蓝牙是否打开
 
 @return YES 打开 NO 没打开
 */
- (BOOL)bluetoothOpen;


/**
 判断是否连接的是bleMac
 
 @return YES 是的 NO 不是
 */
- (BOOL)bluetoothConnectToBlueMac:(NSString *)bleMac;

/**
 扫描门锁，包括扫描门锁、与门锁握手两个环节，只有扫描到设备握手成功才返回正确


 @param bleMac 扫描指定bleMac 如果为nil 随机搜索一个
 @param callback callback
 */
- (void)scanPeripheralBlueMac:(NSString *)bleMac callback:(HMBluetoothCmdCallback)callback;


/**
 清除私钥

 @param callback  callback
 */
- (void)cleanPrSivateKeyCallback:(HMBluetoothCmdCallback)callback;

/**
 设备握手命令，主要判断密钥是否正确

 @param callback callback
 */
- (void)deviceHandshakeCallback:(HMBluetoothCmdCallback)callback;


/**
 获取私钥

 @param callback callback
 */
- (void)getPrivatekeyCallback:(HMBluetoothCmdCallback)callback;


/**
 用户身份验证

 @param callback callback
 */
- (void)userAuthenticationCallback:(HMBluetoothCmdCallback)callback;


/**
 时间同步命令

 @param callback callback
 */
- (void)timeSynchronizationCallback:(HMBluetoothCmdCallback)callback;


/**
 获取设备信息

 @param callback callback
 */
- (void)getEquipmentInformationCallback:(HMBluetoothCmdCallback)callback;


/**
Zigbee组网控制命令(组网 or 清网)


 @param nwkcmd 0 : 操作成功，开启组网  1 : 结束组网  2 : 清除组网
 @param callback callback
 */
- (void)zigbeeNetworkControlNWKCmd:(int)nwkcmd callback:(HMBluetoothCmdCallback)callback;


/**
获取Zigbee组网状态命令


 @param callback callback
 */
- (void)gettingTheStateOfZigbeeNetworkingCallback:(HMBluetoothCmdCallback)callback;



/**
 获取成员信息
 
 @param userId 仅在希望查询某个特定成员时传入 0为查询全部
 @param callback callback
 */
- (void)getMemberInformationUserId:(int)userId callback:(HMBluetoothCmdCallback)callback;


/**
增加成员

 @param callback callback
 */
- (void)addMembersCallback:(HMBluetoothCmdCallback)callback;

/**
 删除成员
 
 @param callback callback
 */
- (void)deleteMembersUserId:(int)userId callback:(HMBluetoothCmdCallback)callback;



/**
 获取门锁里面用户信息

 @param callback callback
 */
- (void)userInformationSynchronizationCallback:(HMBluetoothCmdCallback)callback;


/**
 将门锁用户信息同步到服务器
 
 */
- (void)serverUserInformationSynchronizationUserList:(NSDictionary *)paload;


/**
 保存门锁的最新更新时间到服务器

 @param device  device
 @param updateTime 门锁的最新更新时间
 */
- (void)updateUserUpdateTime:(HMDevice *)device updateTime:(int)updateTime;


/**
 添加用户验证信息
 
 @param userId 添加用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 @param value 表示密码，如果 item 是“pwdx” 格式时起作用，是“fpx”格式 传nil
 @param callback callback
 */
- (void)addingUserAuthenticationUserId:(int)userId item:(NSString *)item value:(NSString *)value callback:(HMBluetoothCmdCallback)callback;


/**
 删除用户验证信息
 
 @param userId 删除用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 */
- (void)deleteUserAuthenticationUserId:(int)userId item:(NSString *)item callback:(HMBluetoothCmdCallback)callback;

/**
 取消指纹录入
 
 @param userId 取消指纹录入用户id
 @param callback callback
 */
- (void)cancellationOfFingerprintEntryUserId:(int)userId callback:(HMBluetoothCmdCallback)callback;


/**
 启动热点扫描
 
 @param callback callback
 */
- (void)hotSpotScanCallback:(HMBluetoothCmdCallback)callback;


/**
 热点信息传输

 @param seq wifi的序列号
 @param pwd wifi的密码
 @param callback callback
 */
- (void)hotInformationTransmissionSeq:(NSInteger)seq pwd:(NSString *)pwd callback:(HMBluetoothCmdCallback)callback;



/**
 读门锁里面的开锁记录

 @param time 读该时间之后的记录
 @param callback  callback
 */
- (void)readOpenDoorRecord:(int)time callback:(HMBluetoothCmdCallback)callback;


/**
 上传门锁里面的状态到服务器，这个方法会调用 readOpenDoorRecord，然后直接上传到服务器
 
 @param device 当前设备
 @param callback callback
 */
- (void)uploadDoorRecordToServerDevice:(HMDevice *)device callback:(HMBluetoothCmdCallback)callback;


/**
 重新设置是否是配套门锁

 @param device device
 @param paried 0 不是 1 是
 */
- (void)resetLockPaired:(HMDevice *)device paired:(int)paried;



- (void)startFirmwareUpdateDevice:(HMDevice *)device filesArrays:(NSArray<HMFirmwareModel *>*)fileArray;


/**
 设置是否正在执行升级操作

 @param firmwareUpdate YES 是 NO 否
 */
- (void)setFirmwareUpdate:(BOOL)firmwareUpdate;


- (FirmwareUpdateStatus)firmwareUpdateStatus;


/**
 获取当前正在升级的设备，没有升级时为nil

 @return  HMDevice
 */
- (HMDevice *)getUpdatingDevice;


/**
 获取升级倒计时

 @return 倒计时
 */
- (int)firmwareUpdateReconnectBluetoothLeftSecond;


- (int)firmwareTransmissionPercent;

/**
 判断是否正在升级

 @return YES 是 NO 否
 */
- (BOOL)getFirmwareUpdate;
/**
 销毁蓝牙门锁模块，释放资源
 */
- (void)destroyBluetoothManager;
@end
