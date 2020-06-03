//
//  QueryQrcodeTokenCmd.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2018/3/27.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "QueryQrcodeTokenCmd.h"

@implementation QueryQrcodeTokenCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_QR_CODE_TOKEN;
}

-(NSDictionary *)payload
{
    if (self.userId.length) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if (self.token.length) {
        [sendDic setObject:self.token forKey:@"token"];
    }
    return sendDic;
}

@end
