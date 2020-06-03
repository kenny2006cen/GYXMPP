//
//  QueryLastMessageCmd.m
//  HomeMate
//
//  Created by liuzhicai on 16/9/26.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QueryLastMessageCmd.h"

@implementation QueryLastMessageCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_LAST_MESSAGE;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    [sendDic setObject:self.lastUpdateTime?:@(0) forKey:@"lastUpdateTime"];
    return sendDic;
}



@end
