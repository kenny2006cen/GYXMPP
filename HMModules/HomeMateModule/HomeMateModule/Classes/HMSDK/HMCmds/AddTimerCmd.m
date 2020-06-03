//
//  AddTimerCmd.m
//  Vihome
//
//  Created by Air on 15-3-10.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddTimerCmd.h"

@implementation AddTimerCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_AT;
}

-(NSDictionary *)payload
{
    
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:self.bindOrder forKey:@"order"];
    [sendDic setObject:[NSNumber numberWithInt:self.value1] forKey:@"value1"];
    [sendDic setObject:[NSNumber numberWithInt:self.value2] forKey:@"value2"];
    [sendDic setObject:[NSNumber numberWithInt:self.value3] forKey:@"value3"];
    [sendDic setObject:[NSNumber numberWithInt:self.value4] forKey:@"value4"];
    [sendDic setObject:[NSNumber numberWithInt:self.hour] forKey:@"hour"];
    [sendDic setObject:[NSNumber numberWithInt:self.minute] forKey:@"minute"];
    [sendDic setObject:[NSNumber numberWithInt:self.second] forKey:@"second"];
    [sendDic setObject:[NSNumber numberWithInt:self.week] forKey:@"week"];
    [sendDic setObject:[NSNumber numberWithInt:self.timingType] forKey:@"timingType"];

    [sendDic setObject:[NSNumber numberWithInt:self.typeId] forKey:@"typeId"];
    [sendDic setObject:[NSNumber numberWithInt:self.isHD] forKey:@"isHD"];

    
    
    if (self.name.length) {
        [sendDic setObject:self.name forKey:@"name"];
    }
    if (self.resourceId.length) {
        [sendDic setObject:self.resourceId forKey:@"resourceId"];
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
