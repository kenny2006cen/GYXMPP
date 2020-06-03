//
//  OneKeyLoginCmd.m
//  HomeMateSDK
//
//  Created by wjy on 2020/4/22.
//  Copyright © 2020 orvibo. All rights reserved.
//

#import "HMOneKeyLoginCmd.h"

@implementation HMOneKeyLoginCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ONEKEY_LOGIN;
}

-(NSDictionary *)payload
{
    if (self.oneKeyToken) {
        [sendDic setObject:self.oneKeyToken forKey:@"oneKeyToken"];
    }
    if (self.sysVersion) {
        [sendDic setObject:self.sysVersion forKey:@"sysVersion"];
    }
    return sendDic;
}
@end
