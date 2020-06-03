//
//  HMMessageAPI.h
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/7/10.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseAPI.h"
#import "HMConstant.h"

// ************ //
 // MARK:  以下方法每次只读取20条数据
// ************ //

// 每次读取的数量
#define kHMMessageAPI_PerReadCount 20

@interface HMMessageAPI : HMBaseAPI

#pragma 读取普通消息
/**
 读取某一家庭最新的普通消息
 @param familyId familyId
 @param completion 回调Server 数据
 */
+ (void)readNewestCommonMsgFromServerWithFamilyId:(NSString *)familyId messageType:(HMMessageType)messageType completion:(commonBlockWithObject)completion;
/**
 读取某一家庭 sequence之前的普通消息 （每条消息都有一个 sequence ）
 @param sequence 消息的序号
 @param familyId familyId
 @param completion 回调Server 数据
 */
+ (void)readOldCommonMsgBeforeSequence:(int)sequence familyId:(NSString *)familyId messageType:(HMMessageType)messageType completion:(commonBlockWithObject)completion;



#pragma 读取安防消息
/**
 读取某一家庭最新的安防消息
 @param familyId familyId
 @param completion 回调Server 数据
 */
+ (void)readNewestSecurityMsgFromServerWithFamilyId:(NSString *)familyId completion:(commonBlockWithObject)completion;


#pragma 读取单个安防设备的消息
/**
 读取单个安防设备最新的状态记录 ： 如传感器，门锁
 @param device 设备实例
 @param completion 回调Server 数据
 */
+ (void)readNewStatusRecordWithSecurityDevice:(HMDevice *)device completion:(commonBlockWithObject)completion;


@end
