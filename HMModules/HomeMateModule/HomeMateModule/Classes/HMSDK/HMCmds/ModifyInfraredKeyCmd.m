//
//  ModifyInfraredKeyCMD.m
//  Vihome
//
//  Created by Ned on 5/8/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyInfraredKeyCmd.h"

@implementation ModifyInfraredKeyCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MIK;
}

-(NSDictionary *)payload
{
    if (self.deviceIrId) {
        [sendDic setObject:self.deviceIrId forKey:@"deviceIrId"];
    }
    if (self.keyName) {
        [sendDic setObject:self.keyName forKey:@"keyName"];
    }
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    
    if (self.kkIrId) {
        [sendDic setObject:self.kkIrId forKey:@"kkIrId"];
    }
    
    if (self.deviceIrArray) {
        [sendDic setObject:self.deviceIrArray forKey:@"deviceIrArray"];
    }
    
    return sendDic;
}

@end
