//
//  ModifyHomeNameCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyHomeNameCmd.h"

@implementation ModifyHomeNameCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MN;
}

-(NSDictionary *)payload
{
    if(self.homeName.length){
        [sendDic setObject:self.homeName forKey:@"homeName"];
        
    }
    if (self.country.length) {
        [sendDic setObject:self.country forKey:@"country"];
    }
    if(self.countryCode.length) {
        [sendDic setObject:self.countryCode forKey:@"countryCode"];

    }
    return sendDic;
}


@end
