//
//  SetPowerOnStateCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2019/10/15.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "SetPowerOnStateCmd.h"

@implementation SetPowerOnStateCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SET_POWER_ON_STATE;
}

-(NSDictionary *)payload
{
    
    if (self.uid) {
        [sendDic setObject:self.uid forKey:@"uid"];
    }
    
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    
    if (self.userName) {
        [sendDic setObject:self.userName forKey:@"userName"];
    }
    
    [sendDic setObject:@(self.status) forKey:@"status"];
    
    return sendDic;
}

@end
