//
//  ModifyRemoteBindCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyRemoteBindCmd.h"

@implementation ModifyRemoteBindCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MM;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.remoteBindList forKey:@"remoteBindList"];
    
    return sendDic;
}


@end
