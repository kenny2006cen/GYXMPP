//
//  QueryUserGatewayBindCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2018/1/20.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "QueryUserGatewayBindCmd.h"

@implementation QueryUserGatewayBindCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_USER_GATEWAY_BIND;
}

-(NSDictionary *)payload
{
    
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    return sendDic;
}

@end
