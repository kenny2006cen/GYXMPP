//
//  QueryShareUsers.m
//  HomeMateSDK
//
//  Created by user on 16/12/5.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryShareUsers.h"

@implementation QueryShareUsers

- (VIHOME_CMD)cmd {
    
    return VIHOME_CMD_QUERY_SHARE_USERS;
}

- (NSDictionary *)payload {
    
    if (self.uid) {
        [sendDic setObject:self.uid forKey:@"uid"];
    }
    
    return sendDic;
}



@end
