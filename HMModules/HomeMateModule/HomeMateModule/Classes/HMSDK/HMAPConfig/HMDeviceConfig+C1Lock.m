//
//  HMDeviceConfig+C1Lock.m
//  HomeMateSDK
//
//  Created by peanut on 2019/3/19.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMDeviceConfig+C1Lock.h"

@implementation HMDeviceConfig (C1Lock)

/**
 增加成员
 
 @param device 当前设备
 @param callback 回调
 */
- (void)addMembersDevice:(HMDevice *)device
                callback:(HMC1LockCallBack)callback {
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_LOCK_ADDUSER;
    msg.timeoutSeconds = 10;
    NSDictionary *dic = @{@"cmd":[NSNumber numberWithInt:msg.cmd],@"uid":device.uid,@"serial":@([BLUtility getRandomNumber:0 to:10000])};
    
    msg.msgBody =dic;
    
     [self sendLockMsg:msg callback:callback];
}

/**
 删除成员
 
 @param device 当前设备
 @param callback 回调
 */
- (void)deleteMembersDevice:(HMDevice *)device
                     userId:(int)userId
                   callback:(HMC1LockCallBack)callback {
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_LOCK_DELETEUSER;
    msg.timeoutSeconds = 10;
    NSDictionary *dic = @{@"cmd":[NSNumber numberWithInt:msg.cmd],@"uid":device.uid,@"userId":@(userId),@"serial":@([BLUtility getRandomNumber:0 to:10000])};
    
    msg.msgBody =dic;
    
     [self sendLockMsg:msg callback:callback];
}


/**
 获取用户信息

 @param device 当前设备
 @param userId 当前用户
 @param callback 回调
 */
- (void)getMemberInformation:(HMDevice *)device
                      userId:(int)userId
                    callback:(HMC1LockCallBack)callback {
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_LOCK_GETUSERINFO;
    msg.timeoutSeconds = 10;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    if(userId != -1){
        [dict setObject:@(userId) forKey:@"userId"];
    }
    [dict setObject:@(VhAPConfigCmd_LOCK_GETUSERINFO) forKey:@"cmd"];
    [dict setObject:@([BLUtility getRandomNumber:0 to:10000]) forKey:@"serial"];
    [dict setObject:device.uid forKey:@"uid"];
    
    msg.msgBody = dict;
    
     [self sendLockMsg:msg callback:callback];
}

/**
 停止读取门锁记录

 @param device 当前设备
 @param callback 回调
 */
- (void)stopReadOpenDoorRecord:(HMDevice *)device
                      callback:(HMC1LockCallBack)callback {
    
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_LOCK_STOPGETOPENRECORD;
    msg.timeoutSeconds = 10;
    NSDictionary *dic = @{@"cmd":[NSNumber numberWithInt:msg.cmd],@"uid":device.uid,@"serial":@([BLUtility getRandomNumber:0 to:10000])};
    
    msg.msgBody =dic;
    
     [self sendLockMsg:msg callback:callback];
    
}

/**
 读取开门信息

 @param device 当前设备
 @param callback 回调
 */
- (void)readOpenDoorRecord:(HMDevice *)device
                  callback:(HMC1LockCallBack)callback {
    
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_LOCK_GETOPENRECORD;
    msg.timeoutSeconds = 10;
    NSDictionary *dic = @{@"cmd":[NSNumber numberWithInt:msg.cmd],@"uid":device.uid,@"serial":@([BLUtility getRandomNumber:0 to:10000])};
    
    msg.msgBody =dic;
    
     [self sendLockMsg:msg callback:callback];
    
}

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
                              callback:(HMC1LockCallBack)callback {
   
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@(userId) forKey:@"userId"];
    [dict setObject:@(VhAPConfigCmd_LOCK_ADDUSERKEY) forKey:@"cmd"];
    [dict setObject:@([BLUtility getRandomNumber:0 to:10000]) forKey:@"serial"];
    [dict setObject:device.uid forKey:@"uid"];

    if (item.length) {
        [dict setObject:item forKey:@"item"];
    }
    if (value.length) {
        [dict setObject:value forKey:@"value"];
    }
    
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_LOCK_ADDUSERKEY;
    msg.timeoutSeconds = 10;
    msg.msgBody =dict;
    
     [self sendLockMsg:msg callback:callback];

    
}

