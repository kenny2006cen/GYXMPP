//
//  DeleteFamilyCmd.m
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeleteFamilyCmd.h"

@implementation DeleteFamilyCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DELETE_FAMILY;
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
