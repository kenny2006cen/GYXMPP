//
//  HMDeviceConfig+C1Lock.h
//  HomeMateSDK
//
//  Created by peanut on 2019/3/19.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import <HomeMateSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMDeviceConfig (C1Lock)

/**
 增加成员
 
 @param device 当前设备
 @param callback 回调
 */
- (void)addMembersDevice:(HMDevice *)device
                callback:(HMC1LockCallBack)callback;

/**
 删除成员
 
 @param device 当前设备
 @param callback 回调
 */
- (void)deleteMembersDevice:(HMDevice *)device
                     userId:(int)userId
                   callback:(HMC1LockCallBack)callback;


/**
 获取用户信息
 
 @param device 当前设备
 @param userId 当前用户
 @param callback 回调
 */
- (void)getMemberInformation:(HMDevice *)device
                      userId:(int)userId
                    callback:(HMC1LockCallBack)callback;;

/**
 停止读取门锁记录
 
 @param device 当前设备
 @param callback 回调
 */
- (void)stopReadOpenDoorRecord:(HMDevice *)device
                      callback:(HMC1LockCallBack)callback;;

/**
 读取开门信息
 
 @param device 当前设备
 @param callback 回调
 */
- (void)readOpenDoorRecord:(HMDevice *)device
                  callback:(HMC1LockCallBack)callback;

/**
 添加用户验证信息
 
 @param device 当前设备
 @param userId 添加用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 @param value 表示密码，如果 item 是“pwdx” 格式时起作用，是“fpx”格式 传nil
 @param callback 回调
 */
- (void)addingUserAuthenticationDevice:(HMDevice *)device
                                userId:(int)userId
                                  item:(NSString *)item
                                 value:(NSString *)value
                              callback:(HMC1LockCallBack)callback;

/**
 删除用户验证信息
 
 @param devie 当前设备
 @param userId 删除用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 */
- (void)deleteUserAuthenticationDevice:(HMDevice *)devie
                                userId:(int)userId
                                  item:(NSString *)item
                              callback:(HMC1LockCallBack)callback;

/**
 取消指纹录入
 
 @param device 当前设备
 @param userId 取消指纹录入用户id
 @param callback 回调
 */
- (void)cancellationOfFingerprintEntryDevice:(HMDevice *)device
                                      userId:(int)userId
                                    callback:(HMC1LockCallBack)callback;

/**
 取消录入RF卡
 
 @param device 当前设备
 @param userId 当前用户
 @param callback 回调
 */
- (void)cancelCelloctionRFInfo:(HMDevice *)device
                        userId:(int)userId
                      callback:(HMC1LockCallBack)callback;

/**
 设置门锁音量
 
 @param device 当前设备
 @param value 音量大小，范围 1 - 4
 @param callback 回调
 */
- (void)setLockVolum:(HMDevice *)device
               value:(int)value
            callback:(HMC1LockCallBack)callback;

/**
 退出AP模式
 
 @param device 当前设备
 @param callback 回调
 */
- (void)stopAPModel:(HMDevice *)device
           callback:(HMC1LockCallBack)callback;

/**
 获取门锁里面用户信息
 
 @param callback
 */
- (void)userInformationSynchronization:(HMDevice *)device callback:(HMC1LockCallBack)callback;
@end

NS_ASSUME_NONNULL_END
