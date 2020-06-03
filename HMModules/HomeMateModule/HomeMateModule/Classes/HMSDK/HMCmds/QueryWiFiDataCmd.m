//
//  QueryWiFiDataCmd.m
//  HomeMate
//
//  Created by Air on 16/7/25.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QueryWiFiDataCmd.h"

@implementation QueryWiFiDataCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_WIFI_DEVICE_DATA;
}

-(NSDictionary *)payload
{
    [sendDic setObject:@(self.LastUpdateTime) forKey:@"lastUpdateTime"];
    
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    
    [sendDic setObject:[NSNumber numberWithInteger:self.PageIndex] forKey:@"pageIndex"];
    [sendDic setObject:self.dataType forKey:@"dataType"];
    return sendDic;
}

@end
