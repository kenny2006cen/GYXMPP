//
//  SetDeviceParamCmd.m
//  HomeMateSDK
//
//  Created by Air on 17/3/7.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "SetDeviceParamCmd.h"

@implementation SetDeviceParamCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SET_DEVICE_PARAM;
}

/*
 DeviceType为93，传感器接入模块 的子类型
 paramValue 取值范围
 
 0：暂不使用
 1：人体传感器
 2：红外对射
 3：门窗传感器
 4：烟雾报警器
 5：可燃气体报警器
 6：水浸传感器
 7：紧急按钮
 8：插卡取电
 9：其它
 */

-(NSDictionary *)payload
{
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    if (self.paramId) {
        [sendDic setObject:self.paramId forKey:@"paramId"];
    }
    if (self.paramType) {
        [sendDic setObject:@(self.paramType) forKey:@"paramType"];
    }
    if (self.paramValue) {
        [sendDic setObject:self.paramValue forKey:@"paramValue"];
    }
    if (self.deviceSettings) {
        [sendDic setObject:self.deviceSettings forKey:@"deviceSettings"];
    }
    return sendDic;
}


@end
