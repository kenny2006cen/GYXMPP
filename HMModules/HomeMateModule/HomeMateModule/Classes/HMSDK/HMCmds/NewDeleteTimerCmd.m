//
//  NewDeleteTimerCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2017/3/3.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "NewDeleteTimerCmd.h"

@implementation NewDeleteTimerCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DELETE_SECURITY_SCENE;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.timingId forKey:@"timingId"];
    return sendDic;
}
@end
