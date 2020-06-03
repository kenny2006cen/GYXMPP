//
//  HMSecurityBusiness.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseBusiness.h"

@interface HMSecurityBusiness : HMBaseBusiness

/**
 获取账号当前家庭所有安防设备

 @param familyId familyId
 @param userId userId
 @return 设备列表
 */
+ (NSArray *)getAllSecurityDevicesWithFamilyId:(NSString *)familyId andUserId:(NSString *)userId;

+ (NSArray *)getSecurityDevicesOfRoomId:(NSString *)roomId familyId:(NSString *)familyId userId:(NSString *)userId;

+ (NSArray *)getAllSecurityDevicesWhoWithTopActionByFamilyId:(NSString *)familyId andUserId:(NSString *)userId;

+ (NSArray *)getAllSecurityDevicesWhoWithoutTopActionByFamilyId:(NSString *)familyId andUserId:(NSString *)userId;

+ (NSArray *)subDeviceTypeisSecurityArray;

+ (NSArray *)securityDeviceArray;

@end
