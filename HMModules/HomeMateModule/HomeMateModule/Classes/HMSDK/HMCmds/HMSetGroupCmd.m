//
//  HMSetGroupCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2019/9/20.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMSetGroupCmd.h"

@implementation HMSetGroupCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SET_GROUP;
}

-(NSDictionary *)payload
{
   
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if(self.groupId) {
        [sendDic setObject:self.groupId forKey:@"groupId"];
    }
    if(self.groupName) {
        [sendDic setObject:self.groupName forKey:@"groupName"];
    }
    if(self.groupMemberAddList) {
        [sendDic setObject:self.groupMemberAddList forKey:@"groupMemberAddList"];
    }
    if(self.groupMemberDeleteList) {
        [sendDic setObject:self.groupMemberDeleteList forKey:@"groupMemberDeleteList"];
    }
    
    if(self.roomId) {
        [sendDic setObject:self.roomId forKey:@"roomId"];
    }
    
    
    return sendDic;
}

-(BOOL)sendToServer{

    return YES;
}

-(BOOL)onlySendOnce{

    return YES;
}

@end
