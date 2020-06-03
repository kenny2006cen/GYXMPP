//
//  QueryFilterSecurityRecordCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2017/12/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryFilterSecurityRecordCmd.h"

@implementation QueryFilterSecurityRecordCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_GET_FILTER_SECURITY_RECORD;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    
    if (self.readCount) {
        [sendDic setObject:[NSNumber numberWithInt:self.readCount] forKey:@"readCount"];
    }
    
    if (self.conditionList) {
        [sendDic setObject:self.conditionList forKey:@"conditionList"];
    }

    return sendDic;
}
@end

