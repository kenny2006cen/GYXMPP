//
//  DeleteVisitorRecordCmd.m
//  HomeMate
//
//  Created by orvibo on 15/12/28.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "DeleteVisitorRecordCmd.h"

@implementation DeleteVisitorRecordCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DDR;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:@(self.type) forKey:@"type"];
    return sendDic;
}

@end
