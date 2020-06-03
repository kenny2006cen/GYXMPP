//
//  ClotheshorseCountdownSettingCmd.m
//  HomeMate
//
//  Created by Air on 15/11/17.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "ClotheshorseCountdownSettingCmd.h"

@implementation ClotheshorseCountdownSettingCmd

-(VIHOME_CMD)cmd
{
    return CLOTHESHORSE_CMD_COUNTDOWN_SETTING;
}

-(NSDictionary *)payload
{
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    
    if (self.needLight) {
        [sendDic setObject:@(self.lightingTime) forKey:@"lightingTime"];
    }
    if (self.needSterilize) {
        [sendDic setObject:@(self.sterilizingTime) forKey:@"sterilizingTime"];
    }
    if (self.needHeatDry) {
        [sendDic setObject:@(self.heatDryingTime) forKey:@"heatDryingTime"];
    }
    if (self.needWindDry) {
        [sendDic setObject:@(self.windDryingTime) forKey:@"windDryingTime"];
    }

    return sendDic;
}



@end
