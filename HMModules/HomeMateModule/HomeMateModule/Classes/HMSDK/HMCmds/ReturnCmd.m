//
//  ReturnCmd.m
//  Vihome
//
//  Created by Air on 15-2-13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ReturnCmd.h"

@implementation ReturnCmd

@synthesize cmd = myCmd;

-(VIHOME_CMD)cmd
{
    return myCmd;
}

-(NSDictionary *)payload
{
    [sendDic setObject:[NSNumber numberWithInteger:self.status] forKey:@"status"];
    if (self.messageId) {
        [sendDic setObject:self.messageId forKey:@"messageId"];
    }
    
    if (sendDic[@"lastUpdateTime"]) {
        [sendDic removeObjectForKey:@"lastUpdateTime"];
    }
    
    return sendDic;
}
@end
