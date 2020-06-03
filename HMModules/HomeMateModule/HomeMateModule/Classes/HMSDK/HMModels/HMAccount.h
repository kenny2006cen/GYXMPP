//
//  VihomeAccount.h
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"
#import "HMBaseModel.h"

@interface HMAccount : HMBaseModel

@property (nonatomic, retain)NSString *             userId;

@property (nonatomic, retain)NSString *             userName;

@property (nonatomic, retain)NSString *             password;
@property (nonatomic, retain)NSString *             passwordNew;

@property (nonatomic, retain)NSString *             phone;

@property (nonatomic, retain)NSString *             email;

@property (nonatomic, assign)int                    userType;

@property (nonatomic, assign)int                    registerType;

@property (nonatomic, assign)int                    idc;

@property (nonatomic, retain)NSString *             country;

@property (nonatomic, retain)NSString *             state;

@property (nonatomic, retain)NSString *             city;

//国家区号
@property (nonatomic, retain)NSString *             areaCode;


/**
 *  当前账号所属的账号，父账号
 */
@property (nonatomic, retain)NSString *             fatherUserId;
/**
 *  更新用户昵称
 */
+(BOOL)updateNickName:(NSString *)nickName;
/**
 *  根据userId获取当前account表中帐号的信息
 *  @return 没有返回nil
 */
+(HMAccount *)objectWithUserId:(NSString *)userId;

+(HMAccount *)accountWithName:(NSString *)name;

+(HMAccount *)accountWithPhoneNumber:(NSString *)phoneNumber areaCode:(NSString *)areaCode;

+(BOOL)updateEmail:(NSString *)email;

+(BOOL)updatePhone:(NSString *)phone;

+(BOOL)updatePassword:(NSString *)password;

+(BOOL)updatePasswordNew:(NSString *)password;

/// 更新国家区号
/// @param areaCode 国家区号
+(BOOL)updateAreaCode:(NSString *)areaCode;

+(NSString *)userIdWithName:(NSString *)name;

/**
 *  返回家庭成员数组
 */
+(NSArray *)familyMemberArray;

/**
 *  删除子账号信息
 *
 *  @param subUserId      子账号userId
 *  @param fatherUserId   主帐号userId
 */
+(BOOL)deleteSubAccountUserId:(NSString *)subUserId fatherUserId:(NSString *)fatherUserId;


@end
