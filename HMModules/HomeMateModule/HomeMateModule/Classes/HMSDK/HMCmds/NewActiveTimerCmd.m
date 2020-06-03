//
//  NewActiveTimerCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2017/3/3.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "NewActiveTimerCmd.h"

@implementation NewActiveTimerCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ACTIVATE_SECURITY_SCENE;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.timingId forKey:@"timingId"];
    [sendDic setObject:@(self.isPause) forKey:@"isPause"];
    return sendDic;
}
@end
