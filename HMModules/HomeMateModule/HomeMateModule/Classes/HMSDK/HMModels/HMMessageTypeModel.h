//
//  HMMessageType.h
//  HomeMateSDK
//
//  Created by liuzhicai on 2018/2/6.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMMessageTypeModel : HMBaseModel

@property (nonatomic,strong) NSString * typeId;

//1告警消息，2系统消息，3低电量消息 4设备状态消息  5定时提醒消息
@property (nonatomic, assign) int type;

// 某家庭拥有的消息类型数组，数组由 @(1),@(2)... 等组成
+ (NSMutableArray *)messageTypesArrOfFamilyId:(NSString *)familyId;


@end
