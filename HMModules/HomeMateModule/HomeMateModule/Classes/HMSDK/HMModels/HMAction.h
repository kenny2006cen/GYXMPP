//
//  VihomeAction.h
//  Vihome
//
//  Created by Ned on 4/21/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMAction : HMBaseModel <OrderProtocol>

@property (nonatomic, strong) NSString *       actionName;

@property (nonatomic, strong) NSString *       bindOrder;

@property (nonatomic, assign)int                value1;

@property (nonatomic, assign)int                value2;

@property (nonatomic, assign)int                value3;

@property (nonatomic, assign)int                value4;
@property (nonatomic, assign)int                delayTime;

@property (nonatomic, assign)int                hue;

@property (nonatomic, assign)int                saturation;

@property (nonatomic, strong) NSString *       deviceId;

@property (nonatomic, copy) NSString *        pluseData;

@property (nonatomic, assign) int pluseNum;

@property (nonatomic, assign) KDeviceType     deviceType;
@property (nonatomic, assign) int     subDeviceType;

// 幻彩灯带用到
@property (nonatomic, copy) NSString * themeId;

- (void)copyValueFromCommonObject:(id)value;

- (void)fillValueToCommonObject:(id)value;

@end
