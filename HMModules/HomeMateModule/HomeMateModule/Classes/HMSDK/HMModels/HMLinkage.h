//
//  VihomeLinkage.h
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

typedef NS_ENUM(NSInteger,HMLinakgeType) {
    HMLinakgeTypeCommon = 0,//普通联动
    HMLinakgeTypeSecurity = 1,//安防联动
    HMLinakgeTypeVoice = 2,//个性化说法联动
};

//语音自动化模式
typedef NS_ENUM(NSInteger,HMLinakgeVoiceMode) {
    HMLinakgeVoiceModeCustom = 0,//自定义
    HMLinakgeVoiceModeBackHome = 1,//回家模式
    HMLinakgeVoiceModeLeaveHome = 2,//离家模式
    HMLinakgeVoiceModeGetUp = 3,//起床模式
    HMLinakgeVoiceModeSleep = 4,//睡觉模式
    HMLinakgeVoiceModeMoving = 5,//观影模式
    HMLinakgeVoiceModeMeeting = 6,//会客模式
};

@interface HMLinkage : HMBaseModel

/**
 *  主键、自增长
 */
@property (nonatomic, retain)NSString *          linkageId;

/**
 *  创建联动的UserId
 */
@property (nonatomic, retain)NSString *          userId;

/**
 *  联动名称，1-16字节
 */
@property (nonatomic, retain)NSString *         linkageName;

/**
 *  0：表示开启联动，如果触发条件满足的话则输出联动动作
 *  1：表示暂停联动，不管如何都不输出联动动作
 */
@property (nonatomic, assign)int                isPause;

// and：表示条件进行“与”运算  or：表示条件进行“或”运算
@property (nonatomic, copy)NSString  *              conditionRelation;

@property (nonatomic, assign) HMLinakgeType         type;

@property (nonatomic, assign) HMLinakgeVoiceMode    mode;


+ (NSArray *)allLinkagesArr;

+ (HMLinkage *)objectWithLinkageId:(NSString *)linkageId;

/**
 *  根据联动输出设备删除相关联动
 */
+ (void)deleteLinkageWithDeviceId:(NSString *)deviceId;

+ (void)deleteLinkageWithLinkageId:(NSString *)linkageId;

+ (void)deleteSecurityWithDeviceId:(NSString *)deviceId;

+ (NSInteger)getLinageConditionCountWithLinakgeId:(NSString *)linkageId;

+ (BOOL)isAlloneLinkage:(NSString *)linkageId;

@end
