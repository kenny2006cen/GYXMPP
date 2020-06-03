//
//  QueryStatus.m
//  HomeMate
//
//  Created by Air on 16/6/12.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QueryStatusCmd.h"

@implementation QueryStatusCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ENERGY_UPLOAD;
}
-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    
    return sendDic;
}
@end
