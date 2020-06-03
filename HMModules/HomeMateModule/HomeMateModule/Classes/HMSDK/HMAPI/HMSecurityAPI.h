//
//  HMSecurityAPI.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseAPI.h"

@interface HMSecurityAPI : HMBaseAPI

/**
 获取账号当前家庭所有安防设备
 
 @param familyId familyId
 @param userId userId
 @return 设备列表
 */
+ (NSArray *)getAllSecurityDevicesWithFamilyId:(NSString *)familyId andUserId:(NSString *)userId;


/**
 获取账号当前家庭某一房间的安防设备

 @param roomId 房间Id
 @param familyId familyId
 @param userId userId
 @return 设备数组
 */
+ (NSArray *)getSecurityDevicesOfRoomId:(NSString *)roomId familyId:(NSString *)familyId userId:(NSString *)userId;

/**
 获取账号当前家庭某一房间的安防设备(有置顶操作的设备)
 
 @param userId userId
 @return 设备数组
 */
+ (NSArray *)getAllSecurityDevicesWhoWithTopActionByFamilyId:(NSString *)familyId andUserId:(NSString *)userId;

/**
 获取账号当前家庭某一房间的安防设备(无置顶操作的设备)
 
 @param familyId familyId
 @return 设备数组
 */
+ (NSArray *)getAllSecurityDevicesWhoWithoutTopActionByFamilyId:(NSString *)familyId andUserId:(NSString *)userId;

/**
 获取所有安防类型的子设备（subDeviceType）
 */

+ (NSArray *)subDeviceTypeisSecurityArray;

/**
 获取所有安防类型设备（deviceType）
 */
+ (NSArray *)securityDeviceArray;

@end
