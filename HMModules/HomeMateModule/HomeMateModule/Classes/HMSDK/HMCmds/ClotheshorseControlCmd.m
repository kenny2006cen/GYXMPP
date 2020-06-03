//
//  ClotheshorseControlCmd.m
//  HomeMate
//
//  Created by Air on 15/11/17.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "ClotheshorseControlCmd.h"

@implementation ClotheshorseControlCmd

-(VIHOME_CMD)cmd
{
    return CLOTHESHORSE_CMD_CONTROL;
}

-(NSDictionary *)payload
{
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    if (self.motorCtrl) {
        [sendDic setObject:self.motorCtrl forKey:@"motorCtrl"];
    }
    if (self.lightingCtrl) {
        [sendDic setObject:self.lightingCtrl forKey:@"lightingCtrl"];
    }
    if (self.sterilizingCtrl) {
        [sendDic setObject:self.sterilizingCtrl forKey:@"sterilizingCtrl"];
    }
    if (self.heatDryingCtrl) {
        [sendDic setObject:self.heatDryingCtrl forKey:@"heatDryingCtrl"];
    }
    if (self.windDryingCtrl) {
        [sendDic setObject:self.windDryingCtrl forKey:@"windDryingCtrl"];
    }
    if (self.mainSwitchCtrl) {
        [sendDic setObject:self.mainSwitchCtrl forKey:@"mainSwitchCtrl"];
    }
    if (self.queryState) {
        [sendDic setObject:self.queryState forKey:@"queryState"];
    }
    
    if (self.clientSessionId) {
        [sendDic setObject:self.clientSessionId forKey:@"clientSessionId"];
    }
    
    return sendDic;
}

@end
