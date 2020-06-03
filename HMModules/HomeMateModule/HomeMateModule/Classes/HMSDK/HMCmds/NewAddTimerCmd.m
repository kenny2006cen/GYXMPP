//
//  NewAddTimerCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2017/3/3.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "NewAddTimerCmd.h"


@implementation NewAddTimerCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ADD_SECURITY_SCENE;
}

-(NSDictionary *)payload
{
    if (self.name.length) {
        [sendDic setObject:self.name forKey:@"name"];
    }
    if (self.bindOrder) {
        [sendDic setObject:self.bindOrder forKey:@"order"];
    }
    if (self.order) {
        [sendDic setObject:self.order forKey:@"order"];
    }
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    
    [sendDic setObject:@(self.value1) forKey:@"value1"];
    [sendDic setObject:@(self.value2) forKey:@"value2"];
    [sendDic setObject:@(self.value3) forKey:@"value3"];
    [sendDic setObject:@(self.value4) forKey:@"value4"];
    [sendDic setObject:@(self.hour) forKey:@"hour"];
    [sendDic setObject:@(self.minute) forKey:@"minute"];
    [sendDic setObject:@(self.second) forKey:@"second"];
    [sendDic setObject:@(self.week) forKey:@"week"];
    [sendDic setObject:@(self.timingType) forKey:@"timingType"];
    
    return sendDic;
}
@end
