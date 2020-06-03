//
//  SetGenaralGateCmd.h
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/9/7.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface SetGenaralGateCmd : BaseCmd

@property (nonatomic, copy)NSString *deviceId; // 传虚拟端点deviceId
@property (nonatomic, copy)NSString *generalGate; // 总闸对应的设备id

@end
