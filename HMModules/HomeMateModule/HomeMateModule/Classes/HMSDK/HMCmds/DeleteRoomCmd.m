//
//  DeleteRoomCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeleteRoomCmd.h"

@implementation DeleteRoomCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DR;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.roomId forKey:@"roomId"];

    return sendDic;
}

@end
