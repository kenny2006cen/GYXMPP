//
//  DeleteUserCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeleteUserCmd.h"

@implementation DeleteUserCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DU;
}

-(NSDictionary *)payload
{
    [sendDic setObject:[NSNumber numberWithInt:self.userId] forKey:@"userId"];
    
    
    return sendDic;
}


@end
