//
//  HMBluetoothCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/10/23.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeMateSDK.h"
@class HMBluetoothCmd;

static int MaxRetransmissionTimes = 3;

@protocol HMBluetoothCmdCallback <NSObject>

/// 蓝牙命令回调
/// @param cmd cmd
/// @param isTimeout 是否超时
/// @param isBluetoothDisconnect 是否与蓝牙断开
-(void)onResponseWithCmd:(HMBluetoothCmd *)cmd
               isTimeout:(BOOL)isTimeout
   isBluetoothDisconnect:(BOOL)isBluetoothDisconnect;

@end

@interface HMBluetoothCmd : NSObject


/**
 发出请求的开始时间戳，用于超时；由超时管理器操作它；
 */
@property (nonatomic, strong) NSDate* startTimestamp;

/**
 请求超时秒数
 */
@property (nonatomic, assign) NSInteger timeoutSeconds;

/**
 重发次数
 */
@property (nonatomic, assign) NSInteger retransmissionTimes;

/**
 0~2^16的随机数 包流水序号,用于区分重发包 2字节
 */
@property (nonatomic,assign) short serial;

/**
 若此位置 1,消息必须应答 若ACK Flag 置1时, 此位 不起效
 */
@property (nonatomic,assign) int ACKRequire;

/**
 应答消息需把此位置 1
 */
@property (nonatomic, assign) int ACKFlag;

/**
 0 : 公钥 1 : 私钥
 */
@property (nonatomic, assign) int EncryptKey;


/**
 帧控制命令 暂时填 0
 */
@property (nonatomic, assign)int frameCommand;

/**
 根据不同的控制指令, Payload 段相应变化
 */
@property (nonatomic, strong) NSDictionary * payload;


/**
 命令的回调
 */
@property (nonatomic, copy) HMBluetoothCmdCallback callback;

@end



