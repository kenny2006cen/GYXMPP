//
//  CheckMultiHubsUpgradeStatusCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/2/20.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "CheckMultiHubsUpgradeStatusCmd.h"

@implementation CheckMultiHubsUpgradeStatusCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_CHECK_MULTI_HUBS_UPGRADE_STATUS;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    return sendDic;
}
@end
