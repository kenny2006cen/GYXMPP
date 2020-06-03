//
//  DeleteDeviceCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeleteDeviceCmd.h"

@implementation DeleteDeviceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DD;
}

-(NSDictionary *)payload
{
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    if (self.extAddr) {
        [sendDic setObject:self.extAddr forKey:@"extAddr"];
    }
    
    
    return sendDic;
}


@end
