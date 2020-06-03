//
//  HMGetEPCommunity.m
//  HomeMateSDK
//
//  Created by orvibo on 2018/7/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMGetEPCommunity.h"

@implementation HMGetEPCommunity

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_GET_EP_COMMUNITY;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.userId forKey:@"userId"];
    [sendDic setObject:self.phone forKey:@"phone"];
    [sendDic setObject:self.openid forKey:@"openid"];
    return sendDic;
}

@end
