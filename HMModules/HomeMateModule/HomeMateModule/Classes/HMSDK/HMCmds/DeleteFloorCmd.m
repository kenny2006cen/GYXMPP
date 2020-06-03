//
//  DeleteFloorCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "DeleteFloorCmd.h"

@implementation DeleteFloorCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DF;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.floorId forKey:@"floorId"];
    
    return sendDic;
}


@end
