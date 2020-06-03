//
//  MassAddRoomCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2018/6/14.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "MassAddRoomCmd.h"

@implementation MassAddRoomCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ADD_ROOMS;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.floorId forKey:@"floorId"];
    [sendDic setObject:self.rooms forKey:@"rooms"];

    return sendDic;
}

@end
