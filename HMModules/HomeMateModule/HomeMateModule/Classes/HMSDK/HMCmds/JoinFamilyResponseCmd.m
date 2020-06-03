//
//  JoinFamilyResponseCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/6/14.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "JoinFamilyResponseCmd.h"

@implementation JoinFamilyResponseCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_JOIN_FAMILY_RESPONSE;
}

-(NSDictionary *)payload
{
    if (self.familyJoinId) {
        [sendDic setObject:self.familyJoinId forKey:@"familyJoinId"];
    }
    
    [sendDic setObject:@(self.type) forKey:@"type"];
    
    return sendDic;
}
@end
