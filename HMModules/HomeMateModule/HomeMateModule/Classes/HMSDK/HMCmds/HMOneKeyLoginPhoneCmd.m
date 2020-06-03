//
//  OneKeyLoginPhoneCmd.m
//  HomeMateSDK
//
//  Created by wjy on 2020/4/26.
//  Copyright © 2020 orvibo. All rights reserved.
//

#import "HMOneKeyLoginPhoneCmd.h"

@implementation HMOneKeyLoginPhoneCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ONE_KEY_LOGIN_BY_VERIFY;
}

-(NSDictionary *)payload
{
    if (self.oneKeyToken) {
        [sendDic setObject:self.oneKeyToken forKey:@"oneKeyToken"];
    }
    if (self.sysVersion) {
        [sendDic setObject:self.sysVersion forKey:@"sysVersion"];
    }
    if (self.phone) {
        [sendDic setObject:self.phone forKey:@"phone"];
    }
    return sendDic;
}
@end
