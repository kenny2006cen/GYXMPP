//
//  HMCountdownAPI.h
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/5/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseAPI.h"

#import "HMTypes.h"
@class HMCountdownModel;

@interface HMCountdownAPI : HMBaseAPI


/**
 创建倒计时 set a count down 

 @param deviceId 设备deviceId
 @param uid 设备uid
 @param value1  0：开 1：关
 @param time 倒计时长
 @param completion 返回 HMCountdownModel 实例
 */
+ (void)setCountDownWithDeviceId:(NSString *)deviceId uid:(NSString *)uid value1:(int)value1 time:(int)time completion:(commonBlockWithObject)completion;

/**
 修改倒计时 modify a count down
 
 @param cdModel 倒计时对象 HMCountdownModel 实例
 @param value1  0：开 1：关
 @param time 倒计时长，单位：分钟
 @param completion 回调方法返回已经修改成功的  对象的实例 return HMCountdownModel instance
 */
+ (void)modifyCountDownObj:(HMCountdownModel *)cdModel value1:(int)value1 time:(int)time completion:(commonBlockWithObject)completion;

/**
 删除倒计时 delete count down

 @param cdModel 倒计时对象 HMCountdownModel 实例
 @param completion 回调服务器返回的数据
 */
+ (void)deleteCountDownObj:(HMCountdownModel *)cdModel completion:(commonBlockWithObject)completion;


/**
 激活倒计时 activate count down

 @param cdModel 倒计时对象 HMCountdownModel 实例
 @param isPause 激活标志： 0：表示暂停 1：表示生效
 @param completion 成功：回调已经激活成功的 HMCountdownModel instance 失败：返回nil
 */
+ (void)activateCountDownObj:(HMCountdownModel *)cdModel isPause:(BOOL)isPause completion:(commonBlockWithObject)completion;


@end
