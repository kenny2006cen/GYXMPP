//
//  StopLearningCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "StopLearningCmd.h"

@implementation StopLearningCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SO;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    
    return sendDic;
}


@end
