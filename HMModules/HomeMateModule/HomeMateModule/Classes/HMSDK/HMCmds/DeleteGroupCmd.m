//
//  DeleteGroupCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/3/9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeleteGroupCmd.h"

@implementation DeleteGroupCmd

- (VIHOME_CMD)cmd {
    
    return VIHOME_CMD_DG;
}

- (NSDictionary *)payload {
    
    [sendDic setObject:self.groupId forKey:@"groupId"];
    
    
    return sendDic;
}

@end
