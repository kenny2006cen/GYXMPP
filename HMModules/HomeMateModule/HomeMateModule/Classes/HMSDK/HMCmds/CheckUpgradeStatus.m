//
//  CheckUpgradeStatus.m
//  HomeMate
//
//  Created by liqiang on 16/7/20.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "CheckUpgradeStatus.h"

@implementation CheckUpgradeStatus
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_CHECK_UPGRADE_STATUS;
}

-(NSDictionary *)payload
{
    return sendDic;
}
@end
