//
//  SetGroupMemberCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/3/9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "SetGroupMemberCmd.h"

@implementation SetGroupMemberCmd

- (VIHOME_CMD)cmd {
    
    return VIHOME_CMD_SET_GROUP_MEMBER;
}

- (NSDictionary *)payload {
    
    if (self.addList.count) {
        [sendDic setObject:self.addList forKey:@"addList"];
    }
    if (self.deleteList.count) {
        [sendDic setObject:self.deleteList forKey:@"deleteList"];
    }
    [sendDic setObject:self.groupId forKey:@"groupId"];
    
    
    return sendDic;
}

@end
