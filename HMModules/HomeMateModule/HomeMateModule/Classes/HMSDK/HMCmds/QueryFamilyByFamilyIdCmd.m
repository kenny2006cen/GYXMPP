//
//  QueryFamilyByFamilyId.m
//  HomeMateSDK
//
//  Created by peanut on 2017/7/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryFamilyByFamilyIdCmd.h"

@implementation QueryFamilyByFamilyIdCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_FAMILY_BY_FAMILYID;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    return sendDic;
}

@end
