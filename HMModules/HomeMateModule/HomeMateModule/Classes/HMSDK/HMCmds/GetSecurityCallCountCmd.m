//
//  GetSecurityCallCount.m
//  HomeMate
//
//  Created by orvibo on 16/6/28.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "GetSecurityCallCountCmd.h"

@implementation GetSecurityCallCountCmd

- (VIHOME_CMD)cmd {

    return VIHOME_CMD_GET_SECURITY_CALL_COUNT;
}

- (NSDictionary *)payload {

    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    return sendDic;
}

@end
