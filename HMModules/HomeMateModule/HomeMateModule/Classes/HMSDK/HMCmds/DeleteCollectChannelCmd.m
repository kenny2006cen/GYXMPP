//
//  DeleteCollectChannelCmd.m
//  HomeMate
//
//  Created by orvibo on 16/7/20.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "DeleteCollectChannelCmd.h"

@implementation DeleteCollectChannelCmd

- (VIHOME_CMD)cmd {

    return VIHOME_CMD_COLLECTION_CHANNEL_CANCLE;
}

- (NSDictionary *)payload {

    [sendDic setObject:_channelCollectionId forKey:@"channelCollectionId"];
    return sendDic;
}

@end
