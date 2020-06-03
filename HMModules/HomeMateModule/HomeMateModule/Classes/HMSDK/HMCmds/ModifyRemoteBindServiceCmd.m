//
//  ModifyRemoteBindServiceCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyRemoteBindServiceCmd.h"

@implementation ModifyRemoteBindServiceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MODIFY_REMOTE_BIND_NEW;
}

-(NSDictionary *)payload
{
    if (self.remoteBind) {
        [sendDic setObject:self.remoteBind forKey:@"remoteBind"];
    }
    if (self.deleteRemoteBindId) {
        [sendDic setObject:self.deleteRemoteBindId forKey:@"deleteRemoteBindId"];
    }
    
    return sendDic;
}

-(BOOL)sendToServer{
    
    return YES;
}

@end
