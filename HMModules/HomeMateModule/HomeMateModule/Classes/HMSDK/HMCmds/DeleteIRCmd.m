//
//  DeleteIRCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeleteIRCmd.h"

@implementation DeleteIRCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DI;
}

-(NSDictionary *)payload
{
    [sendDic setObject:[NSNumber numberWithInt:self.deviceIrId] forKey:@"deviceIrId"];
    [sendDic setObject:[NSNumber numberWithInt:self.deviceId] forKey:@"deviceId"];
    
    return sendDic;
}


@end
