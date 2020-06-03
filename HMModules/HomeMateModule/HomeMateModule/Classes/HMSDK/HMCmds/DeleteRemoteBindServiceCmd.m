//
//  DeleteRemoteBindServiceCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeleteRemoteBindServiceCmd.h"

@implementation DeleteRemoteBindServiceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DELETE_REMOTE_BIND_NEW;
}

-(NSDictionary *)payload
{
    if (self.remoteBindId) {
        [sendDic setObject:self.remoteBindId forKey:@"remoteBindId"];
    }
    
    return sendDic;
}

-(BOOL)sendToServer{
    
    return YES;
}

@end
