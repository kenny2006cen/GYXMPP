//
//  HMQueryUserTerminalDevice.m
//  HomeMateSDK
//
//  Created by liqiang on 2018/8/30.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMQueryUserTerminalDevice.h"

@implementation HMQueryUserTerminalDevice
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_USER_TERMINAL_DEVICE;
}

-(NSDictionary *)payload
{
    if(self.userId){
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if(self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];

    }
    
    return sendDic;
}
@end
