//
//  HMCustomChannel.h
//  HomeMateSDK
//
//  Created by liqiang on 2018/6/7.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@class HMDevice;

@interface HMCustomChannel : HMBaseModel

@property (copy,nonatomic) NSString * customChannelId;//自定义频道id
@property (copy,nonatomic) NSString * deviceId;//虚拟设备id
@property (assign,nonatomic) int channel;//频道号
@property (copy,nonatomic) NSString * channelName;//频道名字
@property (assign,nonatomic)  int sequence;//排序
@property (copy,nonatomic)NSString *stbChannelId;//机顶盒频道id 为空表示为用户自定义 不为空表示公共


- (BOOL)deleteObject;


/**
 设备所有自定义频道

 @param device 小方虚拟设备
 */
+ (NSMutableArray *)customChannelWithDevice:(HMDevice *)device;


/**
 小方所有自定义频道

 @param device 小方虚拟设备
 */
+ (NSMutableArray *)allChannelWithDevice:(HMDevice *)device;

/**
 删除小方虚拟设备的公共自定义频道
 
 @param device 小方虚拟设备
 */
+ (BOOL)deletePublicObjectWithDevice:(HMDevice *)device;

/**
 删除小方虚拟设备的用户自定义频道
 
 @param device 小方虚拟设备
 */
+ (BOOL)deleteCustomChannelWithDevice:(HMDevice *)device;


/**
 删除小方虚拟设备的所有自定义频道（包括自用自定义和公共频道）

 @param device 小方虚拟设备
 */
+ (BOOL)deleteAllObjectWithDevice:(HMDevice *)device;

@end
