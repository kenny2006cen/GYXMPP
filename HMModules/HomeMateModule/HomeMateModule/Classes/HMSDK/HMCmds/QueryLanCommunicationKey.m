//
//  QueryLanCommunicationKey.m
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/8/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "QueryLanCommunicationKey.h"

@implementation QueryLanCommunicationKey

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_LAN_COMMUNICATION_KEY;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    return sendDic;
}

@end
