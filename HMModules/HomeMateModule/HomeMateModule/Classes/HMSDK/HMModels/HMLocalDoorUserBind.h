//
//  HMLocalDoorUserBind.h
//  HomeMateSDK
//
//  Created by peanut on 2019/4/4.
//  Copyright © 2019 orvibo. All rights reserved.
//
#import "HMBaseModel.h"
#import "HMConstant.h"


@interface HMLocalDoorUserBind : HMDoorUserBind

+ (HMLocalDoorUserBind *)objectFromDoorUserBind:(HMDoorUserBind *)userBind;
+ (NSMutableArray *)localObjectForextAddr:(HMDevice *)device;
+ (NSMutableArray *)localUpdateToServerObjectForextAddr:(HMDevice *)device;
+ (void)uploadLoaclUserToServer;
+ (BOOL)deleteExtAddrInArray:(NSArray *)extAddrArray;
@end
