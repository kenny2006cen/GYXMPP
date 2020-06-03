//
//  LocalAccount.h
//  HomeMate
//
//  Created by Air on 15/8/11.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMLocalAccount : HMBaseModel

@property (nonatomic, strong)NSString *         userId;
/**
 *  一个帐号最后一次登录的帐号名(手机号/邮箱)
 */
@property (nonatomic, strong)NSString *         lastUserName;

/**
 *  每次登录成功都需要更新该时间
 */
@property (nonatomic, assign)int                loginTime;

/**
 *  登录的密码md5
 */
@property (nonatomic, strong) NSString *        password;

/**
 *  登录token
 */
@property (nonatomic, strong) NSString *        token;

/**
 *  兼容第三方登录，同一个userId账号，第三方登录后仍然会把之前登录过的手机号或邮箱显示出来
 *  登录历史记录里面的用户名以这个字段显示
 */
@property (nonatomic, copy) NSString  *         compatibleUserName;

//国家区号
@property (nonatomic, retain)NSString *         areaCode;

/**
 *  获取所有本地的帐号信息
 *
 *  @return 没有返回nil
 */
+ (NSArray *)getAllLocalAccountArr;

/**
 *  用于登录页面，获取所有要显示的账号信息
 *
 *  @return 会过滤掉compatibleUserName为空的账号
 */
+ (NSArray *)getAllFilteredLocalAccountArr;

/**
 *  获取最后一次登录的帐号信息，按最大的登录时间算
 *
 */
+ (HMLocalAccount *)lastAccountInfo;

+(BOOL)updateEmail:(NSString *)email;

+(BOOL)updatePhone:(NSString *)phone;

+(BOOL)updatePassword:(NSString *)password;

/// 更新国家区号
/// @param areaCode 国家区号
+(BOOL)updateAreaCode:(NSString *)areaCode;

/**
*  一键登录/验证码登录的账号，修改密码后，旧的Token失效，需要移除掉
*  @param userId 用户Id
*/
+(BOOL)removeTokenWithUserId:(NSString *)userId;

/**
 *  通过登录名获取对象
 *
 *  @param name lastUserName/compatibleUserName
 *
 */
+ (instancetype)objectWithUserName:(NSString *)name;

+ (instancetype)objectWithUserId:(NSString *)userId;

@end 
