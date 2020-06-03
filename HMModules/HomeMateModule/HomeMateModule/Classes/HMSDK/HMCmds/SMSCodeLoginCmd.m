//
//  SMSCodeLoginCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2020/4/23.
//  Copyright © 2020 orvibo. All rights reserved.
//

#import "SMSCodeLoginCmd.h"

@implementation SMSCodeLoginCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SMS_CODE_LOGIN;
}

-(NSDictionary *)payload
{
    
    if (self.phone) {
        [sendDic setObject:self.phone forKey:@"phone"];
    }
    
    if (self.areaCode) {
        [sendDic setObject:self.areaCode forKey:@"areaCode"];
    }
    
    if (self.code) {
        [sendDic setObject:self.code forKey:@"code"];
    }
        
    return sendDic;
}
@end
