
//
//  ModifyFloorCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ModifyFloorCmd.h"

@implementation ModifyFloorCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MF;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.floorId forKey:@"floorId"];
    [sendDic setObject:self.FloorName forKey:@"floorName"];
    
    return sendDic;
}


@end
