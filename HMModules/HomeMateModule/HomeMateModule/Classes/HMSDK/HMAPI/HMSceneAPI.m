//
//  HMSceneAPI.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMSceneAPI.h"
#import "HMSceneBusiness.h"
#import "HMScene.h"

@implementation HMSceneAPI

+ (void)createSceneWithName:(NSString *)sceneName pic:(int)pic completion:(commonBlockWithObject)completion{

    [HMSceneBusiness createScene:sceneName pic:pic completion:completion];
}

+ (void)modifySceneWithNo:(NSString *)sceneNo sceneName:(NSString *)sceneName pic:(int)pic imageURL:(NSString *)imageURL completion:(commonBlockWithObject)completion {

    [HMSceneBusiness modifySceneWithNo:sceneNo sceneName:sceneName pic:pic imageURL:(NSString *)imageURL completion:completion];
}

+ (void)deleteSceneBinds:(NSArray *)sceneBindArray sceneNo:(NSString *)sceneNo completion:(commonBlockWithObject)completion {

    [HMSceneBusiness deleteSceneBinds:sceneBindArray sceneNo:sceneNo completion:completion];
}

+ (void)addSceneBinds:(NSArray *)sceneBindArray sceneNo:(NSString *)sceneNo completion:(commonBlockWithObject)completion {

    [HMSceneBusiness addSceneBinds:sceneBindArray sceneNo:sceneNo completion:completion];
}

+ (void)modifySceneBinds:(NSArray *)sceneBindArray sceneNo:(NSString *)sceneNo completion:(commonBlockWithObject)completion {

    [HMSceneBusiness modifySceneBinds:sceneBindArray sceneNo:sceneNo completion:completion];
}

+ (void)deleteScene:(HMScene *)scene completion:(commonBlockWithObject)completion {

    [HMSceneBusiness deleteScene:scene completion:completion];
}

+ (void)triggleSceneWithScene:(HMScene *)scene completion:(commonBlockWithObject)completion {

    [HMSceneBusiness triggleSceneWithScene:(HMScene *)scene completion:completion];
}
+ (void)sceneControlWithSceneNo:(NSString *)sceneNo sceneId:(int)sceneId uidArray:(NSArray *)uidArray completion:(commonBlockWithObject)completion
{
    [HMSceneBusiness sceneControlWithSceneNo:sceneNo sceneId:sceneId uidArray:uidArray completion:completion];
}

+ (void)querySceneAuthorityOfUserId:(NSString *)userId familyId:(NSString *)familyId completion:(commonBlockWithObject)completion
{
    [HMSceneBusiness querySceneAuthorityOfUserId:userId familyId:familyId completion:completion];
}

+ (void)modifyMemberAuthorityOfUserId:(NSString *)userId
                             familyId:(NSString *)familyId
                        authorityType:(int)authorityType
                             dataList:(NSArray *)dataList
                           completion:(commonBlockWithObject)completion
{
    [HMSceneBusiness modifyMemberAuthorityOfUserId:userId familyId:familyId authorityType:authorityType dataList:dataList completion:completion];
}

+ (void)queryNotificationAuthorityOfSceneNo:(NSString *)sceneNo completion:(commonBlockWithObject)completion;
{
    [HMSceneBusiness queryNotificationAuthorityOfObjId:sceneNo authorityType:3 familyId:userAccout().familyId completion:completion];
}
+(NSArray *)authListWithSceneBind:(HMSceneBind *)bind isModify:(BOOL)modify
{
    return [HMSceneBusiness authListWithSceneBind:bind isModify:modify];
}
@end
