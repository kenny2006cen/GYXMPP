//
//  SetDoorlockUserNameCmd.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "SetDoorlockUserNameCmd.h"

@implementation SetDoorlockUserNameCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SDUN;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.doorUserId forKey:@"doorUserId"];
    [sendDic setObject:self.name forKey:@"name"];
    return sendDic;
}
@end
