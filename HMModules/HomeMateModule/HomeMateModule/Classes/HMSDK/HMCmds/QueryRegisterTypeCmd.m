//
//  QueryRegisterTypeCmd.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/11/30.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryRegisterTypeCmd.h"

@implementation QueryRegisterTypeCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_REGISTER_TYPE;
}

-(NSDictionary *)payload
{
    if (self.accountArr) {
        [sendDic setObject:self.accountArr forKey:@"accountArr"];
    }
    return sendDic;
}


@end
