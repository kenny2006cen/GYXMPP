//
//  HMSceneExtModel.h
//  HomeMateSDK
//
//  Created by orvibo on 16/10/7.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@class HMScene;
@class HMLinkageOutput;


@interface HMSceneExtModel : HMBaseModel

@property (nonatomic, copy, nullable) NSString *sceneNo;
@property (nonatomic, assign) int sequence;

+ (nullable NSArray <HMScene*>*)readAllSceneArray;

+ (nullable NSArray <HMLinkageOutput *>*)mixPadRecommendSceneInSceneNames:(nullable NSArray *)sceneNames;


- (void)insertObjectWithSceneNo:(nullable NSString *)sceneNo;
- (void)deleteObjectWithSceneNo:(nullable NSString *)sceneNo;

+ (int)sequenceWithSceneNo:(nullable NSString *)sceneNo;

@end
