//
//  HMTimingAPI.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMTimingAPI.h"
#import "HMTimingBusiness.h"

#import "HMTiming.h"
#import "HMScene.h"

@implementation HMTimingAPI
//情景
+ (NSArray <HMTiming *>*)querySceneTimingsWithSceneNo:(NSString *)sceneNo {
    return [HMTimingBusiness querySceneTimingsWithSceneNo:sceneNo];
}

+ (void)activate:(BOOL)activate sceneTiming:(HMTiming *)sceneTiming completion:(commonBlockWithObject)completion {
    [HMTimingBusiness activate:activate sceneTiming:sceneTiming completion:completion];
}

+ (void)addSceneTiming:(HMTiming *)sceneTiming scene:(HMScene *)scene completion:(commonBlockWithObject)completion {
    [HMTimingBusiness addSceneTiming:sceneTiming scene:scene completion:completion];
}

+ (void)modifySceneTiming:(HMTiming *)sceneTiming completion:(commonBlockWithObject)completion {
    [HMTimingBusiness modifySceneTiming:sceneTiming completion:completion];
}

+ (void)deleteSceneTiming:(NSString *)timingId completion:(commonBlockWithObject)completion {
    [HMTimingBusiness deleteSceneTiming:timingId completion:completion];
}
+ (HMTiming *)querySceneTimingWhichIsActiveAndCanExecuteTodayWithSceneNo:(NSString *)sceneNo {
    return [HMTimingBusiness querySceneTimingWhichIsActiveAndCanExecuteTodayWithSceneNo:sceneNo];
}

//安防
+ (NSArray <HMTiming *>*)querySecurityTimingsWithFamilyId:(NSString *)familyId {
    return [HMTimingBusiness querySecurityTimingsWithFamilyId:familyId];
}

+ (HMTiming *)querySecurityTimingWhichIsActiveAndCanExecuteTodayWithFamilyId:(NSString *)familyId{
    return [HMTimingBusiness querySecurityTimingWhichIsActiveAndCanExecuteTodayWithFamilyId:familyId];
}
@end
