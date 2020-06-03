//
//  HMSecurityAPI.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMSecurityAPI.h"
#import "HMSecurityBusiness.h"
@implementation HMSecurityAPI
+ (NSArray *)getAllSecurityDevicesWithFamilyId:(NSString *)familyId andUserId:(NSString *)userId {
    return [HMSecurityBusiness getAllSecurityDevicesWithFamilyId:familyId andUserId:userId];
}
+ (NSArray *)getSecurityDevicesOfRoomId:(NSString *)roomId familyId:(NSString *)familyId userId:(NSString *)userId {
    return [HMSecurityBusiness getSecurityDevicesOfRoomId:roomId familyId:familyId userId:userId];
}

+ (NSArray *)getAllSecurityDevicesWhoWithTopActionByFamilyId:(NSString *)familyId andUserId:(NSString *)userId {
    return [HMSecurityBusiness getAllSecurityDevicesWhoWithTopActionByFamilyId:familyId andUserId:userId];
}

+ (NSArray *)getAllSecurityDevicesWhoWithoutTopActionByFamilyId:(NSString *)familyId andUserId:(NSString *)userId {
    return [HMSecurityBusiness getAllSecurityDevicesWhoWithoutTopActionByFamilyId:familyId andUserId:userId];
}

+ (NSArray *)subDeviceTypeisSecurityArray
{
    return [HMSecurityBusiness subDeviceTypeisSecurityArray];
}

+ (NSArray *)securityDeviceArray
{
    return [HMSecurityBusiness securityDeviceArray];
}

@end
