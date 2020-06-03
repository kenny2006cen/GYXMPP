//
//  DelInfraredKeyCMD.m
//  Vihome
//
//  Created by Ned on 5/8/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DelInfraredKeyCmd.h"

@implementation DelInfraredKeyCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DIK;
}

-(NSDictionary *)payload
{
    if (self.deviceIrId) {
        [sendDic setObject:self.deviceIrId forKey:@"deviceIrId"];
    }
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    if (self.kkIrId) {
        [sendDic setObject:self.kkIrId forKey:@"kkIrId"];
    }
    
    [sendDic setObject:@(self.type) forKey:@"type"];
    
    return sendDic;
}

@end
