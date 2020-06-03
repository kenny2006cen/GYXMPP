//
//  SearchFamilyInLanCmd.m
//  HomeMateSDK
//
//  Created by peanut on 2017/6/14.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "SearchFamilyInLanCmd.h"

@implementation SearchFamilyInLanCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SEARCH_FAMILY_IN_LAN;
}

-(NSDictionary *)payload
{
    if (self.uidList.count) {
        [sendDic setObject:self.uidList forKey:@"uidList"];
    } else {
        [sendDic setObject:@[] forKey:@"uidList"];
    }
    
    return sendDic;
}
@end
