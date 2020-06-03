//
//  AddCameraCmd.m
//  Vihome
//
//  Created by Air on 15-3-10.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddCameraCmd.h"

@implementation AddCameraCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_AC;
}

-(NSDictionary *)payload
{
    [sendDic setObject:[NSNumber numberWithInt:self.type] forKey:@"type"];
    [sendDic setObject:self.cameraUID forKey:@"cameraUid"];
    [sendDic setObject:self.user forKey:@"user"];
    [sendDic setObject:self.password forKey:@"password"];
    
    return sendDic;
}


@end
