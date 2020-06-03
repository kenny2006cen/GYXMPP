//
//  VHAPWifiInfo.m
//  HomeMate
//
//  Created by Orvibo on 15/8/11.
//  Copyright © 2017年 Orvibo. All rights reserved.
//

#import "HMAPWifiInfo.h"

@implementation HMAPWifiInfo
- (instancetype)initForDic:(NSDictionary *)dic {
    if (self = [super init]) {
        self.auth =[dic objectForKey:@"auth"];
        self.bssid = [dic objectForKey:@"bssid"];
        self.channel = [[dic objectForKey:@"channel"] integerValue];
        self.enc = [dic objectForKey:@"enc"];
        self.rssi = [[dic objectForKey:@"rssi"] integerValue];
        self.ssid = [dic objectForKey:@"ssid"];
    }
    
    return self;
    
}



@end
