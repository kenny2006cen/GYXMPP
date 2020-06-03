//
//  AddRoomBindCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddRemoteBindServiceCmd.h"

@implementation AddRemoteBindServiceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ADD_REMOTE_BIND_NEW;
}

-(NSDictionary *)payload
{
    if (self.remoteBind) {
        [sendDic setObject:self.remoteBind forKey:@"remoteBind"];
    }
    
    return sendDic;
}

-(BOOL)sendToServer
{
    return YES;
}
@end
