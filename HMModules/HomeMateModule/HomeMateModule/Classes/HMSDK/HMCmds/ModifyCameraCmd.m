//
//  ModifyCameraCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyCameraCmd.h"

@implementation ModifyCameraCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MD;
}

-(NSDictionary *)payload
{
    [sendDic setObject:[NSNumber numberWithInt:self.deviceId] forKey:@"deviceId"];
    [sendDic setObject:self.deviceName forKey:@"deviceName"];
    [sendDic setObject:[NSNumber numberWithInt:self.roomId] forKey:@"roomId"];
    [sendDic setObject:self.user forKey:@"user"];
    [sendDic setObject:self.password forKey:@"password"];
    
    return sendDic;
}


@end
