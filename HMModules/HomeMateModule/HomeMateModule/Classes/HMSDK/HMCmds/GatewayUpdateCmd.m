//
//  GatewayUpdateCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2018/9/6.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "GatewayUpdateCmd.h"

@implementation GatewayUpdateCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_FU;
}

-(NSDictionary *)payload
{
    [sendDic setObject:@(self.targetType) forKey:@"targetType"];
    [sendDic setObject:@(self.type) forKey:@"type"];
    
    if (self.target.length) {
        [sendDic setObject:self.target forKey:@"target"];
    }
    return sendDic;
}
@end
