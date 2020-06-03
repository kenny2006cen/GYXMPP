//
//  JoinFamilyCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/6/14.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "JoinFamilyCmd.h"

@implementation JoinFamilyCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_JOIN_FAMILY;
}

-(NSDictionary *)payload
{
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    
    return sendDic;
}
@end
