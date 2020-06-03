//
//  DeviceUnbindCmd.m
//  CloudPlatform
//
//  Created by orvibo on 15/6/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeviceUnbindCmd.h"

@implementation DeviceUnbindCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DEVICEUNBIND;
}

-(NSDictionary *)payload
{
    if(self.uid){
        [sendDic setObject:self.uid forKey:@"uid"];
    }
    return sendDic;
}


@end
