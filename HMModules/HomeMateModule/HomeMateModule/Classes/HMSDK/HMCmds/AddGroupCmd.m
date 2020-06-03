//
//  AddGroupCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/3/9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddGroupCmd.h"

@implementation AddGroupCmd

- (VIHOME_CMD)cmd {
    
    return VIHOME_CMD_AG;
}

- (NSDictionary *)payload {
    
    [sendDic setObject:self.groupName forKey:@"groupName"];
    [sendDic setObject:@(self.pic) forKey:@"pic"];
    
    
    return sendDic;
}

@end
