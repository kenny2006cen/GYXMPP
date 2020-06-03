//
//  QueryClotheshorseStatusCmd.m
//  HomeMate
//
//  Created by Air on 15/11/17.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QueryClotheshorseStatusCmd.h"

@implementation QueryClotheshorseStatusCmd

-(VIHOME_CMD)cmd
{
    return CLOTHESHORSE_CMD_STATUS_QUERY;
}

-(NSDictionary *)payload
{
    if (self.deviceList) {
        [sendDic setObject:self.deviceList forKey:@"deviceList"];
    }
    return sendDic;
}


@end
