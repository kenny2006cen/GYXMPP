//
//  ResendAuthorizedSmsCmd.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "ResendAuthorizedSmsCmd.h"

@implementation ResendAuthorizedSmsCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_RSAS;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:self.phone forKey:@"phone"];
    return sendDic;
}
@end
