//
//  HMStatusRecordModel.h
//  HomeMate
//
//  Created by liuzhicai on 16/6/30.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel+Extension.h"
@class HMDevice;

// 一次请求的数据
#define KHMOnceFetchDataNum   20


typedef NS_ENUM(NSInteger,StatusRecordType) {
    StatusRecordTypeAll = 0,//所有记录
    StatusRecordTypeAlarm = 1,//门锁报警记录
};

/*
 
 对于门锁: value1里面填写on/off属性值，0表示状态为开，填1表示状态为关;  value2填写authorizedId; value3填写低电量状态,0表示低电量，1表示正常; value4填写type;
 */

@interface HMStatusRecordModel : HMBaseModel

@property (nonatomic, retain)   NSString *   messageId;
@property (nonatomic,strong) NSString *     userId;
@property (nonatomic, retain)   NSString *   deviceId;
@property (nonatomic, strong) NSString *text;

// 0: 未读  1： 已读
@property (nonatomic, assign)int                readType;
@property (nonatomic, assign)int time;    // 状态记录发生时的秒数
@property (nonatomic, assign)int                deviceType;
@property (nonatomic, assign)int                value1;
@property (nonatomic, assign)int                value2;
@property (nonatomic, assign)int                value3;
@property (nonatomic, assign)int                value4;

/**
 0默认所有消息
 针对智能门锁设备类型
 1：异常消息
 */
@property (nonatomic, assign)int                type;


/**
 按 type 分类后，在分类中的序号
 */
@property (nonatomic, assign)int                classifiedSequence;

// 每个deviceId有一个从1递增的序列
@property (nonatomic, assign)int                sequence;

@property (nonatomic, assign)int                isPush;

@property (nonatomic, copy)NSString *stringDateTime;


/**
 *  cell 的高度
 */
@property (nonatomic, assign)CGFloat cellHeight;




@property (nonatomic, assign)BOOL shouldHideDateUIElements; // 两条状态是同一天的，则隐藏日期的label和图片


/// 删除某一设备的状态记录
/// @param deviceId 设备Id
+ (BOOL)deleteStatusRecordWithDeviceId:(NSString *)deviceId;

/**
 *  获取数据库中某一设备所有状态记录的最大序号
 *
 *  @param deviceId 设备Id
 *
 *  @return 返回最大序号
 */
+ (int)getMaxSequenceNumWithDeviceId:(NSString *)deviceId;

/**
 *  获取某一序号以下序号的最大中断序号
 *
 *  @param sequence 某一序号
 *  @param deviceId 某一设备Id
 *
 *  @return 返回中断序号
 */
+ (int)getInterruptSequenceAfterSomeSequence:(int)sequence withDeviceId:(NSString *)deviceId;

/**
 *  某一序号以下的20条数据是否有中断序号，有则去服务器请求数据
 *
 *  @param sequence 某一序号
 *  @param deviceId 某一设备Id
 */
+ (BOOL)isHasInterruptStatusRecordAfterSomeSequence:(int)sequence withDeviceId:(NSString *)deviceId;


/**
 *  获取小于某序号的连续数据，（每次查20条）
 *
 *  @param sequence 某序号
 *  @param deviceId 某一设备Id
 *
 *  @return 状态记录的数组， 数组的状态记录根据序号递减
 */
+ (NSMutableArray *)continuousRecordAfterSomeSequence:(int)sequence withDeviceId:(NSString *)deviceId;


/**
 *  获取数据库中最新的20条连续的数据,用来刚进入界面时显示
 *
 *  @param deviceId 设备Id
 *
 *  @return  返回状态记录数组，数组的状态记录根据序号递减
 */
+ (NSMutableArray *)getNewestTwentyDataFromDbWithDeviceId:(NSString *)deviceId;

/**
 *  返回上次查数据库返回的最后一条数据的序号 跟 中断序号之间的数据
 *
 *  @param minSequence 中断序号，小于此的都是中断的
 *  @param maxSequence 上次查数据库返回的最后一条数据的序号（查数据库都是序号递减返回）
 *  @param deviceId    设备Id
 *
 *  @return 返回状态记录数组， 包括中断序号，不包括 maxSequence
 */
+ (NSMutableArray *)getRecordDataBetweenMinSequence:(int)minSequence maxSequence:(int)maxSequence deviceId:(NSString *)deviceId;

/**
 *  获取某一设备的最近状态记录， 用于首页显示
 */
+ (HMStatusRecordModel *)latestRecordWithDeviceId:(NSString *)deviceId;


/**
 获取门锁的最新记录 （状态记录里的第一条）

 */
+ (HMStatusRecordModel *)latestLockRecordWithDeviceId:(NSString *)deviceId;


+(NSMutableArray *)selectDataByUserIdLimitCount:(NSInteger )count AndDeviceId:(NSString *)deviceId recordType:(StatusRecordType)recordType;

+(NSMutableArray *)selectT1AlarmRecordDevice:(HMDevice *)device lastTime:(NSString *)lastTime;

/**
 *  删除单个设备的所有记录
 */
+ (BOOL)deleteWithDeviceId:(NSString *)deviceId;

+ (NSInteger )getLastDeleteSequence:(HMDevice *)device recordType:(StatusRecordType)recordType;


/**
 从某分页起点开始按序号递减数二十条数据

 @param index 分页起点
 */
+ (NSArray *)twentyRecordFromPagingLimitIndex:(int)index deviceId:(NSString *)deviceId;

+ (NSArray *)lastestTwentyRecordFromDbWithDeviceId:(NSString *)deviceId;
+ (NSInteger)maxRecordUpdateTimeForDevice:(HMDevice *)device;
@end
