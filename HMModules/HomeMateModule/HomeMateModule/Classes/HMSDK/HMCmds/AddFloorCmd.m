//
//  AddFloorCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddFloorCmd.h"

@implementation AddFloorCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_AF;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.floorName forKey:@"floorName"];
    
    [sendDic setObject:self.familyId forKey:@"familyId"];
    
    return sendDic;
}


@end
