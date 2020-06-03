//
//  MessagePush.h
//  HomeMate
//
//  Created by liuzhicai on 15/8/25.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@class HMDevice;

typedef NS_ENUM(NSInteger,HMMessagePushType) {
    HMMessagePushTimingTaskTotalSwitch = 0,//定时任务的推送设置 [总开关]
    HMMessagePushTimimgTaskSwitch = 1,//定时任务的推送设置 [分开关]
    HMMessagePushEnergySavingRemindingTotalSwitch = 11,//节能提醒设置 [总开关]
    HMMessagePushEnergySavingRemindingSwitch = 12,//节能提醒设置 [分开关]

};


@interface HMMessagePush : HMBaseModel

@property (nonatomic, strong)NSString *pushId;

@property (nonatomic, strong)NSString *userId;

/**
 *  0：对所有设备的定时任务的推送设置
 1：对单个设备的定时任务的推送设置。如果存在type为0的设置，则以0的设置为准

 */
@property (nonatomic, assign)int type;

@property (nonatomic, strong)NSString *taskId;

/**
 *  0：需要推送
 1：不需要推送

 */
@property (nonatomic, assign)int isPush;

@property (nonatomic, strong) NSString *startTime;

@property (nonatomic, strong) NSString *endTime;

@property (nonatomic, assign) int week;

// 漏电自检
@property (nonatomic, assign) int day;


@property (nonatomic, assign)int authorizedId;

/**
 *  是否有打开提醒功能的COCO
 */
+ (BOOL)isHasOnCoco;

/**
 *  是否有打开提醒功能的传感器
 */
+ (BOOL)isHasOnSensor;

+ (instancetype)objectWithTaskId:(NSString *)TaskId;

/**
 *  所有传感器是否需要推送
 */
+ (BOOL)allSensorsMessageIsNeedPush;

/**
 *  单个传感器是否需要推送
 *  @return YES:推送状态为开， NO：关
 */
+ (BOOL)singleSensorsIsNeedPushWithDeviceId:(NSString *)deviceId;

/**
 *  单个COCO是否需要推送
 */
+ (BOOL)singleCocoIsNeedPushWithDeviceId:(NSString *)deviceId;

/**
 *  所有coco是否需要提醒
 */
+ (BOOL)allCocosMessageIsNeedPush;

/**
 *  更新表
 *
 *  @param isPush 是否需要推送
 *  @param type   推送类型
 *  @param taskId 设备Id
 */
+ (void)updateTableSetIsPush:(int)isPush type:(int)type taskId:(NSString *)taskId;

// 当传感器总开关设置时，分开关的开关要更新
+ (void)updateSensorsPushDataIsPush:(int)isPush;

// 当COCO总开关设置时，分开关的开关要更新
+ (void)updateCocosPushDataIsPush:(int)isPush;

// 当一个分开关打开时，总开关必须打开    type : 0  coco总开关  type : 2  传感器总开关
+ (void)OpenAllSwitchWithType:(int)type;

+ (instancetype)objectWithTaskId:(NSString *)TaskId
                    WithAuthorID:(int )authorId;

// 此方法内部只结合familyId 来查，没有加userId
+ (instancetype)objectWithTaskId:(NSString *)TaskId
                    WithAuthorID:(int )authorId
                            type:(int)type;

+ (HMMessagePush *)selectModelWithTaskId:(NSString *)taskId AndType:(int)type;
+ (HMMessagePush *)selectModelWithFamilyId:(NSString *)familyId andType:(int)type;
/**
 *  删除wifi插座是否推送的设置
 */
+ (BOOL)deleteWifiSockectPushSettingWithDeviceId:(NSString *)deviceId;


+ (instancetype)sensorObjectWithTaskId:(NSString *)taskId;

//查询t1门锁门磁开关消息
+ (HMMessagePush *)t1LockSensorMessagePush:(HMDevice *)device;

@end
