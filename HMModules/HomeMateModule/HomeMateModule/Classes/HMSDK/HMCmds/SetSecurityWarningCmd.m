//
//  SetSecurityWarningCmd.m
//  HomeMate
//
//  Created by orvibo on 16/6/28.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "SetSecurityWarningCmd.h"

@implementation SetSecurityWarningCmd

- (VIHOME_CMD)cmd {

    return VIHOME_CMD_SET_SECURITY_WARNING;
}

- (NSDictionary *)payload {

    [sendDic setObject:_userId      forKey:@"userId"];
    [sendDic setObject:_securityId  forKey:@"securityId"];

    if (_warningTypeChange) {
        [sendDic setObject:@(_warningType) forKey:@"warningType"];
    }

    if (_warningMemberAddList) {
        [sendDic setObject:_warningMemberAddList forKey:@"warningMemberAddList"];
    }

    if (_warningMemberModifyList) {
        [sendDic setObject:_warningMemberModifyList forKey:@"warningMemberModifyList"];
    }

    if (_warningMemberDeleteList) {
        [sendDic setObject:_warningMemberDeleteList forKey:@"warningMemberDeleteList"];
    }

    return sendDic;
}

@end
