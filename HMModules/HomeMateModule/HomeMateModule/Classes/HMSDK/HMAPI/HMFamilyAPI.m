//
//  HMFaimilyAPI.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMFamilyAPI.h"
#import "HMFamilyBusiness.h"

@implementation HMFamilyAPI

+ (void)queryFamilyListWithCompletion:(SocketCompletionBlock)completion {
    [HMFamilyBusiness queryFamilyListWithCompletion:completion];
}

+ (void)queryFamilyListCanBeRecoverWithCompletion:(SocketCompletionBlock)completion {
    [HMFamilyBusiness queryFamilyListCanBeRecoverWithCompletion:completion];
}


+ (void)switchToFamily:(NSString *)familyId completion:(commonBlock)completion {
    [HMFamilyBusiness switchToFamily:familyId completion:completion];
}

+ (void)createFamilyWithName:(NSString *)familyName completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness createFamilyWithName:familyName completion:completion];
}
+ (void)createFamilyWithName:(NSString *)familyName loading:(BOOL)loading completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness createFamilyWithName:familyName loading:loading completion:completion];
}
+ (void)createFamilyWithName:(NSString *)familyName loading:(BOOL)loading insert:(BOOL)insert completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness createFamilyWithName:familyName loading:loading insert:insert completion:completion];
}

+ (void)modifyFamilyWithName:(NSString *)familyName familyId:(NSString *)familyId completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness modifyFamilyWithName:familyName familyId:familyId completion:completion];
}

/**
 修改家庭地理位置
 
 @param geofence 地理围栏
 @param position 家庭的位置
 @param latotide 经度
 @param latotide 纬度
 @param familyId 该家庭的id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)modifyFamilyWithGeofence:(NSString *)geofence
                         positon:(NSString *)position
                       longitude:(NSString *)longitude
                        latotide:(NSString *)latotide
                        familyId:(NSString *)familyId
                      completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness modifyFamilyWithGeofence:geofence
                                       positon:position
                                     longitude:longitude
                                      latotide:latotide
                                      familyId:familyId
                                    completion:completion];
    
}


+ (void)queryFamilyUsersList:(NSString *)familyId completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness queryFamilyUsersList:familyId completion:completion];
}

+ (void)inviteFamily:(NSString *)userName
            familyId:(NSString *)familyId
             isAdmin:(BOOL)isAdmin
 unAuthorizedRoomIds:(NSArray<NSString*>*)unAuthorizedRoomIds
unAuthorizedDevcedIds:(NSArray<NSString*>*)unAuthorizedDevcedIds
unAuthorizedGroupIds:(NSArray<NSString*>*)unAuthorizedGroupIds
unAuthorizedSceneNos:(NSArray<NSString*>*)unAuthorizedSceneNos
            userBind:(HMDoorUserBind *)user
          completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness inviteFamily:userName familyId:familyId isAdmin:isAdmin unAuthorizedRoomIds:unAuthorizedRoomIds unAuthorizedDevcedIds:unAuthorizedDevcedIds unAuthorizedGroupIds:unAuthorizedGroupIds unAuthorizedSceneNos:unAuthorizedSceneNos userBind:user completion:completion];
}

+ (void)deleteFamilyUsers:(HMFamilyUsers *)familyUser completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness deleteFamilyUsers:familyUser completion:completion];
}
+ (void)deleteFamilyUsers:(HMFamilyUsers *)familyUser deleteLocal:(BOOL)deleteLocal completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness deleteFamilyUsers:familyUser deleteLocal:deleteLocal completion:completion];
}

+ (void)deleteFamily:(NSString *)familyId completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness deleteFamily:familyId completion:completion];
}

+ (void)exitFamily:(NSString *)familyId completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness exitFamily:familyId completion:completion];
}

+ (void)searchFamilyInLanWithCompletion:(commonBlockWithObject)completion {
    [HMFamilyBusiness searchFamilyInLanWithCompletion:completion];
}

+ (void)joinFamily:(NSString *)familyId completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness joinFamily:familyId completion:completion];
}

+ (void)responseJoinFamilyWithFamilyJoinId:(NSString *)familyJoinId accept:(BOOL)accept completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness responseJoinFamilyWithFamilyJoinId:familyJoinId accept:accept completion:completion];
}

+ (void)joinFamilyAsAdmin:(NSString *)familyId completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness joinFamilyAsAdmin:familyId completion:completion];
}

+ (void)queryRoomAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness queryRoomAuthorityWithFamilyId:familyId userId:userId completion:completion];
}

+ (void)queryDeviceAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness queryDeviceAuthorityWithFamilyId:familyId userId:userId completion:completion];
}

+ (void)modifyRoomAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId roomId:(NSString *)roomId authorized:(BOOL)authorized completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness modifyRoomAuthorityWithFamilyId:familyId userId:userId roomId:roomId authorized:authorized completion:completion];
}

+ (void)modifyDeviceAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId authorizedList:(NSArray<HMDevice *> *)authorizedList unauthorizedList:(NSArray<HMDevice *> *)unauthorizedList completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness modifyDeviceAuthorityWithFamilyId:familyId userId:userId authorizedList:authorizedList unauthorizedList:unauthorizedList completion:completion];
}

+ (void)modifyFamilyAdminAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId toBeAdmin:(BOOL)toBeAdmin completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness modifyFamilyAdminAuthorityWithFamilyId:familyId userId:userId toBeAdmin:toBeAdmin completion:completion];
}

+ (void)queryAdminFamilyWithUserName:(NSString *)userName completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness queryAdminFamilyWithUserName:userName completion:completion];
}

+ (void)queryFamilyByFamilyId:(NSString *)familyId completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness queryFamilyByFamilyId:familyId completion:completion];
}

+ (void)recoverFamily:(NSString *)familyId completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness recoverFamily:familyId completion:completion];
}

/**
 查询指定用户的所有终端设备信息，返回设备的标识信息和名称列表，按上报时间倒序排序，最近使用过的终端排在最上面
 
 @param userId 用户Id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)queryUserTerminalDeviceByUserId:(NSString *)userId completion:(commonBlockWithObject)completion {
    [HMFamilyBusiness queryUserTerminalDeviceByUserId:userId completion:completion];
}

+ (void)queryAuthorityWithCmd:(NewQueryAuthorityCmd *)cmd completion:(commonBlockWithObject)completion{
    [HMFamilyBusiness queryAuthorityWithCmd:cmd completion:completion];
}
@end
