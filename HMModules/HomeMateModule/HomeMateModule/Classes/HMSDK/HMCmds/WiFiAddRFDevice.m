//
//  WiFiAddRFDevice.m
//  HomeMateSDK
//
//  Created by peanut on 2016/12/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "WiFiAddRFDevice.h"

@implementation WiFiAddRFDevice

-(NSDictionary *)payload
{
    [super payload];
    if (self.appDeviceId) {
        [sendDic setObject:self.appDeviceId forKey:@"appDeviceId"];
    }
    return sendDic;
}

@end
