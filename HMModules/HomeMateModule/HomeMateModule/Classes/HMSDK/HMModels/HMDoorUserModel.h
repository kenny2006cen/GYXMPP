//
//  DoorUserModel.h
//  
//
//  Created by Air on 15/12/4.
//
//

#import "HMBaseModel+Extension.h"

@class HMDevice;

@interface HMDoorUserModel : HMBaseModel

@property (nonatomic, strong) NSString * doorUserId;

/**
 *  门锁编号
 */
@property (nonatomic, strong) NSString * deviceId;

/**
 *  授权id
 */
@property (nonatomic, assign) int authorizedId;

/**
 *  1指纹开锁
    2密码开锁（包含永久密码和临时密码，如果临时密码失效了必须在这张表里面也删除）
    3刷卡开锁
    4临时密码开锁
 */
@property (nonatomic, assign) int type;

/**
 *  用户名称，默认为空
 */
@property (nonatomic, strong) NSString * name;

/**
 开锁记录设置
 */
@property (nonatomic, assign) BOOL showRecord;

/**
 *  获取当前门锁的成员数
 */
+(int)memberNumForDevice:(HMDevice *)device;

/**
 *  全部有开门权限的成员
 */
+(NSMutableArray *)selectAllWith:(NSString *)deviceID;


/**
 *  排过序的全体成员

 */
+(NSMutableArray *)selectAllWithOrder:(NSString *)deviceID;

/**
 *  排过序的全体成员(过滤掉临时用户)
 */
+(NSMutableArray *)selectAllExceptTemporaryUserWithOrder:(NSString *)deviceID;


/**
 *  通过doorUserId来查询
 */
+(HMDoorUserModel *)selectUserWithDoorUserId:(NSString *)doorUserId;

+(HMDoorUserModel *)selectUserWithDeviceId:(NSString *)deviceId authorizedId:(int)authorizedId;

//获取临时用户
+ (NSMutableArray *)getTempUserDevice:(HMDevice *)device;
@end
