//
//  QueryAdminFamilyCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/7/27.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryAdminFamilyCmd.h"

@implementation QueryAdminFamilyCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_ADMIN_FAMILY;
}

-(NSDictionary *)payload
{
    if (self.userName) {
        [sendDic setObject:self.userName forKey:@"userName"];
    }
    return sendDic;
}

@end
