//
//  HMFloorAPI.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMFloorAPI.h"
#import "HMFloorBusiness.h"

@implementation HMFloorAPI

+ (void)createFloor:(NSString *)floorName familyId:(NSString *)familyId completion:(commonBlockWithObject)completion {
    [HMFloorBusiness createFloor:floorName familyId:familyId completion:completion];
}

+ (void)modifyFloorName:(NSString *)floorName floorId:(NSString *)floorId completion:(commonBlockWithObject)completion {
    [HMFloorBusiness modifyFloorName:floorName floorId:floorId completion:completion];
}

+ (void)deleteFloor:(NSString *)floorId completion:(commonBlockWithObject)completion {
    [HMFloorBusiness deleteFloor:floorId completion:completion];
}

+ (NSArray<HMFloor *> *)queryFloorsWithFamilyId:(NSString *)familyId {
    return [HMFloorBusiness queryFloorsWithFamilyId:familyId];
}

+ (NSArray<HMRoom *> *)queryRoomsWithFloorId:(NSString *)floorId {
    return [HMFloorBusiness queryRoomsWithFloorId:floorId];
}

+ (void)createRoom:(NSString *)roomName floorId:(NSString *)floorId completion:(commonBlockWithObject)completion {
    [HMFloorBusiness createRoom:roomName floorId:floorId completion:completion];
}

+ (void)modifyRoom:(NSString *)roomName roomId:(NSString *)roomId completion:(commonBlockWithObject)completion {
    [HMFloorBusiness modifyRoom:roomName roomId:roomId completion:completion];
}

+ (void)deleteRoom:(NSString *)roomId loading:(BOOL)loading completion:(commonBlockWithObject)completion {
    [HMFloorBusiness deleteRoom:roomId loading:loading completion:completion];
}

+ (void)deleteRoom:(NSString *)roomId completion:(commonBlockWithObject)completion {
    [HMFloorBusiness deleteRoom:roomId loading:YES completion:completion];
}
+ (void)addRooms:(NSArray *)rooms floorId:(NSString *)floorId loading:(BOOL)loading completion:(commonBlockWithObject)completion
{
    [HMFloorBusiness addRooms:rooms floorId:floorId loading:loading completion:completion];
}
@end
