//
//  GetHubStatusCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2017/6/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "GetHubStatusCmd.h"

@implementation GetHubStatusCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_GET_HUB_ONLINE_STATUS;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    return sendDic;
}
@end
