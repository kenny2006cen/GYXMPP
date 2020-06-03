//
//  HMBluetoothEnDecoder.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/10/23.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMBluetoothCmd.h"
@interface HMBluetoothEnDecoder : NSObject

/**
 按协议拼接要发送的命令

 @param cmd 要发送的命令
 @return 拼接的数据
 */
+ (NSData *)enCoderCmd:(HMBluetoothCmd *)cmd;



/**
 解析接收到的数据

 @param data 接收的数据
 @return 解析到的cmd  解析错误返回nil
 */
+ (HMBluetoothCmd *)deCoderData:(NSData *)data;


/**
 判断包头是否有错误
 
 @param headData 包头数据
 @return YES 包头错误  NO 包头正确
 */
+ (BOOL)headError:(NSData *)headData;


/**
 计算包的长度

 @param data 表示包长度的data
 @return 包的长度
 */
+ (int)headLenth:(NSData *)data;

@end
