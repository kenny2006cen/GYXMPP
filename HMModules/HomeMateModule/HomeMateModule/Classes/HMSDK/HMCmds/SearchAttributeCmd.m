//
//  SearchAttributeCmd.m
//  HomeMate
//
//  Created by liuzhicai on 16/9/18.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "SearchAttributeCmd.h"

@implementation SearchAttributeCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SEARCH_ATTRIBUTE;
}
-(NSDictionary *)payload
{
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    [sendDic setObject:@(self.attributeId) forKey:@"attributeId"];
    return sendDic;
}

@end
