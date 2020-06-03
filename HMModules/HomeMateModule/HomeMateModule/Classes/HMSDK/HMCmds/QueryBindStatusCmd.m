//
//  QueryHubBindStatusCmd.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/6/16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryBindStatusCmd.h"

@implementation QueryBindStatusCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SEARCH_HUB_BIND_STATUS;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.uidList forKey:@"uidList"];
    return sendDic;
}

@end
