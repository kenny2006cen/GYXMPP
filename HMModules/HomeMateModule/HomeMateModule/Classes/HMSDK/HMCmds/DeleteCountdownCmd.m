//
//  DeleteCountdownCmd.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "DeleteCountdownCmd.h"

@implementation DeleteCountdownCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DLCD;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.countdownId forKey:@"countdownId"];
    
    return sendDic;
}
@end