/**
 删除用户验证信息
 
 @param device 当前设备
 @param userId 删除用户userId
 @param item 表示式指纹还是密码，如果是指纹 填“fpx:x=1,2,3...” 如果是密码 填“pwdx:x=1,2,3..”
 */
- (void)deleteUserAuthenticationDevice:(HMDevice *)devie
                                userId:(int)userId
                                  item:(NSString *)item
                              callback:(HMC1LockCallBack)callback {
   
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@(userId) forKey:@"userId"];
    [dict setObject:@(VhAPConfigCmd_LOCK_DELETEUSERKEY) forKey:@"cmd"];
    [dict setObject:devie.uid forKey:@"uid"];
    [dict setObject:@([BLUtility getRandomNumber:0 to:10000]) forKey:@"serial"];

    if (item.length) {
        [dict setObject:item forKey:@"item"];
    }
    
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_LOCK_DELETEUSERKEY;
    msg.timeoutSeconds = 10;
    msg.msgBody =dict;
     [self sendLockMsg:msg callback:callback];
    
    
}

/**
 取消指纹录入
 
 @param device 当前设备
 @param userId 取消指纹录入用户id
 @param callback 回调
 */
- (void)cancellationOfFingerprintEntryDevice:(HMDevice *)device
                                      userId:(int)userId
                                    callback:(HMC1LockCallBack)callback {
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VIHOME_CMD_AP_LOCK_CANCELADDFP;
    msg.timeoutSeconds = 10;
    NSDictionary *dic = @{@"cmd":[NSNumber numberWithInt:msg.cmd],@"userId":@(userId),@"uid":device.uid,@"serial":@([BLUtility getRandomNumber:0 to:10000])};
    
    msg.msgBody =dic;
    
     [self sendLockMsg:msg callback:callback];
    
}


/**
 取消录入RF卡

 @param device 当前设备
 @param userId 当前用户
 @param callback 回调
 */
- (void)cancelCelloctionRFInfo:(HMDevice *)device
                        userId:(int)userId
                      callback:(HMC1LockCallBack)callback{
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_CANCELADDRF;
    msg.timeoutSeconds = 10;
    NSDictionary *dic = @{@"cmd":[NSNumber numberWithInt:msg.cmd],@"userId":@(userId),@"uid":device.uid,@"serial":@([BLUtility getRandomNumber:0 to:10000])};
    
    msg.msgBody =dic;
    
    [self sendLockMsg:msg callback:callback];
}

/**
 设置门锁音量
 
 @param device 当前设备
 @param value 音量大小，范围 1 - 4
 @param callback 回调
 */
- (void)setLockVolum:(HMDevice *)device
               value:(int)value
            callback:(HMC1LockCallBack)callback{
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_LOCK_SETVOLUME;
    msg.timeoutSeconds = 10;
    NSDictionary *dic = @{@"cmd":[NSNumber numberWithInt:msg.cmd],@"volume":@(value),@"uid":device.uid,@"serial":@([BLUtility getRandomNumber:0 to:10000])};
    
    msg.msgBody =dic;
    
    [self sendLockMsg:msg callback:callback];
}

/**
 退出AP模式

 @param device 当前设备
 @param callback 回调
 */
- (void)stopAPModel:(HMDevice *)device
           callback:(HMC1LockCallBack)callback {
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_Quit_AP;
    msg.timeoutSeconds = 10;
    NSDictionary *dic = @{@"cmd":[NSNumber numberWithInt:msg.cmd],@"uid":device.uid,@"serial":@([BLUtility getRandomNumber:0 to:10000])};
    
    msg.msgBody =dic;
    
    [self sendLockMsg:msg callback:callback];
}

/**
 获取门锁里面用户信息
 
 @param callback
 */
- (void)userInformationSynchronization:(HMDevice *)device callback:(HMC1LockCallBack)callback {
    [self.lockUserInfo removeAllObjects];
    HMAPConfigMsg * msg = [[HMAPConfigMsg alloc] init];
    msg.cmd = VhAPConfigCmd_LOCK_ASYNUSERINFO;
    msg.timeoutSeconds = 10;
    NSDictionary *dic = @{@"cmd":[NSNumber numberWithInt:msg.cmd],@"uid":device.uid,@"utc":@(0), @"serial":@([BLUtility getRandomNumber:0 to:10000])};
    
    msg.msgBody =dic;
    
    [self sendLockMsg:msg callback:callback];
    
}

@end
