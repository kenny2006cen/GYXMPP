//
//  QueryRoomAuthority.m
//  HomeMateSDK
//
//  Created by peanut on 2017/6/20.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryRoomAuthorityCmd.h"

@implementation QueryRoomAuthorityCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_ROOM_AUTHORITY;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }

    return sendDic;
}
@end
