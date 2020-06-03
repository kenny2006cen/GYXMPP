//
//  RemoteGateway+WiFi.h
//  HomeMate
//
//  Created by Air on 16/7/25.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "RemoteGateway.h"

@interface RemoteGateway (WiFi)

- (void)readAllDataWithFamilyId:(NSString *)familyId completion:(commonBlockWithObject)completion;
- (void)didReceiveWifiTableData:(NSDictionary *)dic;

@end
