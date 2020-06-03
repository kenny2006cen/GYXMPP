//
//  HMDoorUserBind.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@class HMDevice;

@interface HMDoorUserBind : HMBaseModel
@property (nonatomic, strong) NSString *bindId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *extAddr;
@property (nonatomic, assign) int authorizedId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fp1;
@property (nonatomic, strong) NSString *fp2;
@property (nonatomic, strong) NSString *fp3;
@property (nonatomic, strong) NSString *fp4;
@property (nonatomic, strong) NSString *pwd1;
@property (nonatomic, strong) NSString *pwd2;
@property (nonatomic, strong) NSString *rf1;
@property (nonatomic, strong) NSString *rf2;

@property (nonatomic, assign) int uniqueId;
@property (nonatomic, assign) int modifiedRecord;


/**
 开锁记录设置
 */
@property (nonatomic, assign) BOOL showRecord;


+ (HMDoorUserBind *)objectForBindId:(NSString *)bindId;
+ (HMDoorUserBind *)objectForDevice:(HMDevice *)device authorizedId:(int)authorizedId;
+ (NSMutableArray *)objectForextAddr:(HMDevice *)device;
+ (BOOL)deleteAllObjectWithExtAddr:(NSString *)extAddr;
// 获取临时授权用户
+(NSMutableArray *)selectTempUserWithDevice:(HMDevice *)device;

+ (HMDoorUserBind *)objectForDevice:(HMDevice *)device authorizedId:(int)authorizedId recordTime:(NSString *)recordTime;

/**
 得到排序的门锁用户： 按updatetime升序，并且门锁用户在前，临时用户在后
 */
+ (NSMutableArray *)sortedDoorUsersForDevice:(HMDevice *)device;

- (void)setDeleteDoorUser:(NSNumber *)delFlag;

/**
    H1门锁所有用户，不包含临时授权用户
 */
+ (NSMutableArray *)usersForH1Lock:(HMDevice *)device;

/**
 H1门锁临时授权用户
 */
+ (NSMutableArray *)tempUsersForH1Lock:(HMDevice *)device;

@end
