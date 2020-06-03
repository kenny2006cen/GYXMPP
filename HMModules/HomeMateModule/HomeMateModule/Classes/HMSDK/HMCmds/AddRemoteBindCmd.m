//
//  AddRoomBindCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddRemoteBindCmd.h"

@implementation AddRemoteBindCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_AM;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.remoteBindList forKey:@"remoteBindList"];
    
    return sendDic;
}


@end
