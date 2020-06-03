//
//  QueryStatisticsCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryStatisticsCmd.h"

@implementation QueryStatisticsCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QS;
}

-(NSDictionary *)payload
{
    [sendDic setObject:@(self.LastUpdateTime) forKey:@"lastUpdateTime"];
    
    return sendDic;
}

@end
