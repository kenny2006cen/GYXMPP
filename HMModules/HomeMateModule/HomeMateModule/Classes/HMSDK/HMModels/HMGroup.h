//
//  HMGroup.h
//  HomeMate
//
//  Created by liqiang on 16/11/9.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel.h"

@class HMDevice;

typedef NS_ENUM(NSInteger,HMGrpupType) {
    HMGrpupTypeSocket = 1,//插座
    HMGrpupTypeLight,//灯光
    HMGrpupTypeDimmingLight,//调光灯
    HMGrpupTypeColorTemperatureLight,//色温灯
    HMGrpupTypeRGBLight,//RGB灯
    HMGrpupTypeWindowCurtains,//窗帘
    HMGrpupTypeCentralAirCondition,//中央空调
};


@interface HMGroup : HMBaseModel
@property (nonatomic, copy) NSString * userId;
@property (nonatomic, strong) NSString * roomId;
@property (nonatomic, strong) NSString * groupId;
@property (nonatomic, strong) NSString * groupName;
@property (nonatomic, assign) NSString * pic;
@property (nonatomic, assign)int groupNo;
@property (nonatomic, assign)int groupType;



+ (BOOL)deleteGroupDevice:(HMDevice *)device;

+ (BOOL)updateGroupDevice:(HMDevice *)device;

/// 为了方便处理，这个查出来的组转化成device对象
+ (NSArray <HMDevice *>*)allGroups;

/// 为了方便处理，这个查出来的组转化成device对象
+ (NSArray <HMDevice *>*)groupsInRoomId:(NSString *)roomId;

/// 设备组成员的数量
/// @param device 设备组转成的device对象
+ (int)groupMemberCountForGroup:(HMDevice *)device;

/// 为了方便处理，这个查出来的组转化成device对象
+ (NSArray <HMDevice *>*)groupsInDefaultRoomId:(NSString *)roomId;

/// 将组对象转为device对象
+ (HMDevice *)deviceFromGroup:(HMGroup *)group;

/// 根据groupId查组,并转成device对象
+ (HMDevice *)deviceFromGroupId:(NSString *)groupId;

/// 将组对象转为device对象
+ (HMGroup *)groupFromDevice:(HMDevice *)device;

@end
