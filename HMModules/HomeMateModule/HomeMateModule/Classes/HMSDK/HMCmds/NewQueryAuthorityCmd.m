//
//  NewQueryAuthorityCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2019/10/15.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "NewQueryAuthorityCmd.h"

@implementation NewQueryAuthorityCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_NEW_QUERY_AUTHORITY;
}

-(NSDictionary *)payload
{
    
    if (self.authorityType ) {
        [sendDic setObject:self.authorityType forKey:@"authorityType"];
    }
    
    if (self.uid) {
        [sendDic setObject:self.uid forKey:@"uid"];
    }
    if (self.authorityTypes) {
        [sendDic setObject:self.authorityTypes forKey:@"authorityTypes"];
    }
    
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    
    if(self.start) {
        [sendDic setObject:self.start forKey:@"start"];
    }
    
    if (self.limit) {
        [sendDic setObject:self.limit forKey:@"limit"];
    }
    
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    
    [sendDic setObject:@(self.type) forKey:@"type"];
    
    return sendDic;
}


@end
