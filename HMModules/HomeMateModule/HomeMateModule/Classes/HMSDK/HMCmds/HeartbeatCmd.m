//
//  HeartbeatCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HeartbeatCmd.h"

@implementation HeartbeatCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_HB;
}

-(NSDictionary *)payload
{
    return sendDic;
}


@end
