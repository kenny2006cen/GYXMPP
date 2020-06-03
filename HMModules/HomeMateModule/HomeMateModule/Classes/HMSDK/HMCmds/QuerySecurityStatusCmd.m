//
//  QuerySecurityStatusCmd.m
//  HomeMateSDK
//
//  Created by Air on 17/2/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QuerySecurityStatusCmd.h"

@implementation QuerySecurityStatusCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_SECURITY_STATUS;
}
-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    
    return sendDic;
}


@end
