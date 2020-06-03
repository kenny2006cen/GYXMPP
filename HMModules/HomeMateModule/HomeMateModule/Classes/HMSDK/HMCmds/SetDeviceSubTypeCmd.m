//
//  SetDeviceSubTypeCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2017/3/10.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "SetDeviceSubTypeCmd.h"

@implementation SetDeviceSubTypeCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SET_SUB_DEVICE_TYPE;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.uid forKey:@"uid"];
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:@(self.subDeviceType) forKey:@"subDeviceType"];

    return sendDic;
}

@end
