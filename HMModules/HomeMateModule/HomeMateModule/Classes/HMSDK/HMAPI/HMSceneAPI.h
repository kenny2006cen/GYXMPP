//
//  HMSceneAPI.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseAPI.h"
#import "HMTypes.h"

@class HMScene;

@class HMSceneBind;


@interface HMSceneAPI : HMBaseAPI

/**
 创建情景 create a scene
 
 @param sceneName 情景模式名称
 @param pic 情景图标编号
 @param completion 回调方法返回已经创建成功的 HMScene 对象的实例 return HMScene instance
 */
+ (void)createSceneWithName:(NSString *)sceneName pic:(int)pic completion:(commonBlockWithObject)completion;

/**
 修改情景 modify the scene

 @param sceneNo 情景No
 @param sceneName 情景名称
 @param pic 情景图标编号
 @param completion 回调方法返回修改成功后的 HMScene 对象的实例 return HMScene instance
 */
+ (void)modifySceneWithNo:(NSString *)sceneNo sceneName:(NSString *)sceneName pic:(int)pic imageURL:(NSString *)imageURL completion:(commonBlockWithObject)completion;

/**
 删除情景绑定 delete scene bind

 @param sceneBindArray 要删除的情景绑定列表
 @param sceneNo 情景No
 @param completion 服务器返回数据
 */
+ (void)deleteSceneBinds:(NSArray *)sceneBindArray sceneNo:(NSString *)sceneNo completion:(commonBlockWithObject)completion;


/**
 添加情景绑定 add scene bind

 @param sceneBindArray 要添加的情景绑定列表
 @param sceneNo 情景 No
 @param completion 服务器返回数据
 */
+ (void)addSceneBinds:(NSArray *)sceneBindArray sceneNo:(NSString *)sceneNo completion:(commonBlockWithObject)completion;

/**
 修改情景绑定

 @param sceneBindArray 要修改的情景绑定
 @param sceneNo 情景 No
 @param completion 服务器返回数据
 */
+ (void)modifySceneBinds:(NSArray *)sceneBindArray sceneNo:(NSString *)sceneNo completion:(commonBlockWithObject)completion;

/**
 删除情景

 @param scene 情景实例对象
 @param completion 服务器返回数据
 */
+ (void)deleteScene:(HMScene *)scene completion:(commonBlockWithObject)completion;


/**
 触发情景

 @param scene 情景实例对象
 @param completion 服务器返回数据
 */
+ (void)triggleSceneWithScene:(HMScene *)scene completion:(commonBlockWithObject)completion;

/**
 功能同方法 triggleSceneWithScene:completion: 使用场景为无法获取HMScene实例信息
 
 @param sceneNo 情景sceneNo
 @param sceneId 情景sceneId
 @param uidArray 当前情景绑定的设备所在的主机的uid数组，如果情景绑定了多台主机，那么uid数组中应该包含多个uid信息 【调用scene.zigbeeHostUidArray可以获取】
 @param completion 服务器返回数据
 */
+ (void)sceneControlWithSceneNo:(NSString *)sceneNo sceneId:(int)sceneId uidArray:(NSArray *)uidArray completion:(commonBlockWithObject)completion;

+ (void)querySceneAuthorityOfUserId:(NSString *)userId familyId:(NSString *)familyId completion:(commonBlockWithObject)completion;

+ (void)modifyMemberAuthorityOfUserId:(NSString *)userId
                             familyId:(NSString *)familyId
                        authorityType:(int)authorityType
                             dataList:(NSArray *)dataList
                           completion:(commonBlockWithObject)completion;

/**
 查询情景下面的所有自定义通知，各有哪些用户有权限可以查看
 
 @param sceneNo 如果为nil，则查询家庭下所有的情景绑定的自定义通知的用户权限
 @param completion 服务器返回数据
 */
+ (void)queryNotificationAuthorityOfSceneNo:(NSString *)sceneNo completion:(commonBlockWithObject)completion;

/** 对于自定义通知，把成员信息转化成协议中的标准json格式 */
+(NSArray *)authListWithSceneBind:(HMSceneBind *)bind isModify:(BOOL)modify;

@end





