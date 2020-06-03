//
//  HMTimingAPI.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseAPI.h"
#import "HMTypes.h"

@class HMTiming;
@class HMScene;

@interface HMTimingAPI : HMBaseAPI

/**
 查询情景定时

 @param sceneNo 这些情景定时所在的情景的sceneNo
 @return 情景定时列表
 */
+ (NSArray <HMTiming *>*)querySceneTimingsWithSceneNo:(NSString *)sceneNo;

/**
 激活/关闭情景定时

 @param activate 是否要激活
 @param sceneTiming 情景定时对象
 @param completion 完成回调
 */
+ (void)activate:(BOOL)activate sceneTiming:(HMTiming *)sceneTiming completion:(commonBlockWithObject)completion;

/**
 添加情景定时

 @param sceneTiming 情景定时对象
 @param scene 该情景定时对应的情景对象
 @param completion 完成回调
 */
+ (void)addSceneTiming:(HMTiming *)sceneTiming scene:(HMScene *)scene completion:(commonBlockWithObject)completion;

/**
 修改情景定时

 @param sceneTiming 情景定时对象
 @param completion 完成回调
 */
+ (void)modifySceneTiming:(HMTiming *)sceneTiming completion:(commonBlockWithObject)completion;

/**
 删除情景定时

 @param timingId 情景定时id
 @param completion 完成回调
 */
+ (void)deleteSceneTiming:(NSString *)timingId completion:(commonBlockWithObject)completion;

/**
 查询今天可执行的激活状态的情景定时
 
 @param sceneNo 这些情景定时所在的情景的sceneNo
 @return 情景定时
 */
+ (HMTiming *)querySceneTimingWhichIsActiveAndCanExecuteTodayWithSceneNo:(NSString *)sceneNo;

/**
 查询安防定时
 
 @return 安防定时列表
 */
+ (NSArray <HMTiming *>*)querySecurityTimingsWithFamilyId:(NSString *)familyId;

/**
 查询今天可执行的激活状态的安防定时
 
 @return 安防定时
 */
+ (HMTiming *)querySecurityTimingWhichIsActiveAndCanExecuteTodayWithFamilyId:(NSString *)familyId;
@end
