//
//  HMFaimilyAPI.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseAPI.h"
#import "HMTypes.h"
#import "NewQueryAuthorityCmd.h"
#import "HMConstant.h"


@interface HMFamilyAPI : HMBaseAPI


/**
 查询当前用户的家庭列表（查询成功会写入到本地数据库，使用 [HMFamily readAllFamilys] 可返回家庭列表）

 @param completion 回调方法使用服务器返回数据
 */
+ (void)queryFamilyListWithCompletion:(SocketCompletionBlock)completion;


/**
 查询当前用户下已删除的有设备的未被绑定的家庭   ---- 这些家庭能恢复

 @param completion 回调方法使用服务器返回数据
 */
+ (void)queryFamilyListCanBeRecoverWithCompletion:(SocketCompletionBlock)completion;

/**
 切换家庭

 @param familyId 目标家庭的id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)switchToFamily:(NSString *)familyId completion:(commonBlock)completion;

/**
 创建家庭

 @param familyName 家庭的名称
 @param completion 回调方法使用服务器返回数据
 */
+ (void)createFamilyWithName:(NSString *)familyName completion:(commonBlockWithObject)completion;
+ (void)createFamilyWithName:(NSString *)familyName loading:(BOOL)loading completion:(commonBlockWithObject)completion;
+ (void)createFamilyWithName:(NSString *)familyName loading:(BOOL)loading insert:(BOOL)insert completion:(commonBlockWithObject)completion;

/**
 修改家庭名称

 @param familyName 家庭的名称
 @param familyId 该家庭的id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)modifyFamilyWithName:(NSString *)familyName familyId:(NSString *)familyId completion:(commonBlockWithObject)completion;


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
 查询家庭成员（向服务器请求）

 @param familyId 该家庭的id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)queryFamilyUsersList:(NSString *)familyId completion:(commonBlockWithObject)completion;

/**
 邀请家庭成员
 
 @param userName 手机或邮箱
 @param familyId 该家庭的id
 @param isAdmin  是否邀请成为管理员
 @param unAuthorizedRoomIds  屏蔽访问的房间id列表 （普通成员才会设置）
 @param unAuthorizedDevcedIds  屏蔽访问的设备id列表 （普通成员才会设置）
 @param unAuthorizedSceneNos  屏蔽访问的情景序号列表 （普通成员才会设置）
 @param completion 回调方法使用服务器返回数据
 */
+ (void)inviteFamily:(NSString *)userName
            familyId:(NSString *)familyId
             isAdmin:(BOOL)isAdmin
 unAuthorizedRoomIds:(NSArray<NSString*>*)unAuthorizedRoomIds
unAuthorizedDevcedIds:(NSArray<NSString*>*)unAuthorizedDevcedIds
unAuthorizedGroupIds:(NSArray<NSString*>*)unAuthorizedGroupIds
unAuthorizedSceneNos:(NSArray<NSString*>*)unAuthorizedSceneNos
            userBind:(HMDoorUserBind *)user
          completion:(commonBlockWithObject)completion;

/**
 删除家庭成员

 @param familyUser 要删除的家庭成员 HMFamilyUsers 实例
 @param completion 回调方法使用服务器返回数据
 */
+ (void)deleteFamilyUsers:(HMFamilyUsers *)familyUser completion:(commonBlockWithObject)completion;
+ (void)deleteFamilyUsers:(HMFamilyUsers *)familyUser deleteLocal:(BOOL)deleteLocal completion:(commonBlockWithObject)completion;

/**
 删除家庭（必须是管理员用户/家庭的创建者）

 @param familyId 该家庭的id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)deleteFamily:(NSString *)familyId completion:(commonBlockWithObject)completion;

/**
 家庭成员退出家庭（该用户不是家庭的管理员/家庭的创建者）

 @param familyId 该家庭的id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)exitFamily:(NSString *)familyId completion:(commonBlockWithObject)completion;

/**
 局域网搜索家庭（里面执行了两个步骤：1. 先局域网搜索主机，获得把主机的uid列表 2. 传入主机uid列表，局域网搜索家庭）

 @param completion 回调方法使用服务器返回数据（返回的familyList数组中，包括familyId，familyName，pic，creator，email，phone，userName，nicknameInFamily等信息）
 */
