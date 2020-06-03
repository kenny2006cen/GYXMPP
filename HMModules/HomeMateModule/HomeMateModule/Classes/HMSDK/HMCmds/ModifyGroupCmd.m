//
//  ModifyGroupCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/3/9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyGroupCmd.h"

@implementation ModifyGroupCmd

- (VIHOME_CMD)cmd {
    
    return VIHOME_CMD_MG;
}

- (NSDictionary *)payload {
    
    [sendDic setObject:self.groupId forKey:@"groupId"];
    [sendDic setObject:self.groupName forKey:@"groupName"];
    [sendDic setObject:@(self.pic) forKey:@"pic"];
    
    
    return sendDic;
}


@end
