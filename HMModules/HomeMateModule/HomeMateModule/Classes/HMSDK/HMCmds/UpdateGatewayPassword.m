//
//  UpdateGatewayPassword.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/11.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "UpdateGatewayPassword.h"

@implementation UpdateGatewayPassword
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_UPDATE_GATEWAY_PASSWORD;
}
-(NSDictionary *)payload
{
    if (self.password.length) {
        [sendDic setObject:self.password forKey:@"password"];
    }
    if (self.blueExtAddr.length) {
        [sendDic setObject:self.blueExtAddr forKey:@"blueExtAddr"];
    }
    return sendDic;
}
@end
