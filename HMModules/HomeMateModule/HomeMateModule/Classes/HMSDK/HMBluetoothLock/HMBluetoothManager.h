//
//  HMBluetoothManager.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/10/24.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMTypes.h"

static int MAXRECONNECTTIMES = 3;

static BOOL WriteBlueToothWithResponce = NO;

typedef NS_ENUM(NSInteger,HMBluetoothStatus) {
    HMBluetoothStatusNotFoundDevice,
    HMBluetoothStatusPowerOn,
    HMBluetoothStatusPowerOff,
    HMBluetoothStatusDisconnected,
    HMBluetoothStatusGetwriteCharacteristic,
};

@protocol HMBluetoothManagerCallback <NSObject>
/**
 写数据回调

 @param error 成功为nil
 */
- (void)didWriteValueError:(NSError *)error;

/**
 读数据回调
 
 @param error 成功为nil
 */
- (void)didUpdateValue:(NSData *)data error:(NSError *)error;


- (void)connectBluetoothStatus:(HMBluetoothStatus)status;
@end

@interface HMBluetoothManager : NSObject
@property (nonatomic, assign)BOOL bluetoothOpen;
@property (nonatomic, assign) HMCBManagerState bluetoothState;
@property (nonatomic, assign)int  reconnectTimes;
@property (nonatomic, assign)id <HMBluetoothManagerCallback> delegate;
@property (nonatomic, strong)NSString * bleMac;

- (void)writeData:(NSData *)data;

- (void)scanPeripheralBlueMac:(NSString *)bleMac;

- (void)disconnectBluetooth;

/**
 判断是否连接的是bleMac
 
 @return YES 是的 NO 不是
 */
- (BOOL)bluetoothConnectToBlueMac:(NSString *)bleMac;
@end
