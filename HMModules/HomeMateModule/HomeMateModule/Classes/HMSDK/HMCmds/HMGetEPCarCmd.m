//
//  HMGetEPCarCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2018/7/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMGetEPCarCmd.h"

@implementation HMGetEPCarCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_GET_EP_CAR;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.userId forKey:@"userId"];
    [sendDic setObject:self.phone forKey:@"phone"];
    [sendDic setObject:self.openid forKey:@"openid"];
    return sendDic;
}

@end
