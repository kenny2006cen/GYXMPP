//
//  NewModifyTimerCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2017/3/3.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "NewModifyTimerCmd.h"

@implementation NewModifyTimerCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MODIFY_SECURITY_SCENE;
}

-(NSDictionary *)payload
{
    if (self.name) {
        [sendDic setObject:self.name forKey:@"name"];
    }
    
    if (self.timingId) {
        [sendDic setObject:self.timingId forKey:@"timingId"];
    }
    
    if (self.order) {
        [sendDic setObject:self.order forKey:@"order"];
    }
    
    [sendDic setObject:@(self.value1) forKey:@"value1"];
    [sendDic setObject:@(self.value2) forKey:@"value2"];
    [sendDic setObject:@(self.value3) forKey:@"value3"];
    [sendDic setObject:@(self.value4) forKey:@"value4"];
    [sendDic setObject:@(self.hour) forKey:@"hour"];
    [sendDic setObject:@(self.minute) forKey:@"minute"];
    [sendDic setObject:@(self.second) forKey:@"second"];
    [sendDic setObject:@(self.week) forKey:@"week"];

    return sendDic;
}
@end
