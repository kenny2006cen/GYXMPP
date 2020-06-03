//
//  HMTokenLoginCmd.m
//  HomeMateSDK
//
//  Created by Alic on 2020/4/23.
//  Copyright © 2020 orvibo. All rights reserved.
//

#import "HMTokenLoginCmd.h"
#import "HMConstant.h"


@implementation HMTokenLoginCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_TOKEN_LOGIN;
}

-(NSDictionary *)payload
{
    NSString *appSetupId = phoneIdentifier();
    if (userAccout().isWidget){
        appSetupId = [userAccout() widgetUserInfo][@"appSetupId"]?:appSetupId;
    }
    if (appSetupId) {
        [sendDic setObject:appSetupId forKey:@"appSetupId"];
    }
    if (self.accessToken) {
        [sendDic setObject:self.accessToken forKey:@"accessToken"];
    }
    
    return sendDic;
}
@end
