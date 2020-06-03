//
//  AuthorizedCancelCmd.m
//  
//
//  Created by Air on 15/12/4.
//
//

#import "AuthorizedCancelCmd.h"

@implementation AuthorizedCancelCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_AUC;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.authorizedUnlockId forKey:@"authorizedUnlockId"];
    return sendDic;
}


@end
