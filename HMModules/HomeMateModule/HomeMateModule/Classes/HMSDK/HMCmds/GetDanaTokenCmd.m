//
//  GetDanaTokenCmd.m
//  HomeMate
//
//  Created by orvibo on 16/7/25.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "GetDanaTokenCmd.h"

@implementation GetDanaTokenCmd


-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_GET_DANA_TOKEN;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    
    return sendDic;
}


@end
