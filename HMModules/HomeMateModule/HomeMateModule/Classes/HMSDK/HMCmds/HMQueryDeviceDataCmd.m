//
//  HMQueryDeviceDataCmd.m
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/10/25.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMQueryDeviceDataCmd.h"

@implementation HMQueryDeviceDataCmd

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
    [sendDic setObject:[NSNumber numberWithInt:self.pageIndex] forKey:@"pageIndex"];
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
