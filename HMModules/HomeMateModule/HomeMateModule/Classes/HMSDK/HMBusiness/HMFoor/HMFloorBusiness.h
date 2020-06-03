//
//  HMFloorBusiness.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseBusiness.h"

@interface HMFloorBusiness : HMBaseBusiness

+ (void)createFloor:(NSString *)floorName familyId:(NSString *)familyId completion:(commonBlockWithObject)completion;
+ (void)createFloor:(NSString *)floorName familyId:(NSString *)familyId loading:(BOOL)loading completion:(commonBlockWithObject)completion;

+ (void)modifyFloorName:(NSString *)floorName floorId:(NSString *)floorId completion:(commonBlockWithObject)completion;
+ (void)modifyFloorName:(NSString *)floorName floorId:(NSString *)floorId loading:(BOOL)loading completion:(commonBlockWithObject)completion;

+ (void)deleteFloor:(NSString *)floorId completion:(commonBlockWithObject)completion;
+ (void)deleteFloor:(NSString *)floorId loading:(BOOL)loading completion:(commonBlockWithObject)completion;

+ (NSArray<HMFloor *> *)queryFloorsWithFamilyId:(NSString *)familyId;

+ (NSArray<HMRoom *> *)queryRoomsWithFloorId:(NSString *)floorId;

+ (void)createRoom:(NSString *)roomName floorId:(NSString *)floorId completion:(commonBlockWithObject)completion;
+ (void)createRoom:(NSString *)roomName floorId:(NSString *)floorId loading:(BOOL)loading completion:(commonBlockWithObject)completion;

+ (void)modifyRoom:(NSString *)roomName roomId:(NSString *)roomId completion:(commonBlockWithObject)completion;
+ (void)modifyRoom:(NSString *)roomName roomId:(NSString *)roomId loading:(BOOL)loading completion:(commonBlockWithObject)completion;

+ (void)deleteRoom:(NSString *)roomId completion:(commonBlockWithObject)completion;
+ (void)deleteRoom:(NSString *)roomId loading:(BOOL)loading completion:(commonBlockWithObject)completion;

+ (void)addRooms:(NSArray *)rooms floorId:(NSString *)floorId loading:(BOOL)loading completion:(commonBlockWithObject)completion;
@end
