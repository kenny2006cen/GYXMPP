//
//  QueryDevicePropertyStatusCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2018/11/22.
//  Copyright © 2018 orvibo. All rights reserved.
//

#import "QueryDevicePropertyStatusCmd.h"

@implementation QueryDevicePropertyStatusCmd

-(VIHOME_CMD)cmd{
    return VIHOME_CMD_QUERY_DEVICE_STATUS; // 查询设备实时属性
}
-(NSDictionary *)payload{
    if (self.deviceList) {
        [sendDic setObject:self.deviceList forKey:@"deviceList"];
    }
    return sendDic;
}
@end
