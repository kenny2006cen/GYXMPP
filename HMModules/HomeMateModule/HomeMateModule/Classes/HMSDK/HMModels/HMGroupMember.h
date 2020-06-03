//
//  HMGroupMember.h
//  HomeMate
//
//  Created by liqiang on 16/11/14.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel.h"

#import "HMBaseModel+Extension.h"
@class HMDeviceStatus;


@interface HMGroupMember : HMBaseModel<SceneEditProtocol>
@property (nonatomic, strong)NSString * groupMemberId;
@property (nonatomic, strong)NSString * deviceId;
@property (nonatomic, strong)NSString * groupId;


// 以下为非协议字段

@property (nonatomic, strong)NSString *         bindOrder;

@property (nonatomic, assign)int                value1;

@property (nonatomic, assign)int                value2;

@property (nonatomic, assign)int                value3;

@property (nonatomic, assign)int                value4;

@property (nonatomic, assign)int                delayTime;
@property (nonatomic, strong)NSString *         deviceName;
@property (nonatomic, strong)NSString *         floorRoom;
@property (nonatomic, strong)NSString *         roomId;
@property (nonatomic, assign)KDeviceType        deviceType;
@property (nonatomic, assign)int                subDeviceType; //设备子类型(传感器接入模块)
@property (nonatomic, assign)BOOL               selected;
@property (nonatomic, assign,readonly) BOOL     isLearnedIR;
@property (nonatomic, assign,readonly) BOOL     changed;

+ (instancetype)deviceObject:(FMResultSet *)rs;

+ (instancetype)bindObject:(FMResultSet *)rs;

+ (NSArray <HMGroupMember *>*)groupMembers:(NSString *)groupId;

+ (NSArray <HMDeviceStatus *> *)groupMemberStatusForGroupId:(NSString *)groupId;

// device widget 使用
+ (NSArray <NSMutableDictionary *> *)groupMemberStatusDictWithGroupId:(NSString *)groupId;

+ (BOOL)deleteGroupMemberGroupId:(NSString *)groupId uids:(NSArray *)uids;

@end
