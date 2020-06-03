//
//  HMTimingBusiness.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseBusiness.h"

@interface HMTimingBusiness : HMBaseBusiness
//情景
+ (NSArray <HMTiming *>*)querySceneTimingsWithSceneNo:(NSString *)sceneNo;

+ (void)activate:(BOOL)activate sceneTiming:(HMTiming *)sceneTiming completion:(commonBlockWithObject)completion;

+ (void)addSceneTiming:(HMTiming *)sceneTiming scene:(HMScene *)scene completion:(commonBlockWithObject)completion;

+ (void)modifySceneTiming:(HMTiming *)sceneTiming completion:(commonBlockWithObject)completion;

+ (void)deleteSceneTiming:(NSString *)timingId completion:(commonBlockWithObject)completion;

+ (HMTiming *)querySceneTimingWhichIsActiveAndCanExecuteTodayWithSceneNo:(NSString *)sceneNo;

//安防
+ (NSArray <HMTiming *>*)querySecurityTimingsWithFamilyId:(NSString *)familyId;

+ (HMTiming *)querySecurityTimingWhichIsActiveAndCanExecuteTodayWithFamilyId:(NSString *)familyId;
@end
