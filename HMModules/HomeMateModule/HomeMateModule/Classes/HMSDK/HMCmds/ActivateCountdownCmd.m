//
//  ActivateCountdownCmd.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "ActivateCountdownCmd.h"

@implementation ActivateCountdownCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ACCD;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.countdownId forKey:@"countdownId"];
    [sendDic setObject:@(self.isPause) forKey:@"isPause"];
    [sendDic setObject:@(self.startTime) forKey:@"startTime"];
    return sendDic;
}
@end
