//
//  AddRoomCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddRoomCmd.h"

@implementation AddRoomCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_AR;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.roomName forKey:@"roomName"];
    [sendDic setObject:@(self.roomType) forKey:@"roomType"];
    [sendDic setObject:self.floorId forKey:@"floorId"];
    return sendDic;
}


@end
