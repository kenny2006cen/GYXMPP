//
//  HMQueryUserMessage.m
//  HomeMateSDK
//
//  Created by user on 16/10/11.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryUserMessage.h"

@implementation QueryUserMessage

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_USER_MESSAGE;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.userId forKey:@"userId"];
    if (self.tableName) {
        [sendDic setObject:self.tableName forKey:@"tableName"];
    }
    
    [sendDic setObject:[NSNumber numberWithInt:self.minSequence] forKey:@"minSequence"];
    
    [sendDic setObject:[NSNumber numberWithInt:self.maxSequence] forKey:@"maxSequence"];
    [sendDic setObject:[NSNumber numberWithInt:self.type] forKey:@"type"];

    if (self.readCount) {
        [sendDic setObject:[NSNumber numberWithInt:self.readCount] forKey:@"readCount"];
    }
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.dataFlag) {
        [sendDic setObject:self.dataFlag forKey:@"dataFlag"];
    }
    return sendDic;
}


@end
