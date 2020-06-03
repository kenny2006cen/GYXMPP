//
//  DataToDeviceCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 16/11/25.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DataToDeviceCmd.h"

@implementation DataToDeviceCmd
- (VIHOME_CMD)cmd {
    return VIHOME_CMD_DATA_TO_DEVICE;
}

-(NSDictionary *)payload
{
    if (self.deviceId.length) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    
    if (_payload) {
        [sendDic setObject:_payload forKey:@"payload"];
    }
    
    [sendDic setObject:@(self.ackRequire) forKey:@"ackRequire"];
    
    return sendDic;
}
@end
