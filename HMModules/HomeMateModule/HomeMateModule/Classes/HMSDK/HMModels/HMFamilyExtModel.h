//
//  HMFamilyExtModel.h
//  HomeMateSDK
//
//  Created by peanut on 2017/5/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"
@class HMFamily;

@interface HMFamilyExtModel : HMBaseModel

@property (nonatomic, copy) NSString * _Nullable userId;
@property (nonatomic, assign) int sequence;

+ (nullable NSMutableArray <HMFamily*>*)readAllFamilys;
+ (HMFamily *_Nullable)defaultFamily;
+ (instancetype _Nullable )objectWithFamily:(HMFamily *_Nullable)family sequence:(int)sequence;

@end
