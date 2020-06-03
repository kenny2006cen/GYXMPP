//
//  RestCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ResetCmd.h"

@implementation ResetCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_RS;
}

-(NSDictionary *)payload
{
    [sendDic setObject:[NSNumber numberWithInt:self.type] forKey:@"type"];
    return sendDic;
}


@end
