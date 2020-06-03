//
//  SequenceSyncCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/12/18.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "SequenceSyncCmd.h"

@implementation SequenceSyncCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_SEQUENCE_SYNCHRONIZATION;
}

-(NSDictionary *)payload
{
    if (self.userName) {
        [sendDic setObject:self.userName forKey:@"userName"];
    }
    if (self.tableName) {
        [sendDic setObject:self.tableName forKey:@"tableName"];
    }
    if (self.dataList) {
        [sendDic setObject:self.dataList forKey:@"data"];
    }
    
    return sendDic;
}
@end
