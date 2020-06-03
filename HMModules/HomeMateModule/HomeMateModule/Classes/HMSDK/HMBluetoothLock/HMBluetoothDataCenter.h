//
//  HMBluetoothDataCenter.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/10/25.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMBluetoothCmd.h"

@class HMTypes;

//传输到这个大小，要等门锁的响应之后再接着传

static int pktHexSize = 1024;

@interface HMBluetoothDataCenter : NSObject
- (void)sendCmd:(HMBluetoothCmd *)cmd;

/// 扫描门锁，包括扫描门锁、与门锁握手两个环节，只有扫描到设备握手成功才返回正确
/// @param bleMac 扫描指定bleMac
/// @param callback callback
- (void)scanPeripheralBlueMac:(NSString *)bleMac callback:(HMBluetoothCmdCallback)callback;

- (void)disconnectBluetooth;

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
@end
