//
//  ClockSyncCmd.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ClockSyncCmd.h"

@implementation ClockSyncCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_CS;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.Timezone forKey:@"timezone"];
    [sendDic setObject:[NSNumber numberWithInt:self.DST] forKey:@"dst"];
    [sendDic setObject:[NSNumber numberWithInt:self.Time] forKey:@"time"];
    
    return sendDic;
}

@end
