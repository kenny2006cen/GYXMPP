//
//  QueryFirmwareVersionCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2017/12/25.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryFirmwareVersionCmd.h"

@implementation QueryFirmwareVersionCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_FIRMWARE_VERSION;
}

-(NSDictionary *)payload
{
    if (self.deviceId.length) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    if (self.typeArr) {
        [sendDic setObject:self.typeArr forKey:@"typeArr"];
    }
    if (self.language) {
        [sendDic setObject:self.language forKey:@"language"];
    }
    
    return sendDic;
}
@end
