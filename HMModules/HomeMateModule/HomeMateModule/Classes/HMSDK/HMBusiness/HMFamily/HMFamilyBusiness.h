//
//  HMFamilyBusiness.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseBusiness.h"

@interface HMFamilyBusiness : HMBaseBusiness

+ (void)deleteFamilyWithUserId:(NSString *)userId;

+ (void)saveAndSortFamilyInfo:(NSDictionary *)returnDic;

+ (void)queryFamilyListWithCompletion:(SocketCompletionBlock)completion;
+ (void)queryFamilyListCanBeRecoverWithCompletion:(SocketCompletionBlock)completion;
+ (void)switchToFamily:(NSString *)familyId completion:(commonBlock)completion;

+ (void)createFamilyWithName:(NSString *)familyName completion:(commonBlockWithObject)completion;
+ (void)createFamilyWithName:(NSString *)familyName loading:(BOOL)loading completion:(commonBlockWithObject)completion;
+ (void)createFamilyWithName:(NSString *)familyName loading:(BOOL)loading insert:(BOOL)insert completion:(commonBlockWithObject)completion;

+ (void)modifyFamilyWithName:(NSString *)familyName familyId:(NSString *)familyId completion:(commonBlockWithObject)completion;

+ (void)queryFamilyUsersList:(NSString *)familyId completion:(commonBlockWithObject)completion;

+ (void)inviteFamily:(NSString *)userName
            familyId:(NSString *)familyId
             isAdmin:(BOOL)isAdmin
 unAuthorizedRoomIds:(NSArray<NSString*>*)unAuthorizedRoomIds
unAuthorizedDevcedIds:(NSArray<NSString*>*)unAuthorizedDevcedIds
unAuthorizedGroupIds:(NSArray<NSString*>*)unAuthorizedGroupIds
unAuthorizedSceneNos:(NSArray<NSString*>*)unAuthorizedSceneNos
            userBind:(HMDoorUserBind *)user
          completion:(commonBlockWithObject)completion;

+ (void)deleteFamilyUsers:(HMFamilyUsers *)familyUser completion:(commonBlockWithObject)completion;
+ (void)deleteFamilyUsers:(HMFamilyUsers *)familyUser deleteLocal:(BOOL)deleteLocal completion:(commonBlockWithObject)completion;

+ (void)deleteFamily:(NSString *)familyId completion:(commonBlockWithObject)completion;

+ (void)exitFamily:(NSString *)familyId completion:(commonBlockWithObject)completion;

+ (void)searchFamilyInLanWithCompletion:(commonBlockWithObject)completion;

+ (void)joinFamily:(NSString *)familyId completion:(commonBlockWithObject)completion;

+ (void)responseJoinFamilyWithFamilyJoinId:(NSString *)familyJoinId accept:(BOOL)accept completion:(commonBlockWithObject)completion;

+ (void)joinFamilyAsAdmin:(NSString *)familyId completion:(commonBlockWithObject)completion;

+(void)requestFamilyWithUserId:(NSString *)userId completion:(SocketCompletionBlock)completion;

+ (void)queryRoomAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId completion:(commonBlockWithObject)completion;

+ (void)queryDeviceAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId completion:(commonBlockWithObject)completion;

/**
 通用权限查询接口
 cmd.authorityTypes
 权限类型,可以查询多个权限类型，用英文","分隔，如1, 4， 支持分页
 0：房间权限
 1：设备权限
 2：情景权限
 3：MixPad语音对讲权限
 5：MixPad语音对讲权限(APP)
 6：组权限
 */
+ (void)queryAuthorityWithCmd:(NewQueryAuthorityCmd *)cmd completion:(commonBlockWithObject)completion;

+ (void)modifyRoomAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId roomId:(NSString *)roomId authorized:(BOOL)authorized completion:(commonBlockWithObject)completion;

+ (void)modifyDeviceAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId authorizedList:(NSArray <HMDevice *>*)authorizedList unauthorizedList:(NSArray <HMDevice *>*)unauthorizedList completion:(commonBlockWithObject)completion;

+ (void)modifyFamilyAdminAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId toBeAdmin:(BOOL)toBeAdmin completion:(commonBlockWithObject)completion;

+ (void)queryAdminFamilyWithUserName:(NSString *)userName completion:(commonBlockWithObject)completion;

+ (void)queryFamilyByFamilyId:(NSString *)familyId completion:(commonBlockWithObject)completion;

+ (void)recoverFamily:(NSString *)familyId completion:(commonBlockWithObject)completion;

/**
 修改家庭地理位置
 
 @param geofence 地理围栏
 @param position 家庭的位置
 @param longitude 经度
 @param latotide 纬度
 @param familyId 该家庭的id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)modifyFamilyWithGeofence:(NSString *)geofence
                         positon:(NSString *)position
                       longitude:(NSString *)longitude
                        latotide:(NSString *)latotide
                        familyId:(NSString *)familyId
                      completion:(commonBlockWithObject)completion;

/**
 查询指定用户的所有终端设备信息，返回设备的标识信息和名称列表，按上报时间倒序排序，最近使用过的终端排在最上面
 
 @param userId 用户Id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)queryUserTerminalDeviceByUserId:(NSString *)userId
                             completion:(commonBlockWithObject)completion;
@end
