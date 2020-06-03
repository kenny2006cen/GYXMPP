//
//  QueryFamilyCmd.m
//  HomeMateSDK
//
//  Created by user on 17/1/19.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryFamilyCmd.h"

@implementation QueryFamilyCmd


-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_FAMILY;
}

-(NSDictionary *)payload
{
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    [sendDic setObject:@(self.type) forKey:@"type"];
    return sendDic;
}


@end
