//
//  QueryPowerCmd.m
//  HomeMate
//
//  Created by Air on 16/6/12.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QueryPowerCmd.h"

@implementation QueryPowerCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_POWER;
}
-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:self.uid forKey:@"uid"];
    
    return sendDic;
}

@end
