//
//  DeviceSearchCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeviceSearchCmd.h"

@implementation DeviceSearchCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DC;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.Type forKey:@"type"];
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.uidList) {
        [sendDic setObject:self.uidList forKey:@"uidList"];
    }
    return sendDic;
}


@end
