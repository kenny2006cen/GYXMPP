//
//  SearchMdns.h
//  Vihome
//
//  Created by Air on 15-1-27.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "SingletonClass.h"
#import "HMTypes.h"

@interface SearchMdns : SingletonClass <NSNetServiceBrowserDelegate,NSNetServiceDelegate>

-(void)searchGatewaysAndPostResult;

// 搜索主机
-(void)searchGatewaysWtihCompletion:(SearhMdnsBlock)completion;

// 搜索主机以外的设备
-(void)mdnsSearchDevicesWithDeviceType:(KDeviceType)deviceType completion:(SearhMdnsBlock)completion;

-(void)didFindGateway:(NSNetService *)sender udpInfo:(NSDictionary *)udpInfo;

@end
