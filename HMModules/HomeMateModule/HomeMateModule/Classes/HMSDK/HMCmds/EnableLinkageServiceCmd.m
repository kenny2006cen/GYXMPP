//
//  EnableLinkageServiceCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2019/6/12.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "EnableLinkageServiceCmd.h"

@implementation EnableLinkageServiceCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_REPORT_LINKAGE;
}

-(NSDictionary *)payload
{
    if (self.userName) {
        [sendDic setObject:self.userName forKey:@"userName"];
    }
    if (self.linkageId) {
        [sendDic setObject:self.linkageId forKey:@"linkageId"];

    }
    
    return sendDic;
    
}
@end
