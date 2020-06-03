//
//  CollectChannelCmd.m
//  HomeMate
//
//  Created by orvibo on 16/7/20.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "CollectChannelCmd.h"

@implementation CollectChannelCmd

- (VIHOME_CMD)cmd {

    return VIHOME_CMD_COLLECTION_CHANNEL;
}

- (NSDictionary *)payload {

    [sendDic setObject:self.uid forKey:@"uid"];
    [sendDic setObject:_deviceId forKey:@"deviceId"];
    [sendDic setObject:[NSNumber numberWithInt:_channelId] forKey:@"channelId"];
    [sendDic setObject:[NSNumber numberWithInt:_isHd] forKey:@"isHd"];
    [sendDic setObject:_countryId forKey:@"countryId"];
    return sendDic;
}

@end
