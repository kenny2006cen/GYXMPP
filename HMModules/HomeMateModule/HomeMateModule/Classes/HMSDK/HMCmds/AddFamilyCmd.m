//
//  AddFamilyCmd.m
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddFamilyCmd.h"

@implementation AddFamilyCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ADD_FAMILY;
}

-(NSDictionary *)payload
{
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    
    if (self.familyName) {
        [sendDic setObject:self.familyName forKey:@"familyName"];
    }
    
    return sendDic;
}



@end
