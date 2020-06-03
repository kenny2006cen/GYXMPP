//
//  VihomeTiming.h
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMTiming : HMBaseModel <OrderProtocol>

@property (nonatomic, retain) NSString *       timingId;

@property (nonatomic, retain) NSString *        actionName;


@property (nonatomic, retain) NSString *        name;

@property (nonatomic, retain) NSString *        deviceId;

@property (nonatomic, retain) NSString *        bindOrder;

@property (nonatomic, assign)int                value1;

@property (nonatomic, assign)int                value2;

@property (nonatomic, assign)int                value3;

@property (nonatomic, assign)int                value4;

@property (nonatomic, assign)int                hour;

@property (nonatomic, assign)int                minute;

@property (nonatomic, assign)int                second;

@property (nonatomic, assign)int                week;

/**
 *  0：表示暂停
    1：表示生效
 */
@property (nonatomic, assign)int                isPause;

@property (nonatomic, assign)int                timingType;
@property (nonatomic, assign)int                resourceId;
@property (nonatomic, assign)int                typeId;
@property (nonatomic, assign)int                isHD;

/** 小方定时 */
@property (nonatomic, assign) int freq;
@property (nonatomic, assign) int pluseNum;
@property (nonatomic, copy) NSString * pluseData;

// 幻彩灯带用到
@property (nonatomic, copy) NSString * themeId;


/** 雷士日期定时 已在另外的.m 处理*/
@property (nonatomic,strong) NSString * startDate;

@property (nonatomic,strong) NSString * endDate;

/** 模式定时 */
@property (nonatomic, retain) NSString *       timingGroupId;
@property (nonatomic, assign) int showIndex;

@property (nonatomic, assign) KDeviceType deviceType;
@property (nonatomic, assign) int     subDeviceType;

/**
 *  判断两个定时任务是否相同
 *
 *  @param timer 定时任务
 *
 *  @return 是否相同 YES：相同 NO：不同
 */
- (BOOL)isEqualtoTimer:(HMTiming *)timer;

/**
 *  根据deviceId获取某个设备的所有定时，按照定时的时间排序
 *
 *  @param deviceId 网关下设备的唯一编号
 *
 *  @return 定时数组,没有定时返回nil
 */
+(NSArray *)timingArrWithDeviceId:(NSString *)deviceId;

/**
 *  根据deviceId获取某个设备所有有效的定时
 */
+(NSArray *)availabilityTimingArrWithDeviceId:(NSString *)deviceId;

/**
 *  更新定时有效位
 *
 *  @param isPause 0：暂停    1：生效
 */
+(BOOL)updatePause:(int)isPause timingId:(NSString *)timingId;

/**
 *  删除一个定时
 */
+(BOOL)deleteTimerWithTimingId:(NSString *)timingId;

/**
 *  确定当前设置的定时对应的时间是否与已经设置的定时有冲突
 *
 *  @param hour     当前设置定时的hour
 *  @param minute   当前设置定时的minute
 *  @param newWeek  当前设置定时的周
 *  @param deviceId 设备的deviceId
 *
 *  @return YES:当前设置的定时与已经存在的定时存在冲突，NO:当前设置的定时没有与已经设置的定时存在冲突
 */
+(BOOL)sameHour:(int)hour minute:(int)minute newTimerWeek:(int)newWeek deviceId:(NSString *)deviceId;

/**
 *  编辑定保存时判断
 *
 *  @return YES：存在冲突，  NO：正常
 */
+(BOOL)sameHour:(int)hour minute:(int)minute newTimerWeek:(int)newWeek deviceId:(NSString *)deviceId ignoreTimingId:(NSString *)timingId;

/**
 *  获取对应timingId的对象
 */
+ (HMTiming *)objectWithTimingId:(NSString *)timingId;

/**
 *  获得小方的预约定时
 */
+ (NSArray *)appointmentProgramsWithDeviceId:(NSString *)deviceId;

/**
 *  在某时某分是否有预约节目
 *  @param name   节目名字
 */
+ (BOOL)isHasOrderProgramInHour:(int)hour minute:(int)minute week:(int)week isHd:(BOOL)isHd deviceId:(NSString *)deviceId name:(NSString *)name;


+ (HMTiming *)orderProgramInHour:(int)hour minute:(int)minute week:(int)week isHd:(BOOL)isHd deviceId:(NSString *)deviceId name:(NSString *)name;


@end
