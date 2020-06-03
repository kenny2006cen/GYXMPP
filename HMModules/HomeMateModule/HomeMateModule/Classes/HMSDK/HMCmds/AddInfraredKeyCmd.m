//
//  AddInfraredKeyCMD.m
//  Vihome
//
//  Created by Ned on 5/8/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddInfraredKeyCmd.h"

@implementation AddInfraredKeyCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_AIK;
}

-(NSDictionary *)payload
{
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    if (self.keyName) {
        [sendDic setObject:self.keyName forKey:@"keyName"];
    }
    [sendDic setObject:@(self.keyType) forKey:@"keyType"];
    
    if (self.bindDeviceId) {
        [sendDic setObject:self.bindDeviceId forKey:@"bindDeviceId"];
    }
    
    if (self.order) {
        [sendDic setObject:self.order forKey:@"order"];
    }

    [sendDic setObject:@(self.rid) forKey:@"rid"];
    [sendDic setObject:@(self.fid) forKey:@"fid"];

    return sendDic;
}

@end
