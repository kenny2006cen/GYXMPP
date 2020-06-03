//
//  QueryFamilyUsers.m
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryFamilyUsers.h"

@implementation QueryFamilyUsers

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_FAMILY_USERS;
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
