//
//  AuthorizedUnlock.h
//  
//
//  Created by Air on 15/12/4.
//
//

#import "HMBaseModel+Extension.h"
#import "HMConstant.h"


@interface HMAuthorizedUnlockModel : HMBaseModel

@property (nonatomic, strong) NSString * authorizedUnlockId;

/**
 *  被授权的门锁编号
 */
@property (nonatomic, strong) NSString * deviceId;

/**
 *  授权id
 */
@property (nonatomic, assign) int authorizedId;

/**
 *  授权手机号
 */
@property (nonatomic, strong) NSString * phone;


/**
 *  授权人
 */
@property (nonatomic, strong) NSString * authorizer;


/**
 *  单位，分钟 UTC时间
 */
@property (nonatomic, assign) int time;

/**
 *  在有效期内允许开锁的次数。
    填写0的时候表示不限制次数。
 */
@property (nonatomic, assign) int number;

/**
 *  UTC时间
 */
@property (nonatomic, assign) int startTime;

/**
 *  已开锁次数
 */
@property (nonatomic, assign) int unlockNum;

/**
 *  0：正常授权
    1：超过有效期
    2：超过最大次数限制
    3：手工取消授权
 */
@property (nonatomic, assign) int authorizeStatus;

/**
  * 密码使用方式
  * 0:多次有效
  * 1:1次有效
  * 2：每周有效
  * 3：一个月的某些天有效
  * 4：每天有效
 */
@property (nonatomic, assign) int  pwdUseType;

/**
 *  有效天数
 */
@property (nonatomic, strong) NSString * day;


/**
 *  获取最近一次授权的用户信息
 *
 */
+(HMAuthorizedUnlockModel *)SelectRecentUserWithDeviceId:(NSString *)deviceId;

/**
 *  获取最近三次次授权的用户信息
 *
 */
+(NSMutableArray<HMAuthorizedUnlockModel *> *)selectRecentThreeUserWithDevice:(HMDevice *)device;



/**
 *  获取有效的授权
 *
 */
+(NSMutableArray *)selectUserWithDevice:(HMDevice *)device;

+ (BOOL)deleteUnlockModelDevice:(HMDevice *)device;
@end
