//
//  QuerySongListCmd.m
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/10/23.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "QuerySongListCmd.h"

@implementation QuerySongListCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_DEVICE_DATA;
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
    
    if (self.Count) {
        [sendDic setObject:[NSNumber numberWithInt:self.Count] forKey:@"Count"];
    }
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
//    if (self.dataFlag) {
//        [sendDic setObject:self.dataFlag forKey:@"dataFlag"];
//    }
    return sendDic;
}



@end
