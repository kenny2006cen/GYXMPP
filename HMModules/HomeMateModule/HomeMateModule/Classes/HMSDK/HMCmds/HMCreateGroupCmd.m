//
//  HMCreateGroupCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2019/9/20.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMCreateGroupCmd.h"

@implementation HMCreateGroupCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_CREAT_GROUP;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if(self.groupName) {
        [sendDic setObject:self.groupName forKey:@"groupName"];
    }
    if(self.groupMemberList) {
        [sendDic setObject:self.groupMemberList forKey:@"groupMemberList"];
    }
    if(self.pic) {
        [sendDic setObject:self.pic forKey:@"pic"];
    }
    if(self.roomId) {
        [sendDic setObject:self.roomId forKey:@"roomId"];
    }
    [sendDic setObject:@(self.groupType) forKey:@"groupType"];
    
    
    return sendDic;
}

-(BOOL)sendToServer{

    return YES;
}

-(BOOL)onlySendOnce{

    return YES;
}

@end
