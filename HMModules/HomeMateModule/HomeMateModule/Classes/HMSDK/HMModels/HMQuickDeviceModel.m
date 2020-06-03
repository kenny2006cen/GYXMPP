//
//  HMQuickDeviceModel.m
//  HomeMateSDK
//
//  Created by Feng on 2019/8/12.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMQuickDeviceModel.h"
#import "HMBaseModel+Extension.h"


@implementation HMQuickDeviceModel
+ (NSString *)tableName {
    
    return @"QuickDevice";
}

+ (NSArray*)columns
{
    return @[
             column("userId","text"),
             column("familyId","text"),
             column("deviceId","text"),
             column("uid","text"),
             column("deviceName","text"),
             column("weight","integer"),
             column("timestamp","text"),
             column("updateTime","text"),
             ];
}

+ (NSString*)constrains
{
    return @"UNIQUE (userId,familyId,deviceId) ON CONFLICT REPLACE";
}
@end
