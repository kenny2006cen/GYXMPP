//
//  ModifyRoomAuthorityCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/6/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyRoomAuthorityCmd.h"

@implementation ModifyRoomAuthorityCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MODIFY_ROOM_AUTHORITY;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if (self.roomId) {
        [sendDic setObject:self.roomId forKey:@"roomId"];
    }
    [sendDic setObject:@(self.isAuthorized) forKey:@"isAuthorized"];
    return sendDic;
}
@end
