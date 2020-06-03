//
//  HMQueryLoginTokenCmd.m
//  HomeMateSDK
//
//  Created by Alic on 2020/4/23.
//  Copyright © 2020 orvibo. All rights reserved.
//

#import "HMQueryLoginTokenCmd.h"
#import "HMConstant.h"

@implementation HMQueryLoginTokenCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_LOGIN_TOKEN;
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
    return sendDic;
}
@end
