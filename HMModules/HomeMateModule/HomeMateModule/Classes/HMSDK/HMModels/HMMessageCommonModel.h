//
//  HMMessageCommonModel.h
//  HomeMateSDK
//
//  Created by liuzhicai on 16/11/17.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

typedef NS_ENUM(NSInteger,HMMessageType) {
    HMMessageTypeAll = 0,
    HMMessageTypeAlarm,
    HMMessageTypeSyStem,
    HMMessageTypeLowPower,
    HMMessageTypeDeviceStatus,
    HMMessageTypeTime,
};

@interface HMMessageCommonModel : HMBaseModel

@property (nonatomic, strong)NSString *messageCommonId;

@property (nonatomic, strong)NSString *userId;

@property (nonatomic, strong)NSString *deviceId;

@property (nonatomic, strong)NSString *text;

@property (nonatomic, strong)NSString *deviceName;

@property (nonatomic, strong)NSString *roomName;

@property (nonatomic, strong)NSString *rule;

@property (nonatomic, strong)NSString *params;


/**
 *  是否已读     0:未读   1：已读
 */
@property (nonatomic, assign)int readType;
@property (nonatomic, assign)int infoType;
@property (nonatomic, assign)int type;
@property (nonatomic, assign)int classifiedSequence;

/**
 *  1970年1月1号到现在的秒数
 */
@property (nonatomic, assign) int time;

@property (nonatomic, assign) int deviceType;

@property (nonatomic, assign) int value1;
@property (nonatomic, assign) int value2;
@property (nonatomic, assign) int value3;
@property (nonatomic, assign) int value4;

@property (nonatomic, assign) int sequence;

/**
 *  该消息是否进行推送0:不推送 1:推送
 */
@property (nonatomic, assign) int isPush;


/**
 *  当一条消息跟上一条消息处于同一分钟时，隐藏时间
 */
@property (nonatomic, assign)BOOL shouldHideTime;


/**
 *  精确到分钟的时间字符串 （当一条消息跟上一条消息处于同一分钟时，隐藏时间）
 */
@property (nonatomic, copy)NSString * minPreciseTimeStr;

/**********  3.3 系统消息升级加的属性  ***************/

/**
 跳转页面的url
 */
@property (nonatomic, copy)NSString * pageUrl;

/**
 消息详情图片url
 */
@property (nonatomic, copy)NSString * msgIconUrl;

/**
 消息标题 ， 消息详情还用 text 属性
 */
@property (nonatomic, copy)NSString * messageTitle;


/**
 infoType 不等于 47 都要显示， 等于47要判断版本号、系统
 是否要显示这条消息对象 事件  “（版本号为空 || 版本号数组中有app当前版本）&& 是否iOS系统 && infoType ==47 ”  为真就显示
 */
@property (nonatomic, assign)BOOL isShouldDisplay;

/**
 *  某用户消息的本地最大序号 （默认当前家庭）
 */
+ (int)getMaxSequenceNum;

/**
 * 某用户消息的某一家庭本地最大序号
 * @param familyId 家庭id
 */
+ (int)getMaxSequenceNumWithFamilyId:(NSString *)familyId messageType:(HMMessageType)messageType;

+ (NSArray *)lastTwentyMsgFromCount:(int)count messageType:(HMMessageType)messageType;

+(int)getUnreadMsgNum;

+(int)getUnreadMsgNumWithFamilyId:(NSString *)familyId;



/**
 首页是否有红点

 @param familyId <#familyId description#>
 */
+(BOOL)isHasHomePageRedInFamilyId:(NSString *)familyId;

// 获得最大已删除序号，小于此序号的不请求，不显示
+ (int)getMaxDeleteSequenceWithFamilyId:(NSString *)familyId messageType:(HMMessageType)messageType;


+ (BOOL)deleteAllMsg;

+ (void)setAllMsgToHasRead;

/**
 *  判断某消息序号是否有中断
 */
+ (BOOL)isHasInterruptMsgAfterSomeSequence:(HMMessageCommonModel *)messageCommonModel messageType:(HMMessageType)messageType;

/**
 *  获得sequence之后的中断序号
 */
+ (int)getInterruptSequenceAfterSomeSequence:(HMMessageCommonModel *)messageCommonModel messageType:(HMMessageType)messageType;

+ (NSMutableArray *)getCommonMsgBetweenMinSequence:(int)minSequence maxSequence:(int)maxSequence messageType:(HMMessageType)messageType;

+ (NSMutableArray *)continuousMessageAfterSomeSequence:(HMMessageCommonModel *)messageCommonModel messageType:(HMMessageType)messageType;

@end
