//
//  HMCommonChannelUtil.h
//  HomeMate
//
//  Created by liqiang on 2018/6/5.
//  Copyright © 2018年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMConstant.h"

@interface HMCommonChannelUtil : NSObject

+ (HMCommonChannelUtil *)shareUtil ;//DEPRECATED_MSG_ATTRIBUTE("这里可以不使用单例，后面某个版本可能会去掉，建议使用 -init");


/**
 修改自定义频道信息

 @param customChannel 要修改的频道
 @param channelName 频道名字（无修改 填原名字）
 @param channelNum 频道号（无修改 填原频道号）
 @param callback 回调
 */
- (void)updateCustomChannel:(HMCustomChannel *)customChannel
                channelName:(NSString *)channelName
                 channelNum:(int)channelNum
                   callback:(void(^)(HMCustomChannelStatus status,HMCustomChannel * customChannel))callback;


/**
 删除自定义频道

 @param customChannel 要删除的频道
 @param callback 回调
 */
- (void)deleteCustomChannel:(HMCustomChannel *)customChannel
                   callback:(void(^)(HMCustomChannelStatus status))callback;

/**
 获取所有频道

 @param callback 回调
 */
- (void)getChannelList:(void(^)(HMCustomChannelStatus status,NSMutableArray * channelList))callback;


/**
 获取用户添加的频道列表

 @param device 小方的虚拟设备
 @param callback 回调
 */
- (void)getCommonCannelList:(HMDevice *)device
                   callback:(void(^)(HMCustomChannelStatus status,NSMutableArray * customChannelList))callback;


/**
 获取公共频道列表 目前只有四川电信、浙江电信、湖南电信等有数据，这里请求的数据是运营商返回的频道名字跟频道号，不允许用户再设置了

 @param device 小方的虚拟设备
 @param callback 回调
 */
- (void)getPublicCannelList:(HMDevice *)device
                   callback:(void(^)(HMCustomChannelStatus status,NSMutableArray * customChannelList))callback;


/**
 添加常用频道

 @param device 小方的子设备
 @param channelName 频道名字
 @param channelNum 频道号
 @param callback 回调
 */
- (void)addChannel:(HMDevice *)device
       channelName:(NSString *)channelName
        channelNum:(int)channelNum
          callback:(void(^)(HMCustomChannelStatus status,HMCustomChannel * customChannel))callback;

- (void)showErrorTip:(HMCustomChannelStatus)status device:(HMDevice *)device;


/**
 修改小方所在国家

 @param countryId 国家id
 @param countryName 国家名字
 @param device 小方
 @param callback 回调
 */
- (void)uploadCountryId:(NSString *)countryId countryName:(NSString *)countryName device:(HMDevice *)device callback:(commonBlock)callback;


/**
 获取小方或者小方的虚拟设备所在国家ID

 @param device 小方或者小方的虚拟设备
 @return 国家id
 */
- (NSString *)getCountyId:(HMDevice *)device;


/**
 获取小方或者小方的虚拟设备所在国家名字

 @param device 小方或者小方的虚拟设备
 @return 国家名字
 */
- (NSString *)getCountyName:(HMDevice *)device;


/**
 根据频道名字查询频道是否存在  关键字查询

 @param channelName 要查询的频道名字
 @param callback 回调
 */
- (void)queryChannel:(NSString *)channelName
            callback:(void(^)(HMCustomChannelStatus status ,NSArray * data))callback;


/**
 获取http接口的 auth token

 @param callback 回调
 */
- (void)getCommonChannekToken:(void(^)(HMCustomChannelStatus status, NSString *token))callback;
@end
