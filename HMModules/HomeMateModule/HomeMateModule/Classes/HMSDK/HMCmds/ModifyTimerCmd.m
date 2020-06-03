//
//  EditTimerCmd.m
//  Vihome
//
//  Created by Ned on 3/25/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyTimerCmd.h"

@implementation ModifyTimerCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MT;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:self.bindOrder forKey:@"order"];
    [sendDic setObject:self.timingId forKey:@"timingId"];
    [sendDic setObject:[NSNumber numberWithInt:self.value1] forKey:@"value1"];
    [sendDic setObject:[NSNumber numberWithInt:self.value2] forKey:@"value2"];
    [sendDic setObject:[NSNumber numberWithInt:self.value3] forKey:@"value3"];
    [sendDic setObject:[NSNumber numberWithInt:self.value4] forKey:@"value4"];
    [sendDic setObject:[NSNumber numberWithInt:self.hour] forKey:@"hour"];
    [sendDic setObject:[NSNumber numberWithInt:self.minute] forKey:@"minute"];
    [sendDic setObject:[NSNumber numberWithInt:self.second] forKey:@"second"];
    [sendDic setObject:[NSNumber numberWithInt:self.week] forKey:@"week"];
    
    if (self.name.length) {
        [sendDic setObject:self.name forKey:@"name"];
    }
    [sendDic setObject:[NSNumber numberWithInt:self.pluseNum] forKey:@"pluseNum"];
    [sendDic setObject:[NSNumber numberWithInt:self.freq] forKey:@"freq"];
    
    if (self.pluseData.length) {
        [sendDic setObject:self.pluseData forKey:@"pluseData"];
    }
    if (self.startDate) {
        [sendDic setObject:self.startDate forKey:@"startDate"];
        
    }
    if (self.endDate) {
        [sendDic setObject:self.endDate forKey:@"endDate"];
        
    }
    
    if (self.themeId) {
        [sendDic setObject:self.themeId forKey:@"themeId"];
    }
    
    return sendDic;
}

@end