+ (void)searchFamilyInLanWithCompletion:(commonBlockWithObject)completion;

/**
 请求加入家庭(有管理员的家庭)

 返回status
 0：处理成功(加入家庭申请已发送给管理员，等待确认)
 1：处理失败
 33：已经是家庭成员
 
 @param familyId 该家庭的id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)joinFamily:(NSString *)familyId completion:(commonBlockWithObject)completion;

/**
 主账号接受或拒绝子账号的加入家庭申请
 
 返回status
 0：处理成功
 1：处理失败
 36：该请求已经被处理过
 60：不是家庭管理员
 
 @param familyJoinId 加入家庭申请的申请id
 @param accept 是否接受
 @param completion 回调方法使用服务器返回数据
 */
+ (void)responseJoinFamilyWithFamilyJoinId:(NSString *)familyJoinId accept:(BOOL)accept completion:(commonBlockWithObject)completion;

/**
 请求加入家庭(无管理员的家庭)
 
 返回status
 0：处理成功(无管理员家庭，加入成功)
 1：处理失败
 
 @param familyId 该家庭的id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)joinFamilyAsAdmin:(NSString *)familyId completion:(commonBlockWithObject)completion;

/**
 查询某用户在某家庭的房间权限

 @param familyId 该家庭的id
 @param userId 该用户的id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)queryRoomAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId completion:(commonBlockWithObject)completion;

/**
 查询某用户在某家庭的设备权限
 
 @param familyId 该家庭的id
 @param userId 该用户的id
 @param completion 回调方法使用服务器返回数据
 */
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

/**
 修改某用户在某家庭的房间权限
 
 @param familyId 该家庭的id
 @param userId 该用户的id
 @param roomId 要修改权限的房间id
 @param authorized 设定成可访问或不可访问：YES（可访问），NO（不可访问）
 @param completion 回调方法使用服务器返回数据
 */
+ (void)modifyRoomAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId roomId:(NSString *)roomId authorized:(BOOL)authorized completion:(commonBlockWithObject)completion;

/**
 修改某用户在某家庭的设备权限

 @param familyId 该家庭的id
 @param userId 该用户的id
 @param authorizedList 允许访问的设备id列表 (类型：[String])
 @param unauthorizedList 不允许访问的设备id列表 (类型：[String])
 @param completion 回调方法使用服务器返回数据
 */
+ (void)modifyDeviceAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId authorizedList:(NSArray <HMDevice *>*)authorizedList unauthorizedList:(NSArray <HMDevice *>*)unauthorizedList completion:(commonBlockWithObject)completion;

/**
 设为/解除家庭管理员（必须是该家庭的超级管理员才能调用此接口）

 @param familyId 该家庭的id
 @param userId   被设定/解除的用户的id
 @param toBeAdmin YES:设成管理员，NO:解除管理员
 @param completion 回调方法使用服务器返回数据
 */
+ (void)modifyFamilyAdminAuthorityWithFamilyId:(NSString *)familyId userId:(NSString *)userId toBeAdmin:(BOOL)toBeAdmin completion:(commonBlockWithObject)completion;

/**
 通过手机号码或者邮箱查找家庭管理员帐号。

 @param userName 手机号码或者邮箱，必填
 @param completion 回调方法使用服务器返回数据
 */
+ (void)queryAdminFamilyWithUserName:(NSString *)userName completion:(commonBlockWithObject)completion;

/**
 通过familyId查询具体的家庭

 @param familyId 该家庭的id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)queryFamilyByFamilyId:(NSString *)familyId completion:(commonBlockWithObject)completion;


/**
 查询指定用户的所有终端设备信息，返回设备的标识信息和名称列表，按上报时间倒序排序，最近使用过的终端排在最上面
 
 @param userId 用户Id
 @param completion 回调方法使用服务器返回数据
 */
+ (void)queryUserTerminalDeviceByUserId:(NSString *)userId completion:(commonBlockWithObject)completion;

/**
 恢复家庭
 */
+ (void)recoverFamily:(NSString *)familyId completion:(commonBlockWithObject)completion;

@end

typedef HMFamilyAPI HMFaimilyAPI;

