//
//  HMFamilyUsers.h
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMFamilyUsers : HMBaseModel

@property (nonatomic, copy) NSString *familyUserId;
//@property (nonatomic, copy) NSString *familyId;
@property (nonatomic, copy) NSString *userId;

/**
 0: 管理员 1: 非管理员
 */
@property (nonatomic, assign) int userType;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *nicknameInFamily;

// 非协议字段
@property (nonatomic, strong, readonly)NSString *showName;
@property (nonatomic, assign) BOOL selected;

+ (NSMutableArray *)selectFamilyUsersByFamilyId:(NSString *)familyId;


+ (NSMutableArray *)selectAllFamilyUsersByFamilyId:(NSString *)familyId;


+ (HMFamilyUsers *)selectUsersByUserId:(NSString *)userId;

+ (HMFamilyUsers *)defaultFamilyMember; // 返回默认的家庭成员[当前用户]
/**
 删除某家庭的所有家庭成员

 @param familyId 家庭ID
 */
+ (BOOL)deleteFamilyUsersOfFamilyId:(NSString *)familyId;

@end
