//
//  HMC1LockAPI.m
//  HomeMateSDK
//
//  Created by peanut on 2019/3/19.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMC1LockAPI.h"
#import "HMDeviceConfig+C1Lock.h"
@implementation HMC1LockAPI

+ (BOOL)isConnectToDevice:(HMDevice *)device {
    
   return  [[HMDeviceConfig defaultConfig] connectedToDevice:device];
    
}

/**
 增加成员
 
 @param device 当前设备
 @param callback 回调
 */
+ (void)addMembersDevice:(HMDevice *)device
                callback:(HMC1LockCallBack)callback {
                    [[HMDeviceConfig defaultConfig] addMembersDevice:device callback:callback];
}

/**
 删除成员
 
 @param device 当前设备
 @param callback 回调
 */
+ (void)deleteMembersDevice:(HMDevice *)device
                     userId:(int)userId
                   callback:(HMC1LockCallBack)callback {
    
    [[HMDeviceConfig defaultConfig] deleteMembersDevice:device
                                                 userId:userId
                                               callback:callback];
}


/**
 获取用户信息
 
 @param device 当前设备
 @param userId 当前用户
 @param callback 回调
 */
+ (void)getMemberInformation:(HMDevice *)device
                      userId:(int)userId
                    callback:(HMC1LockCallBack)callback {
    
    [[HMDeviceConfig defaultConfig] getMemberInformation:device
                                                  userId:userId
                                                callback:callback];
    
}


/**
 停止读取门锁记录
 
 @param device 当前设备
 @param callback 回调
 */
+ (void)stopReadOpenDoorRecord:(HMDevice *)device
                      callback:(HMC1LockCallBack)callback {
    [[HMDeviceConfig defaultConfig] stopReadOpenDoorRecord:device
                                                  callback:callback];
    
}


/**
 读取开门信息
 
 @param device 当前设备
 @param callback 回调
 */
+ (void)readOpenDoorRecord:(HMDevice *)device
                  callback:(HMC1LockCallBack)callback {
    [[HMDeviceConfig defaultConfig] readOpenDoorRecord:device
                                              callback:callback];

}

/**
 添加用户验证信息
 
 @param device 当前设备
 @param userId 添加用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 @param value 表示密码，如果 item 是“pwdx” 格式时起作用，是“fpx”格式 传nil
 @param callback 回调
 */
+ (void)addingUserAuthenticationDevice:(HMDevice *)device
                                userId:(int)userId
                                  item:(NSString *)item
                                 value:(NSString *)value
                              callback:(HMC1LockCallBack)callback {
    [[HMDeviceConfig defaultConfig] addingUserAuthenticationDevice:device
                                                            userId:userId
                                                              item:item
                                                             value:value
                                                          callback:callback];
}

/**
 删除用户验证信息
 
 @param device 当前设备
 @param userId 删除用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 */
+ (void)deleteUserAuthenticationDevice:(HMDevice *)devie
                                userId:(int)userId
                                  item:(NSString *)item
                              callback:(HMC1LockCallBack)callback {
    [[HMDeviceConfig defaultConfig] deleteUserAuthenticationDevice:devie
                                                            userId:userId
                                                              item:item
                                                          callback:callback];
    
}

/**
 取消指纹录入
 
 @param device 当前设备
 @param userId 取消指纹录入用户id
 @param callback 回调
 */
+ (void)cancellationOfFingerprintEntryDevice:(HMDevice *)device
                                      userId:(int)userId
                                    callback:(HMC1LockCallBack)callback {
    [[HMDeviceConfig defaultConfig] cancellationOfFingerprintEntryDevice:device userId:userId callback:callback];
}

/**
 取消录入RF卡
 
 @param device 当前设备
 @param userId 当前用户
 @param callback 回调
 */
+ (void)cancelCelloctionRFInfo:(HMDevice *)device
                        userId:(int)userId
                      callback:(HMC1LockCallBack)callback{
    [[HMDeviceConfig defaultConfig] cancelCelloctionRFInfo:device userId:userId callback:callback];
}


/**
 设置门锁音量
 
 @param device 当前设备
 @param value 音量大小，范围 1 - 4
 @param callback 回调
 */
+ (void)setLockVolum:(HMDevice *)device
               value:(int)value
            callback:(HMC1LockCallBack)callback{
    [[HMDeviceConfig defaultConfig] setLockVolum:device value:value callback:callback];
}

/**
 退出AP模式
 
 @param device 当前设备
 @param callback 回调
 */
+ (void)stopAPModel:(HMDevice *)device callback:(HMC1LockCallBack)callback {
    [[HMDeviceConfig defaultConfig] stopAPModel:device callback:callback];
}

/**
 获取门锁里面用户信息
 
 @param callback
 */
+ (void)userInformationSynchronization:(HMDevice *)device callback:(HMC1LockCallBack)callback{
    [[HMDeviceConfig defaultConfig] userInformationSynchronization:device callback:callback];
}
@end
